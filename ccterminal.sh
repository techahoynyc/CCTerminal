#!/bin/bash
source /etc/default/ccterminal.conf
export PGPASSWORD=$PGPASSWD
function getBalance(){ gear=$(psql -h $GHOST -U $GUSER -d $GTABLE -t -c "SELECT gear FROM users WHERE username='$1'");}
function getUsers(){ users=$(psql -h $GHOST -U $GUSER -d $GTABLE -t -c "SELECT username FROM users");}
function transferGear(){
  $(psql -h $GHOST -U $GUSER -d $GTABLE -t -c "UPDATE users SET gear = gear - $2 WHERE username = '$3'");
  $(psql -h $GHOST -U $GUSER -d $GTABLE -t -c "UPDATE users SET gear = gear + $2 WHERE username = '$1'");
}
function verifyUser(){ userFound=$(psql -h $GHOST -U $GUSER -d $GTABLE -t -c "SELECT count(username) from users WHERE username='$1'");}
function awardGear(){
  result=$(psql -h $GHOST -U $GUSER -d $GTABLE -t -c "UPDATE users SET gear = gear + $2 WHERE username = '$1'");
}


function logo(){
echo "  __                       .__              .__   "
echo "_/  |_  ___________  _____ |__| ____ _____  |  |  "
echo "\   __\/ __ \_  __ \/     \|  |/    \\__  \ |  |  "
echo " |  | \  ___/|  | \/  Y Y  \  |   |  \/ __ \|  |__"
echo " |__|  \___  >__|  |__|_|  /__|___|  (____  /____/"
echo "           \/            \/        \/     \/      "
}

function displayHeader(){
  clear
  columns=31
  echo
  #echo "   ***      TERMINAL      **   "
  #logo
  figlet "terminal"
  echo
  echo "          TechAhoy Inc         "
  echo "         Ridgewood, NY         "
  echo
  echo "   ***                    ***  "
  echo ""
  echo "-------------------------------"
  printf "%*s\n" $(((${#1}+$columns)/2)) "$1"
  echo "-------------------------------"
  echo ""
}

function displayFooter(){
  echo "-------------------------------"
  read -n 1 -p "Press any key to check your current balance..."

}

function displayAlert(){
  columns=31
  printf "%*s\n" $(((${#1}+$columns)/2)) "$1"
  echo ""
}

function displayHelp(){
  displayHeader "HELP"
  echo "Options:"
  echo "'1' -> Get your current gear balance"
  echo "'2' -> Send gear to another user"
  echo "'3' -> Earn gear by completing the daily challenge"
  echo "'h' -> Display this menu"
  echo "'x' -> Quit the terminal"
  echo ""
  read -n 1 -p "Press any key to retun to the main menu..."
  return 0;
}

function displayMenu(){
  until [ "$ans" = "x"]; do
    displayHeader "MENU"
    echo " 1. Check gear balance"
    echo " 2. Send gear"
    echo " 3. Daily Challenge"
    echo ""
    tput setaf 3; tput smso; echo " $. ** FREE GEAR **"; tput sgr0
    echo ""
    read -n 1 -p "Please enter your choice (h for help):" ans;
    case $ans in
      1) clear; displayBalance ;;
      2) clear; sendGear ;;
      3) clear; dailyChallenge ;;
      $) clear; freeGear ;;
      h|H) clear; displayHelp ;;
      x) clear; return 0 ;;
      *) clear ;;
    esac
  done
}

function sendGear(){
  getBalance $USER
  getUsers
  sgInit=0
  until [ "$sgInit" = "y" ];do
    displayHeader "SEND GEAR"
    echo -n " Available Balance:";tput setaf 3;echo $gear"g";tput sgr0
    echo
    echo " List of users available:"
    printf "%s\n" "$users"
    echo
    read -n 1 -p "Do you want to send gear? (y/n)" sgInit
    if [ "$sgInit" = "n" ]; then
      return 0;
    fi
  done
  echo
  read -p "Enter the username to whom you want to send gear:" sgUser;
  read -p "Enter the amount of gear to send:" sgGear;
  verifyUser $sgUser
  if (("$sgGear" > "$gear")); then
    tput cup 11 0
    tput ed
    displayAlert "*** ERROR ***"
    echo " You do not have enough gear."
    echo " You tried to send "$sgGear"g, but you only have"$gear"g!"
    echo ""
    read -n 1 -p "Press any key to return to the main menu..."
    return 0;
  fi
  if ((!"$userFound")); then
    tput cup 11 0
    tput ed
    displayAlert "*** ERROR ***"
    echo " The user "$sgUser" does not exist!"
    echo ""
    read -n 1 -p "Press any key to return to the main menu..."
    return 0;
  fi
  until [ "$sgConfirm" = "y" ];do
    tput cup 11 0
    tput ed
    displayAlert "*** CAUTION ***"
    echo -n 	" You are about to send ";tput setaf 3;echo $sgGear"g";tput srg0
    echo " to "$sgUser"!"
    echo
    read -n 1 -p "Press 'y' to confirm or 'a' to abort:" sgConfirm;
    if [ "$sgConfirm" = "a" ]; then
      return 0;
    fi
  done

  transferGear $sgUser $sgGear 'ganondorfcc'
  #sendGearNow
}

function displayBalance(){
  getBalance $USER
  displayHeader "GEAR BALANCE"
  echo "  "`date`
  echo ""
  echo -n "  User: ";tput setaf 2;echo $USER;tput sgr0;
  echo -n "  Available Balance: ";tput setaf 3;echo $gear"g";tput sgr0;
  echo ""
  echo ""
  echo "  !!  Earn gear thru the    !!"
  echo "  !!  the Daily Challenge!  !!"
  echo ""
  echo "-------------------------------"
  echo ""
  read -n 1 -p "Press any key to return to the main menu..."
  return 0;
}

function dailyChallenge(){
  displayHeader "DAILY CHALLENGE"
  echo "Instructions:"
  echo "Decode the following payload successfully and give the answer to an instructor."
  echo ""
  echo "Reward:"
  tput setaf 3;echo "10g";tput sgr0
  echo ""
  echo "Payload:"
  echo "Inaj rj ymj lifw!"
  echo ""
  read -n 1 -p "Press any key to return to the main menu..."
  return 0;
}

function freeGear(){
  displayHeader "FREE GEAR"
  freeAmt=$((1 + RANDOM % 10))
  echo "  "`date`
  echo ""
  echo -n "Congrats you have earned ";tput setaf 3;echo $freeAmt"g";tput sgr0
  echo ""
  echo "Login again tomorrow for more free gear!"
  echo ""
  awardGear $USER $freeAmt
  echo "-------------------------------"
  read -n 1 -p "Press any key to check your current balance..."
  displayBalance
}

displayMenu
clear
