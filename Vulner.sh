#!/bin/bash

# Projectname and creator:
# Cyber-Security project nr 4: PENETRATION TESTING | PROJECT: VULNER
# Creator of the project: Hadroxx


# Start of project

# Define color variables
RED='\e[31m'
GREEN='\e[32m'
YELLOW='\e[33m'
BLUE='\e[34m'
WHITE='\e[37m'
RESET='\e[0m'


function BOOT()
{	
# Switch to Norwegian keyboard layout (this can be removed if you have an English keyboard-layout, or changed if you have other keyboard-layouts)
setxkbmap no
echo "[*] Switched to Norwegian keyboard layout."
sleep 1
echo

# Loop to ask if the user has updated Kali
while true; do
    read -p "[*] Have you updated Kali today? (y/n): " ANSWER
    if [[ "$ANSWER" == "Y" || "$ANSWER" == "y" ]]
    then
        echo
        echo -e "${GREEN}[*] KALI updated.${RESET} Continuing with the script"
        break  # Exit the loop and continue with the script
    elif [[ "$ANSWER" == "N" || "$ANSWER" == "n" ]]
    then
    echo
    echo -e "${RED}[*] KALI not updated${RESET}. Updating KALI, this will take some time..."
        sudo apt-get update -y >/dev/null 2>&1
    echo -e "${GREEN}KALI updated!${RESET}"
        break  # Exit the loop after updating
    fi
done
echo
sleep 2
}


