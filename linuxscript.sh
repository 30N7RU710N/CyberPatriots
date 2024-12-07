#!/bin/bash

creating_users () {
	awk -F: '($3>=1000)&&($3<60000)&&($1!="nobody"){print $1}' /etc/passwd	
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
	echo installing apps
}
default_security () {
	echo default security
}
firewall () {
	echo firewall enabled
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
		echo App name
	elif [[ $number == 4 ]]
	then
		echo App name
	elif [[ $number == 5 ]]
	then
		echo setting security policy
		echo done
	elif [[ $number == 6 ]]
	then
		firewall            
	elif [[ $number == 7 ]]
	then
		echo What files
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
