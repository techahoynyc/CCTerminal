#!/bin/bash
source /etc/default/ccterminal.conf
export PGPASSWORD=$PGPASSWD
function getBalance(){ gear=$(psql -h $GHOST -U $GUSER -d $GTABLE -t -c "SELECT gear FROM users WHERE username='$1'");}
function getUsers(){ users=$(psql -h $GHOST -U $GUSER -d $GTABLE -t -c "SELECT username FROM users");}
function transferGear(){
  result=$(psql -h $GHOST -U $GUSER -d $GTABLE -t -c "UPDATE users SET gear = gear - $2 WHERE username = '$3'");
  result=$(psql -h $GHOST -U $GUSER -d $GTABLE -t -c "UPDATE users SET gear = gear + $2 WHERE username = '$1'");
}
function verifyUser(){ userFound=$(psql -h $GHOST -U $GUSER -d $GTABLE -t -c "SELECT count(username) from users WHERE username='$1'");}
function checkLastGear(){
  lastChecked=$(psql -h $GHOST -U $GUSER -d $GTABLE -t -c "SELECT lastfreegear from users WHERE username = '$1'");
}
function awardFreeGear(){
  result=$(psql -h $GHOST -U $GUSER -d $GTABLE -t -c "UPDATE users SET gear = gear + $2,lastfreegear = '$3' WHERE username = '$1'");
}