function INPUT()
{
# Asking the user for input and saving it into a variable
get_user_input() {
    echo "[*] To run this script, please input the following:"
    echo
    sleep 1
      # Loop until a valid network range is provided.
      while true
      do
      read -p "[*] Enter the desired network-range to scan (example: 8.8.8.8/24): " NETWORK
      echo
      
      # Validating the network range with nmap
      nmap $NETWORK -sL 2>./ValidNetwork.txt 1>./NetworkScan.txt
      
      # Checking to see if "failed to resolve" is in the output
      if grep -i "failed to resolve" ./ValidNetwork.txt # The file needed to be "grepped" is the ValidNetwork.txt because in here lies the error-messages (the 2> output)
      then
      echo "[!] Network-range is invalid. Please input the correct network-range."
      echo
      else
      echo "[*] Network-range is valid. Continuing the script..."
      break # Exit the loop and continue the script
      fi
      done

    echo
    sleep 1
    read -p "[*] Enter the desired name for the output directory: " DIRECTORY
    echo
    sleep 1
    read -p "[*] If you want a full scan type full, if you want a basic scan type basic: " ANSWER
    echo
    sleep 1
}

# Loop until the user confirms the input is correct.
while true
do
    get_user_input
    
    # 1.4 Make sure the input is valid.
    echo
    echo
    echo "[*] Desired network-range specified: $NETWORK"
    echo
    echo "[*] Desired output directory name: $DIRECTORY"
    echo
    echo "[*] Desired type of scan: $ANSWER"
    echo
    read -p "[*] Is the input correct? (y/n): " INPUT
    echo
    
    # Check if the user confirmed the input
    if [[ "$INPUT" == "Y" || "$INPUT" == "y" ]]
    then
        echo
        echo "[*] Continuing with the script."
        echo
        break  # Exit the loop and continue the script
    else
        echo
        echo "[!] Input incorrect, please re-enter the information."
        echo
    fi
done



echo "[*] Now creating the output directory $DIRECTORY, sub-directories (FULL, BASIC and so on) will be made depending on the scan chosen: "
mkdir ./$DIRECTORY
chmod 777 ./$DIRECTORY # The reason I do chmod 777 here is simply to avoid possible issues regarding permissions later on.
# Here I'm just moving the .txt files into the newly created directory, so everything is in the same place at the end.
mv ./ValidNetwork.txt ./NetworkScan.txt ./$DIRECTORY
echo




read -p "Do you wish to supply your own password list?(y/n) " REPLY
if [[ $REPLY = Y || $REPLY = y ]]
then
while true
do
read -p "Input the path to your file (example: /home/kali/Desktop/FILE)" PASSLIST
if [[ -f $PASSLIST ]]
then
echo -e "${GREEN}[*] Password list set to: $PASSLIST${RESET}"
break
	else
	echo -e "${RED}[!] File not found. Please input a valid file path.${RESET}"
	fi
	done
else
	# Here I generate passwords using crunch, then throwing it into its directory and moving it to $DIRECTORY
	echo
	echo "Now generating the weak passwords password-list with crunch, then moving it into PASSWORDS and then into $DIRECTORY. The generated output will not be displayed on screen to not have a lot of clutter, and this will take time."
	mkdir ./PASSWORDS
	chmod 777 ./PASSWORDS # Here I simply give it full permissions for ease of use, so it won't argue about being moved.
	mv ./PASSWORDS ./$DIRECTORY
	# I had to minimize the size of the generated passwords, otherwise it would take forever and create gigantic files. As a result of this I had to "set msf as fixed" and only randomize the last 5 characters
	# In reality, where we don't know the username/password the result might be that we generate 1TB or 1PB sizes of files for this purpose. But for the project it would just take too long.
	crunch 8 8 "abcdefghijklmnopqrstuvwxyz" -t msf@@@@@ | tee ./$DIRECTORY/PASSWORDS/PASSWORDS.TXT > /dev/null #I redirect the output to dev/null otherwise it would fill the screen for ages
	echo "The generated passwords-list can be found in the directory: ./$DIRECTORY/PASSWORDS/PASSWORDS.TXT"
	echo
	sleep 1
	echo -e "${YELLOW}[*] No custom password list supplied. Using the ./$DIRECTORY/PASSWORDS/PASSWORDS.TXT${RESET}"
    PASSLIST="./$DIRECTORY/PASSWORDS/PASSWORDS.TXT"  #The crunched password-list
    echo
fi



# I also made a built-in Usernamelist to check for login-credentials to use with whichever tool needs it (Hydra, Medusa and so on)
read -p "Do you wish to supply your own username list?(y/n) " RESPONSE
if [[ $RESPONSE = Y || $RESPONSE = y ]]
then
while true
do
read -p "Input the path to your file (example: /home/kali/Desktop/FILE)" USERLIST
if [[ -f $USERLIST ]]
then
echo -e "${GREEN}[*] Username list set to: $USERLIST${RESET}"
break
	else
	echo -e "${RED}[!] File not found. Please input a valid file path.${RESET}"
	fi
	done
else
	# Here I simply create a directory for the usernamelist and then I generate a usernamelist using crunch, using the same function as for the pass-list
	echo
	echo "Now generating the logincredentials username-list with crunch, then moving it into USERNAMES and then into $DIRECTORY. The generated output will not be displayed on screen to not have a lot of clutter, and this will take time."
	mkdir ./USERNAMES
	chmod 777 ./USERNAMES # Here I also simply give it full permissions for ease of use, so it won't argue about being moved.
	mv ./USERNAMES ./$DIRECTORY
	# As with the password generation I had to minimize the size of the generated usernames, otherwise it would take forever and create gigantic files. As a result of this I had to "set msf as fixed" and only randomize the last 5 characters
	# In reality, where we don't know the username/password the result might be that we generate 1TB or 1PB sizes of files for this purpose. But for the project it would just take too long.
	crunch 8 8 "abcdefghijklmnopqrstuvwxyz" -t msf@@@@@ | tee ./$DIRECTORY/USERNAMES/USERS.TXT > /dev/null #I redirect the output to dev/null otherwise it would fill the screen for ages
	echo "Generated usernames-list can be found in the directory: ./$DIRECTORY/USERNAMES/USERS.TXT"
	echo
	sleep 1
	echo -e "${YELLOW}[*] No custom username-list supplied. Using the ./$DIRECTORY/USERNAMES/USERS.TXT${RESET}"
    USERLIST="./$DIRECTORY/USERNAMES/USERS.TXT"  #The pre-made userlist generated with crunch
fi

}


