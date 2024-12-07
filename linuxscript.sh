#!/bin/bash

creating_users () {
	echo What is the username
	read username
	sudo adduser "$username"
	sudo passwd "$username"

}


deleting_users () {
	awk -F: '($3>=1000)&&($3<60000)&&($1!="nobody"){print $1}' /etc/passwd
	echo What is the username
	read username
	sudo deluser  "$username"
}


deleting_apps () {
	echo deleting apps
}
installing_apps () {
	if dpkg -l | grep -i "wget" &> /dev/null
	then
		echo "wget is installed"
	else
		sudo apt install wget
	fi
	echo "Enter the installation link of the application to add"
	echo "Search exmaple: Linux Latest app_name Install"
	echo "Link Example: https://d1.google.com/linux/direct/google-chrome-stable_current_amd64.deb)"
	read -p "Enter Link: " app_link

	sudo wget "$app_link"
	echo "Application has been added sucessfully."

}
default_security () {
	sudo apt install libpam-pwquality -y
	sudo sed -i 's/password requisite pam_pwquality.so retry=3/password requisite pam_pwquality.so retry=3 minlen=14 difok=3 ucredit=-1 lcredit=-1 dcredit=-1 ocredit=-1/' /etc/pam.d/common-password	
	sudo sed -i "s/^PASS_MAX_DAYS.*/PASS_MAX_DAYS 90/"/etc/login.defs
	sudo sed -i "s/^PASS_MIN_DAYS.*/PASS_MIN_DAYS 7/" /etc/login.defs
	sudo sed -i "s/PASS_WARN_AGE.*/PASS_WARN_AGE 7/" /etc/login.defs
	sudo sed -i "s/PASS_MIN_LEN.*/PASS_MIN_LEN 14/" /etc/login.defs
}
firewall () {
	echo "enable or disable"
	read wall
	sudo apt-get install ufw
	sudo ufw default deny incoming
	sudo ufw default allow outgoing
	sudo ufw logging on
	sudo ufw logging high

	if [[ $wall == "enable" ]] 
	then
		sudo ufw enable
	else
		sudo ufw disable

	fi
	sudo ufw status
}
check_files () {
	echo check what files	
}
change_userpwd () {
	new_password = "!@#Cyb3rP@tri0t15@#"
	users = $(cat /etc/passwd | cut -d ":" -f1)
	for user in $users
	do
		echo "Changed Password for user $user"
	done
}
change_perms () {
	echo "Do you want to make someone adminstrator or not (y/n)"
	read yes_no
	if [[ $yes_no == y ]] 
	then
		echo "Who"
		read $username
		sudo adduser $username sudo

	else
		echo "Who"
		read $username
		sudo deluser $username sudo
	fi	
}
while :
do
	echo What would you like to do?
	echo "1. Create User (Done)" 
	echo "2. Delete User (Done)"
	echo "3. Delete Apps (Not Done)"
	echo "4. Install Apps (Not done)"
	echo "5. Set Security (Not done)"
	echo "6. Enable / Disable Firewall (Not done )"
	echo "7. Check Files (Not Done)"
	echo "8. Change passwords (Needs Testing)"
	echo "9. Change perms (Needs Testing)"
	echo "exit"
	echo "Enter a choice:"
	read number
	
	if [[ $number == 1 ]]
	then
		creating_users



	elif [[ $number == 2 ]]
	then
		deleting_users

	
	elif [[ $number == 3 ]]
	then
		deleting_apps


	elif [[ $number == 4 ]]
	then
		installing_apps


	elif [[ $number == 5 ]]
	then
		default_security


	elif [[ $number == 6 ]]
	then
		firewall        


	elif [[ $number == 7 ]]
	then
		check_file


	elif [[ $number == 8 ]]
	then
		change_userpwd 


	elif [[ $number == 9 ]] 
	then
		change_perms      


	elif [[ $number = exit ]]
	then 
		break
	else 
		echo "Invalid"
	fi
done
