#Get current username
$currentUser = $env:UserName
$currentBalance = 0
$conn = New-Object -comobject ADODB.Connection

# use existing 64 bit ODBC System DSN that we set up manually
$conn.Open("CCTerminal")

# Check if freeTime has already been declared
if(-not (test-path env:freeTime)){
  # Connect to DB and retrieve user stats
  $recordset = $conn.Execute("SELECT * FROM users WHERE username = '$currentUser'")
  if ($recordset.EOF -ne $True) { #Ensure user is in database
    $loginTime = Get-WmiObject win32_networkloginprofile | ? {$_.lastlogon -ne $null} | % {[Management.ManagementDateTimeConverter]::ToDateTime($_.lastlogon)}
    $userFriendlyName = #The person's first name
    $currentBalance = $recordset.Fields.Item("gear").value #Current gear balance (1 gear = 1 minute)
    #Max freetime (currently 30 mintes)
    if ($currentBalance > 30){
        $env:freeTime = 30
    } else {
        $env:freeTime = $currentBalance
    }
  }
}
$timeSpan = New-TimeSpan -Minutes $env:freeTime #Convert gear balance into a time object
$totalTime = $loginTime + $timeSpan #Compute logoff time by adding gear balance to logon time

$env:freeTime -= 1 #Subtract a minute
$recordset = $conn.Execute("Update users set gear = gear - 1 WHERE username = '$currentUser'")

if ($(get-date) -gt $totalTime) { #You outta time - time to logoff
  $str = "logoff"
  Invoke-Expression $str
} elseif ($(($totalTime - $(get-date)).Minutes) -lt 5) {
  #Give a warning
  $remainingTime = $currentBalance

  $wshell = New-Object -ComObject Wscript.Shell

  $wshell.Popup("You have $env:freeTime minutes of free time remaining.",0,"Time is almost up!",0x30)

}
else {
  #Have fun!
}