function SCANNING()
{
if [[ "$ANSWER" = "basic" || "$ANSWER" = "BASIC" ]]
then
echo
echo "[*] Creating the Basic-scan sub-directories"
mkdir -p ./$ANSWER/TCP_SCAN
mkdir -p ./$ANSWER/UDP_SCAN
chmod 777 ./$ANSWER/TCP_SCAN ./$ANSWER/UDP_SCAN # Here I do chmod 777 to not have any issues with moving directories, as it can happen, and since it is on "our machine" it's safe to give full permissions
mv ./$ANSWER ./$DIRECTORY
echo



# Basic: scans the network for TCP and UDP, including the service version and weak passwords.
echo "[*] Initiating a basic scan: scans the network for TCP and UDP, including the service version on the given network-range $NETWORK, this may take some time..."
# Here the command is running both TCP and UDP, TCP first and then UDP, which will take some time unfortunately, since it scans all the 65535 available ports on both the scans.
echo
echo "[!] Initiating open-port scan on the given network-range to see which hosts are up and open. Output located in the directory ./$DIRECTORY/$ANSWER/OPENPORT_output.txt"
# To avoid too much clutter/output on the terminal-screen I chose to send the output to dev/null.
# Here I'm excluding my own physical machines IP's as I don't want/need to include them in my nmap-scans
nmap $NETWORK -p- --open 2>/dev/null | tee ./$DIRECTORY/$ANSWER/OPENPORT_output.txt > /dev/null
echo "[*] Open-port scan complete. Now showing the found IP-addresses:"
echo
echo "[*] Locating IP-addresses from within the OPENPORT_output.txt file, and saving them into ./$DIRECTORY/$ANSWER/IPS.txt"
grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' ./$DIRECTORY/$ANSWER/OPENPORT_output.txt | tee ./$DIRECTORY/$ANSWER/IPS.txt #The command for IP-addresses is not one I remember by heart, so I just got it from ChatGPT
echo
echo "[!] Now running nmap for TCP, this takes time. Results will be shown on the terminal and saved into their respective sub-directories" #Throws the output into a file as well and save it in the created directory




# Looping through the IP-addresses from the IPS.txt to use in the TCP/UDP-scans.
IPS=$(grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' ./$DIRECTORY/$ANSWER/IPS.txt)


# Loop through each IP and run nmap, then save the output into separate files
for i in $IPS
do
    nmap $i -sS -sV -p- | tee ./$DIRECTORY/$ANSWER/TCP_SCAN/${i}_TCP_output.txt
done
echo
echo "[*] Nmap for TCP complete"
echo
echo "[!] Now running Masscan for UDP, this takes time. Results will be shown on the terminal and saved into their respective sub-directories" #Throws the output into a file as well and save it in the created directory
# Looping through the IP-addresses from the PING_output.txt to use in the TCP/UDP-scans.
# Loop through each IP and run nmap, then save the output into separate files
echo
for i in $IPS
do
    masscan $i -pU:0-65535 --rate=10000 | tee ./$DIRECTORY/$ANSWER/UDP_SCAN/${i}_UDP_output.txt
done
echo "[*] Masscan for UDP complete"
echo



#2 Weak Credentials
# Here I make the directories for the weak credentials and move it into $DIRECTORY
mkdir ./CREDS
chmod 777 ./CREDS
mv ./CREDS ./$DIRECTORY/$ANSWER
#2.1 Look for weak passwords used in the network for login services and #2.2 Login services to check include: SSH, RDP, FTP, and TELNET.

IPS=$(grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' ./$DIRECTORY/$ANSWER/IPS.txt)


# Loop through each IP and look for weak passwords, then save the output into separate files
# I use the tools HYDRA, MEDUSA and Nmap-scripts (NSE)??
for i in $IPS
do
echo "[!] Brute-force attack initiating, this will take some time..."
echo
echo
#nmap -sV $IP --script=brute | tee ./$DIRECTORY/$ANSWER/CREDS/$i_bruteforce.txt
hydra -L $USERLIST -P $PASSLIST $i ftp | tee ./$DIRECTORY/$ANSWER/CREDS/${i}_FTP_CREDS_output.txt
echo
hydra -L $USERLIST -P $PASSLIST $i telnet | tee ./$DIRECTORY/$ANSWER/CREDS/${i}_telnet_CREDS_output.txt
echo
hydra -L $USERLIST -P $PASSLIST $i rdp | tee ./$DIRECTORY/$ANSWER/CREDS/${i}_RDP_CREDS_output.txt
echo
echo
echo "[*] Brute-force attack completed, now showing the files: "
echo
echo
done

# For-loop that shows the files in the CREDS directory after the bruteforce-attack is done.
for file in ./$DIRECTORY/$ANSWER/CREDS/*
	do
    if [[ -f $file ]]; then
        cat "${GREEN}$file${RESET}"
        echo
    fi
done




# I like to make it clear where one function/part/script begins and ends, and where the next one begins and ends.
# This is why theres a lot of empty room between functions, variables ets.

elif [[ "$ANSWER" = "full" || "$ANSWER" = "FULL" ]]
then
#1.3.2 Full: include Nmap Scripting Engine (NSE), weak passwords, and vulnerability analysis.
echo
echo "[*] Creating the FULL-scan sub-directories"
mkdir -p ./$ANSWER/TCP_SCAN
mkdir -p ./$ANSWER/UDP_SCAN
chmod 777 ./$ANSWER/TCP_SCAN ./$ANSWER/UDP_SCAN # Here I do chmod 777 to not have any issues with moving directories, as it can happen, and since it is on "our machine" it's safe to give full permissions
mv ./$ANSWER ./$DIRECTORY
echo


# 1.3.2 Full: include Nmap Scripting Engine (NSE), weak passwords, and vulnerability analysis
echo "[*] Initiating a full scan: scans the network for TCP and UDP, including the service version on the given network-range $NETWORK, this may take some time..."
# Here the command is running both TCP and UDP, TCP first and then UDP, which will take some time unfortunately, since it scans all the 65535 available ports on both the scans.
echo


echo "[!] Initiating NMAP open-port scan on the given network-range to see which hosts are up and open. Output located in the directory ./$DIRECTORY/$ANSWER/OPENPORT_output.txt"
# To avoid too much clutter/output on the terminal-screen I chose to send the output to dev/null.
nmap $NETWORK -p- --open 2>/dev/null | tee ./$DIRECTORY/$ANSWER/OPENPORT_output.txt > /dev/null
echo "[*] Open-port scan complete. Now showing the found IP-addresses:"
echo


echo "[*] Locating IP-addresses from within the OPENPORT_output.txt file, and saving them into ./$DIRECTORY/$ANSWER/IPS.txt"
grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' ./$DIRECTORY/$ANSWER/OPENPORT_output.txt | tee ./$DIRECTORY/$ANSWER/IPS.txt #The command for IP-addresses is not one I remember by heart, so I just got it from ChatGPT
echo
echo "[!] Now running NMAP for TCP, this takes time. Results will be shown on the terminal and saved into their respective sub-directories" #Throws the output into a file as well and save it in the created directory

# Looping through the IP-addresses from the IPS.txt to use in the TCP/UDP-scans.
IPS=$(grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' ./$DIRECTORY/$ANSWER/IPS.txt)

# Loop through each IP and run nmap, then save the output into separate files
for i in $IPS
do
    nmap $i -sS -sV -p- | tee ./$DIRECTORY/$ANSWER/TCP_SCAN/${i}_TCP_output.txt
done
echo
echo


echo "[!] Now running Masscan for UDP, this takes time. Results will be shown on the terminal and saved into their respective sub-directories" #Throws the output into a file as well and save it in the created directory
# Looping through the IP-addresses from the PING_output.txt to use in the TCP/UDP-scans.
# Loop through each IP and run nmap, then save the output into separate files
echo
for i in $IPS
do
    masscan $i -pU:0-65535 --rate=10000 | tee ./$DIRECTORY/$ANSWER/UDP_SCAN/${i}_UDP_output.txt
done
echo




#2 Weak Credentials
# Here I make the directories for the weak credentials and move it into $DIRECTORY
mkdir ./CREDS
chmod 777 ./CREDS
mv ./CREDS ./$DIRECTORY/$ANSWER
#2.1 Look for weak passwords used in the network for login services and #2.2 Login services to check include: SSH, RDP, FTP, and TELNET.

IPS=$(grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' ./$DIRECTORY/$ANSWER/IPS.txt)


# Loop through each IP and look for weak passwords, then save the output into separate files
# I use the tools HYDRA, MEDUSA and Nmap-scripts (NSE)??
for i in $IPS
do
echo -e "${YELLOW}[!] Brute-force attacks initiating, this will take some time.${RESET}"
echo
echo
echo -e "${RED}[!] FTP-bruteforce starting${RESET}"
echo
hydra -L $USERLIST -P $PASSLIST $i ftp | tee ./$DIRECTORY/$ANSWER/CREDS/${i}_FTP_CREDS_output.txt
echo
echo -e "${GREEN}[*] FTP-bruteforce complete${RESET}"
echo
echo -e "${RED}[!] TELNET-bruteforce starting${RESET}"
echo
hydra -L $USERLIST -P $PASSLIST $i telnet | tee ./$DIRECTORY/$ANSWER/CREDS/${i}_telnet_CREDS_output.txt
echo
echo -e "${GREEN}[*] TELNET-bruteforce complete${RESET}"
echo
echo -e "${RED}[!] RDP-bruteforce starting${RESET}"
hydra -L $USERLIST -P $PASSLIST $i rdp | tee ./$DIRECTORY/$ANSWER/CREDS/${i}_RDP_CREDS_output.txt
echo
echo -e "${GREEN}[*] RDP-bruteforce complete${RESET}"
echo
echo -e "${RED}[!] SSH-bruteforce starting${RESET}"
hydra -L $USERLIST -P $PASSLIST $i ssh | tee ./$DIRECTORY/$ANSWER/CREDS/${i}_SSH_CREDS_output.txt
echo
echo -e "${GREEN}[*] SSH-bruteforce complete${RESET}"
echo
echo "[*] All Brute-force attacks completed, now showing the files:"
echo
echo
done

# For-loop that shows the files in the CREDS directory after the bruteforce-attack is done.
for file in ./$DIRECTORY/$ANSWER/CREDS/*
	do
    if [[ -f $file ]]; then
       echo -e "${GREEN}$file${RESET}" && cat "$file"
        echo
    fi
done


#3 Mapping Vulnerabilities
for i in $IPS
do
nmap -sV $IPS --script=vulners.nse -oN VULNERABILITIES.txt > /dev/null 2>&1
done
mv VULNERABILITIES.txt ./$DIRECTORY/$ANSWER/CREDS
echo
echo
echo "[*] The Vulnerabilities file can be found in: ./$DIRECTORY/$ANSWER/CREDS/VULNERABILITIES.txt. It will not be shown in the terminal because there's a lot of output."

#This is a loop in case the variabel the user inputs isn't any of the possible options (basic or full), and then the script wont run.
elif [[ "$ANSWER" != "basic" && "$ANSWER" != "BASIC" && "$ANSWER" != "full" && "$ANSWER" != "FULL" ]] 
then
echo "[!] You haven't chosen basic or full, please chose one of them"
break
fi
}




function LOGS()
{
#4.0 Log Results
#4.1 During each stage, display the stage in the terminal.
#4.2 At the end, show the user the found information.
echo "Showing all the saved output now: Contents of $DIRECTORY"
echo
ls ./$DIRECTORY/*
echo
#4.3 Allow the user to search inside the results.
echo "All the results are saved into $DIRECTORY. If you wish to search through the results you can do so there, inside the $DIRECTORY as shown above."
echo
echo


#4.4 Allow to save all results into a Zip file.
read -p "[*] Do you wish to save all the results into a zip-file? (y/n): " ZIPCHOICE
if [[ $ZIPCHOICE = Y || $ZIPCHOICE = y ]]
then
echo
echo "[*] Zipping the results into Zipped_$DIRECTORY.zip"
zip -r ./Zipped_$DIRECTORY.zip $DIRECTORY
echo
echo "Zipped_$DIRECTORY.zip is ready"
else
echo
echo "[!] You chose not to zip the results"
fi
}





echo -e "${YELLOW}[*]--------------------START OF PROJECT--------------------[*]${RESET}"
echo
echo
echo -e "${YELLOW}[*]--------------------Function 1: BOOT--------------------[*]${RESET}"
echo
BOOT
echo
echo -e "${YELLOW}[*]--------------------Function 2: INPUT--------------------[*]${RESET}"
echo
INPUT
echo
echo -e "${YELLOW}[*]--------------------Function 3: SCANNING/VULNERABILITIES--------------------[*]${RESET}"
echo
SCANNING
echo
echo -e "${YELLOW}[*]--------------------Function 4: LOG-RESULTS/ZIPPING--------------------[*]${RESET}"
echo
LOGS
echo
echo
echo -e "${YELLOW}[*]--------------------END OF PROJECT--------------------[*]${RESET}"

# End of project
