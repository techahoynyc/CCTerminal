#!/bin/bash
source /etc/default/ccterminal.conf
export $PGPASSWORD
ccuser="$1"
gear="$2"
echo $ccuser
echo $gear
echo "testing"
function verifyUser(){ userFound=$(psql -h $GHOST -U $GUSER -d $GTABLE -t -c "SELECT count(username) from users WHERE username='$1'");}
function awardGear(){
  result=$(psql -h $GHOST -U $GUSER -d $GTABLE -t -c "UPDATE users SET gear = gear + $2 WHERE username = '$1'");
}

verifyUser $ccuser
if ((!"$userFound")); then
  echo "Error: User not found"
  return 0;
fi
awardGear $ccuser $gear
echo $ccuser" has been awarded "$gear"g"
