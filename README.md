# CCTerminal
A terminal based menu system for [code:Cadet](https://techahoy.org/code-cadet) students

## Description
CCTerminal was designed to encourage code:Cadet students to interact with the command line interface.  
Students can perform a number of tasks such as:  
- Check their TechAhoy Coin (gear) balance  
- Transfer gear to fellow students
- Complete daily challenges that involve coding, puzzles, and general problem solving

## Requirements
- RasperryPi or other Linux based OS
- [PostgreSQL](https://en.wikipedia.org/wiki/PostgreSQL) database  
- A configuration file, **ccterminal.conf** saved in **/etc/default/** with the following format:  
  ```
  #!/bin/bash
  PGPASSWD=<psql password>
  GUSER=<psql user>
  GHOST=<psql host>
  GTABLE=<table>
  ```

## Installation
1. Copy the repository with the following command `git clone https://github.com/techahoynyc/CCTerminal`
