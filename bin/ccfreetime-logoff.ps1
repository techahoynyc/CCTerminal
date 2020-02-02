#Get current username
$currentUser = $env:UserName
$currentBalance = 0
$conn = New-Object -comobject ADODB.Connection
$today = $(get-date).toString("MM/dd/yyyy")
# use existing 64 bit ODBC System DSN that we set up manually
$conn.Open("CCTerminal")

function updateGearBal(){
  $maxFreeTime = 30 #query this from DB in the future
  $recordset = $conn.Execute("Update users set lastGearBalUpdate = '$today' WHERE username = '$currentUser'")
  $recordset = $conn.Execute("SELECT gear,freetimeGearBal FROM users WHERE username='$currentUser'")
  $userGear = $recordset.Fields.Item("gear").value
  $userFreeTimeGearBal = $recordset.Fields.Item("freetimeGearBal").value
  if($userFreeTimeGearBal.Equals([DBNull]::Value)){$userFreeTimeGearBal = 0} #check for null
  $freeTimeDif = ($maxFreeTime - $userFreeTimeGearBal)
  if ($userGear -gt $freeTimeDif){
    $recordset = $conn.Execute("Update users set freetimeGearBal = '$maxFreeTime' WHERE username = '$currentUser'")
    $recordset = $conn.Execute("Update users set gear = gear - '$freeTimeDif' WHERE username = '$currentUser'")
    write-host "max freetime!"
    return $maxFreeTime
  } else {
    $recordset = $conn.Execute("Update users set freetimeGearBal = freetimeGearBal + '$freeTimeDif' WHERE username = '$currentUser'")
    $recordset = $conn.Execute("Update users set gear = 0 WHERE username = '$currentUser'")
    write-host "some freetime"
    return ($userFreeTimeGearBal + $freeTimeDif)
  }
}

# Connect to DB and verify freetime
while (1) {
  $recordset = $conn.Execute("SELECT * FROM stats")
  if ($recordset.EOF -ne $True) { #Ensure we have results
      $freetime = $recordset.Fields.Item("freetime").value #freetime = 1
      if($freetime -eq 1){
        # Alert user
        #$wshell = New-Object -ComObject Wscript.Shell
        #$wshell.Popup("Freetime has begun!`nThe computer will logoff when your time expires.",0,"codeCadet Freetime",0x30)
        # Connect to DB and retrieve user stats
        $recordset = $conn.Execute("SELECT * FROM users WHERE username = '$currentUser'")
        if ($recordset.EOF -ne $True) { #Ensure user is in database
          $lastGearBalUpdate = $recordset.Fields.Item("lastGearBalUpdate").value
          $freetimeGearBal = $recordset.Fields.Item("freetimeGearBal").value
          write-host $freetimeGearBal
          if($lastGearBalUpdate.Equals([DBNull]::Value)){$freetimeGearBal = updateGearBal} #check for null
          if ($lastGearBalUpdate -lt $today){
            $freetimeGearBal = updateGearBal
          }
          $freetimeGearBal = $freetimeGearBal - 1
          $loginTime = Get-WmiObject win32_networkloginprofile | ? {$_.lastlogon -ne $null} | % {[Management.ManagementDateTimeConverter]::ToDateTime($_.lastlogon)}
          $userFriendlyName = #The person's first name

          $timeSpan = New-TimeSpan -Minutes $freetimeGearBal #Convert gear balance into a time object
          $totalTime = $loginTime + $timeSpan #Compute logoff time by adding gear balance to logon time

          if ($(get-date) -gt $totalTime) { #You outta time - time to logoff
            $str = "logoff"
            Invoke-Expression $str
          } elseif ($(($totalTime - $(get-date)).Minutes) -lt 5) {
            #Give a warning
            $wshell = New-Object -ComObject Wscript.Shell
            $wshell.Popup("You have $freetimeGearBal minutes of free time remaining.",0,"Time is almost up!",0x30)
          }
          else {
            #Have fun!
          }
          #update freetimeGearBal
          $recordset = $conn.Execute("Update users set freetimeGearBal = '$freetimeGearBal' WHERE username = '$currentUser'")
        } else {
          write-host "oops shouldn't be here"
        }
      }
  }
  Start-Sleep -s 60 #sleep for one minute
}