today=`date +%Y-%m-%d`
function printC(){
  content=$1
  col=$(tput cols)
  printf "%*s\n" $(((${#content}+$col)/2)) "$content"
}

function printP(){
  content=$1
  col=$(tput cols)
  printf "%*s" $(((${#content}+$col)/2)) "$content"
}

function logo(){
printC "  __                       .__              .__   "
printC "_/  |_  ___________  _____ |__| ____ _____  |  |  "
printC "\   __\/ __ \_  __ \/     \|  |/    \\__  \ |  |  "
printC " |  | \  ___/|  | \/  Y Y  \  |   |  \/ __ \|  |__"
printC " |__|  \___  >__|  |__|_|  /__|___|  (____  /____/"
printC "           \/            \/        \/     \/      "
}

function displayHeader(){
  clear
  columns=31
  tput cup 5
  #echo "   ***      TERMINAL      **   "
  logo
  #figlet "terminal"
  #printC "this is a test"
  printC ""
  printC "          TechAhoy Inc         "
  printC "         Ridgewood, NY         "
  printC
  printC "   ***                    ***  "
  printC ""
  printC "-------------------------------"
  #printf "%*s\n" $(((${#1}+$columns)/2)) "$1"
  printC "$1"
  printC "-------------------------------"
  printC ""
}

function displayFooter(){
  printC "-------------------------------"
  printP "Press any key to check your current balance..."
  read -n 1 
}

function displayAlert(){
  columns=31
  #printf "%*s\n" $(((${#1}+$columns)/2)) "$1"
  printC "$1"
  printC ""
}

function displayHelp(){
  displayHeader "HELP"
  printC "Options:                                          "
  printC "'1' -> Get your current gear balance              "
  printC "'2' -> Send gear to another user                  "
  printC "'3' -> Earn gear by completing the daily challenge"
  printC "'h' -> Display this menu                          "
  printC "'x' -> Quit the terminal                          "
  printC ""
  printP "Press any key to retun to the main menu..."
  read -n 1
  return 0;
}

function displayMenu(){
  until [ "$ans" = "x"]; do
    displayHeader "MENU"
    printC " 1. Check gear balance"
    printC " 2. Send gear         "
    printC " 3. Daily Challenge   "
    printC ""
    tput setaf 3
    printC " $. ** FREE GEAR **   "
    tput sgr0
    printC ""
    printP "Please enter your choice (h for help):"; read -n 1 ans;
    case $ans in
      1) clear; displayBalance ;;
      2) clear; sendGear ;;
      3) clear; dailyChallenge ;;
      $) clear; freeGearCheck ;;
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
    printP "Available Balance:";tput setaf 3;echo $gear"g";tput sgr0
    printC
    printC "List of users available:"
    for u in $users; do
      printC $u
    done
    printC
    printP "Do you want to send gear? (y/n)"
    read -n 1 sgInit
    if [ "$sgInit" = "n" ]; then
      return 0;
    fi
  done
  printC ""
  printP "Enter the username to whom you want to send gear:"
  read sgUser;
  printP "Enter the amount of gear to send:                ";tput cub 16
  read sgGear;
  verifyUser $sgUser
  if (("$sgGear" > "$gear")); then
    displayHeader "SEND GEAR - ERROR!"
    #displayAlert "*** SEND GEAR - ERROR ***"
    printC " You do not have enough gear."
    printP " You tried to send "$sgGear"g, but you only have";echo $gear"g!"
    printC ""
    printP "Press any key to return to the main menu..."
    read -n 1
    return 0;
  fi
  if ((!"$userFound")); then
    displayHeader "SEND GEAR - ERROR!"
    #displayAlert "*** ERROR ***"
    printC " The user $sgUser does not exist!"
    printC ""
    printP "Press any key to return to the main menu..."
    read -n 1
    return 0;
  fi
  until [ "$sgConfirm" = "y" ];do
    displayHeader "SEND GEAR - CAUTION!"
    #displayAlert "*** CAUTION ***"
    printP "You are about to send ";tput setaf 3;echo $sgGear"g";tput sgr0
    printC "to "$sgUser"!"
    printC ""
    printP "Press 'y' to confirm or 'a' to abort:"
    read -n 1 sgConfirm;
    if [ "$sgConfirm" = "a" ]; then
      return 0;
    fi
  done

  transferGear $sgUser $sgGear $USER
  #sendGearNow
}

function displayBalance(){
  getBalance $USER
  displayHeader "GEAR BALANCE"
  printC "$today"
  printC ""
  printC "  User: $USER"
  printP "  Available Balance: ";tput setaf 3;echo $gear"g";tput sgr0;
  printC ""
  printC ""
  printC "  !!  Earn gear thru the    !!"
  printC "  !!  the Daily Challenge!  !!"
  printC ""
  printC "-------------------------------"
  printC ""
  printP "Press any key to return to the main menu..."
  read -n 1
  return 0;
}

function dailyChallenge(){
  displayHeader "DAILY CHALLENGE"
  printC "Instructions:                            "
  printC "Decode the following payload successfully"
  printC "and give the answer to an instructor.    "
  printC ""
  printP "Reward: "
  tput setaf 3
  echo "10g                                      ";tput sgr0
  printC ""
  printC "Payload:                                 "
  printC "Inaj rj ymj lifw!                        "
  printC ""
  printP "Press any key to return to the main menu..."
  read -n 1
  return 0;
}

function freeGear(){
  displayHeader "FREE GEAR"
  freeAmt=$((1 + RANDOM % 10))
  printC ""
  printC "$today"
  printC ""
  printP "Congrats you have earned "
  tput setaf 3;echo $freeAmt"g";tput sgr0
  printC ""
  printC "Login again tomorrow for more free gear!"
  printC ""
  awardFreeGear $USER $freeAmt $today
  printC "-------------------------------"
  printC "Press any key to check your current balance..."
  read -n 1
  displayBalance
}

function freeGearCheck(){
  checkLastGear $USER
  if [ -z $lastChecked ];then
    freeGear
  elif [ `date -d $lastChecked +%s` -lt `date -d $today +%s` ];then
    freeGear
  else
    displayHeader "FREE GEAR"
    printC "Last Checked: $lastChecked"
    printC ""
    printC "You already earned your free gear."
    printC "Try again tomorrow!"
    printC ""
    printC "-------------------------------"
    printC "Press any key to return to the main menu..."
    read -n 1
  fi
}

displayMenu
clear

