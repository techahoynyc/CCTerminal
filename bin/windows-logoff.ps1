#Get current username
$currentUser = $env:UserName
$currentBalance = 0
$conn = New-Object -comobject ADODB.Connection

# use existing 64 bit ODBC System DSN that we set up manually
$conn.Open("CCTerminal")

#IAN FIX THIS CONNECTION
$recordset = $conn.Execute("SELECT * FROM users WHERE username = '$currentUser'")
#$recordset = $conn.Execute("SELECT * FROM users WHERE username = 'taadmin'")
if ($recordset.EOF -ne $True) {
$loginTime = Get-WmiObject win32_networkloginprofile | ? {$_.lastlogon -ne $null} | % {[Management.ManagementDateTimeConverter]::ToDateTime($_.lastlogon)}
$userFriendlyName = #The person's first name
$currentBalance = $recordset.Fields.Item("gear").value #How much time this person has in the bank in minutes

if(-not (test-path env:freeTime)){
    if ($currentBalance > 30){
        $env:freeTime = 30
    } else {
        $env:freeTime = $currentBalance
    }
}


$timeSpan = New-TimeSpan -Minutes $env:freeTime #Convert their balance into a time object
$totalTime = $loginTime + $timeSpan #Find the time that with their total balance they would have to log off by adding the time span to the time they logged in

$env:freeTime -= 1
$recordset = $conn.Execute("Update users set gear = gear - 1 WHERE username = '$currentUser'")
if ($(get-date) -gt $totalTime) { #You outta time, gtfo
#update database to set time available to 0 ignoring initial value of possibly -1
#Ian make a sql call to set the user banace to 0 this has to be before the logoff statement
#UPDATE TimeBalances SET balance = 0 WHERE username = $currentUser;
$str = "logoff"
Invoke-Expression $str
}
elseif ($(($totalTime - $(get-date)).Minutes) -lt 5) {

#Give a warning
$remainingTime = $currentBalance

$wshell = New-Object -ComObject Wscript.Shell

$wshell.Popup("You have $env:freeTime minutes of free time remaining.",0,"Time is almost up!",0x30)

}
else {
#Have fun!

}

}

