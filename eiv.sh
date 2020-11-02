#!/bin/bash

: '
Emt-Dublin
@amijaljevic
October 2020
';

#Colors
BLUE='\033[0;34m';
RED='\033[0;31m';
YELLOW='\033[0;33m';
GREEN='\033[1;32m';
BGGREEN='\033[42m';
BOLD='\033[1;37m';
NOCOLOR='\033[0m';

# Wifi availability
netCon=$(ifconfig | sed -n '/en0/,/active/p' | sed -n '/status/p' | cut -c10-18);

function conCheck() {
    while [ $netCon == 'inactive' ]; do
        echo -e '\0033\0143';
        read -p "$(echo -e ${RED}Not connected to the network! Connect to WiFi and press any key to continue ...${NOCOLOR})";
        netCon=$(ifconfig | sed -n '/en0/,/active/p' | sed -n '/status/p' | cut -c10-18);
    done
}

conCheck;

#Commands
cVersion=$(sw_vers | sed -n '/ProductVersion/p' | tail -c 8);
hostN=$(hostname);
serialN=$(ioreg -l | grep IOPlatformSerialNumber | tail -c 15 | tr "\"", " ");
ethMac=$(ifconfig | sed -n '/en0/,/status/p' | sed -n '/ether/p' | cut -c8-24);

# Clear screen & Welcome screen
echo -e '\0033\0143';
echo -e "
${BLUE}*****************************************************************
 #####                                        ####### ### #     # 
#     #  ####   ####   ####  #      ######    #        #  #     #${NOCOLOR}
${RED}#       #    # #    # #    # #      #         #        #  #     # 
#  #### #    # #    # #      #      #####     #####    #  #     #${NOCOLOR}
${YELLOW}#     # #    # #    # #  ### #      #         #        #   #   #  
#     # #    # #    # #    # #      #         #        #    # #${NOCOLOR}
 ${GREEN}#####   ####   ####   ####  ###### ######    ####### ###    #  
******************** EMT Dublin | Stable ver 0.1 **********************${NOCOLOR}
";

# Printing machine info: product version, current date, hostname, serial number, wireless MAC address
echo -e "\n${BOLD}1| MACHINE INFORMATIONS${NOCOLOR}\n";
echo -e "${RED}MacOS version${NOCOLOR}: $cVersion";
echo -e "${RED}Current date & time${NOCOLOR}: ${UBLACK}$(date)${NOCOLOR}";
echo -e "${RED}Hostname${NOCOLOR}: $hostN (default RM)"; #get real hostname?
echo -e "${RED}Serial number${NOCOLOR}:$serialN";
echo -e "${RED}Wireless MAC${NOCOLOR}: $ethMac";
echo -e "${RED}Network connection${NOCOLOR}: $netCon";

# Local Date & Time check & Syncing with NTP Apple server
echo -e "\n${BOLD}2| DATE & TIME SYNC${NOCOLOR}\n";

timeCheck=0;
count=1;

while [ $timeCheck == 0 ];do
	sntp -sS time.google.com &> /dev/null || sntp -sS time.apple.com &> /dev/null;
    if [[ $? > 0 && $count < 4 ]];then
        echo -e "Syncing NTP Apple server with local machine date & time ATTEMPT: $count... ${RED}FAILED${NOCOLOR}";
        sleep 2;
        count=$((count+1));
    elif [[ $? > 0 && $count == 4 ]];then
        timeCheck=1;
        echo -e "\n>${RED} NTP not available${NOCOLOR}";
        echo -e "> ${RED}Program terminated\n${NOCOLOR}";
        exit 1
    else
        timeCheck=1;
        echo -e "Syncing NTP Apple server with local machine Date & Time ... ${GREEN}SYNCED${NOCOLOR}";
        echo -e "Updated Date & Time: ${BGGREEN}$(date)${NOCOLOR}";
    fi
done



# MAC address check up
echo -e "\n${BOLD}3| MAC ADDRESS CHECK${NOCOLOR}\n";
echo -e "Please verify device wireless MAC address >> ${BGGREEN}$ethMac${NOCOLOR}";

# Product version check
echo -e "\n${BOLD}4| MACOS VERSION CHECK${NOCOLOR}\n";
verVer=$(sw_vers | sed -n '/ProductVersion/p' | cut -c20-21);

if (( $verVer >= 15 )); then
    hdiutil attach https://tieclip.corp.google.com/eiv.dmg &> /dev/null;
    echo -e "Verifying OS version ... ${GREEN}VERSION SUPPORTED${NOCOLOR}\n";
    read -p "$(echo -e Press any key to initiate ${RED}EIV process${NOCOLOR} ...)";
else
    echo -e "Verifying OS version$ ... ${RED}VERSION NOT SUPPORTED, SECOND BOOT TO INTERNET RM NEEDED\n${NOCOLOR}";
    read -p "Press any key to reboot machine ...\n";
        echo -e "{RED}HOLD CMD + OPTION + R${NOCOLOR}";
    sleep 3;
    nvram internet-recovery-mode=RecoveryModeNetwork && reboot
    exit 0;
fi

# Running EIV Command
echo -e "\n${BOLD}5| RUNNING EIV${NOCOLOR}\n";
echo -e "Running EIV ... ${GREEN}EXECUTED${NOCOLOR}";
/Volumes/eiv/Eiv.app/Contents/MacOS/Eiv;