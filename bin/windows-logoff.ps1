#Get current username
$currentUser = $env:UserName

$conn = New-Object -comobject ADODB.Connection

# use existing 64 bit ODBC System DSN that we set up manually
$conn.Open("PostgreSQL35W")

#IAN FIX THIS CONNECTION
$recordset = $conn.Execute("SELECT * FROM TimeBalances WHERE username = $currentUser")
while ($recordset.EOF -ne $True) {
$loginTime = #On the login script connect to the database and set this value in the database as get-date
$userFriendlyName = #The person's first name
$currentBalance = #How much time this person has in the bank in minutes
}

$timeSpan = New-TimeSpan -Minutes $currentBalance #Convert their balance into a time object
$totalTime = $loginTime + $timeSpan #Find the time that with their total balance they would have to log off by adding the time span to the time they logged in

if (get-date -gt $totalTime) { #You outta time, gtfo
#update database to set time available to 0 ignoring initial value of possibly -1
#Ian make a sql call to set the user banace to 0 this has to be before the logoff statement
#UPDATE TimeBalances SET balance = 0 WHERE username = $currentUser;
$str = "logoff"
Invoke-Expression $str


}
else if ($totalTime -lt 5) {
#Give a warning
$remainingTime = $currentBalance

$wshell = New-Object -ComObject Wscript.Shell

$wshell.Popup("You have $currentBalance minutes remaining.",0,"Done",0x1)

#subtract 1 from the users balance
$newBalance = $currentBalance - 1
#UPDATE TimeBalances SET balance = $newBalance WHERE username = $currentUser;
}
else {
#Have fun!
}
