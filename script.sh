#!/bin/bash

creating_users () {
	read "Enter the username: " username
	
	useradd -m "$username"

	passwd "$username"

}
deleting_users () {
	echo delete user
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
	echo changes whos password
}
change_perms () {
	echo changing perms
}
while :
do
	echo What would you like to do?
	echo 1. Create User
	echo 2. Delete User
	echo 3. Delete Apps
	echo 4. Install Apps
	echo 5. Set Security
	echo 6. Enable / Disable Firewall
	echo 7. Check Files
	echo 8. Change passwords
	echo 9. Change perms
	echo exit
	echo "Enter a choice:"
	read number
	
	if [[ $number == 1 ]]
	then
		echo Usersname
		echo Password
	elif [[ $number == 2 ]]
	then
		echo Username
		echo Password
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
		echo enable firewall
		echo disable firewall
	elif [[ $number == 7 ]]
	then
		echo What files
	elif [[ $number == 8 ]]
	then
		echo Newpassword:
	elif [[ $number == 9 ]] 
	then
		echo Change Perms
	elif [[ $number = exit ]]
	then 
		break
	else 
	then
		echo "Invalid"
	fi
done	
