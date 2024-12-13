#!/bin/bash
# CyberPatriots Linux Script






# Add User
add_user() {
    read -p "Enter the username for the new account: " username
    if id "$username" &>/dev/null; then
        echo "User '$username' already exists."
    else
        sudo adduser $username
        echo "User '$username' added successfully."
    fi
}




# Change Password
change_password(){
    read -p "Enter username: " username
    if id "$username" &>/dev/null; then
        sudo passwd $username
        echo "Password for '$username' updated."
    else
        echo "User '$username' does not exist."
    fi
}




# Add User to a Group
add_user_to_group() {
    read -p "Enter the username to add to a group: " username
    if id "$username" &>/dev/null; then
        read -p "Enter the group name to add '$username' to: " groupname
        if grep -q "^$groupname:" /etc/group; then
            sudo usermod -aG $groupname $username
            echo "User '$username' has been added to the group '$groupname'."
        else
            echo "Group '$groupname' does not exist. Please create the group first."
        fi
    else
        echo "User '$username' does not exist. Please add the user first."
    fi
}




# Delete User
delete_user() {
    read -p "Enter the username of the account to delete: " username
    if id "$username" &>/dev/null; then
        if sudo deluser --remove-home $username; then
            echo "User account '$username' has been deleted successfully."
        else
            echo "Failed to delete user '$username'."
        fi
    else
        echo "User account '$username' does not exist."
    fi
}




# Enable Firewall
enable_firewall() {
    sudo ufw enable
    sudo ufw status verbose
    echo "Firewall has been enabled."
}




# System Audit
audit_system() {
    echo "Performing system audit..."
    sudo find / -perm 777 -type d
    sudo netstat -tulpn
    echo "Audit complete. Review the results."
}




# Update System
update_system() {
    sudo apt update && sudo apt upgrade -y
    echo "System packages updated."
}




# Remove Application
remove_application() {
    read -p "Enter the name of the application to remove: " app_name
    # Check if the application is installed (case-insensitive)
    if dpkg -l | grep -i "$app_name" &>/dev/null; then
        sudo apt remove --purge -y "$app_name" && sudo apt autoremove -y
        echo "Application '$app_name' has been removed successfully."
    else
        echo "Application '$app_name' is not installed or the name is incorrect."
    fi
}




#Adding Application
adding_application() {
    if dpkg -l | grep -i "wget" &>/dev/null; then
        echo “wget is installed”
    else
        sudo apt install wget
    fi
    read -p "Enter the installation link of the application to add (search example: Linux Latest app_name Install) (link example: https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb): " app_link
    # Downloader
    sudo wget "$app_link"
    echo "Application '$app_link' has been added successfully."
}




#Change Password MIN/MAX
setDefault_passwordSettings() {
    sudo apt install libpam-pwquality -y
    sudo sed -i 's/password requisite pam_pwquality.so retry=3/password requisite pam_pwquality.so retry=3 minlen=14 difok=3 ucredit=-1 lcredit=-1 dcredit=-1 ocredit=-1/' /etc/pam.d/password




    sudo sed -i 's/^PASS_MAX_DAYS.*/PASS_MAX_DAYS 15/' /etc/login.defs
    sudo sed -i 's/^PASS_MIN_DAYS.*/PASS_MIN_DAYS 7/' /etc/login.defs
    sudo sed -i 's/^PASS_WARN_AGE.*/PASS_WARN_AGE 7/' /etc/login.defs
    sudo sed -i 's/^minlen.*/minlen = 14/' /etc/security/pwquality.conf




    echo "Security settings applied. Please reboot the system."
}




# Detect and Delete mp4/mp3 Files
remove_media_files() {
    find / -type f \( -iname "*.mp4" -o -iname "*.mp3" \) 2>/dev/null
    echo "Searching for .mp4 and .mp3 files..."




    read -p "Do you want to delete all these files? (y/n): " confirmation
    if [[ $confirmation == "y" || $confirmation == "Y" ]]; then
        sudo find / -type f \( -iname "*.mp4" -o -iname "*.mp3" \) -exec rm -f {} \; 2>/dev/null
        echo ".mp4 and .mp3 files have been deleted."
    else
        echo "Deletion canceled."
    fi
}


# Deactivating IPv4 + Enabling TCP SYN Cookies
deactivate_IPv4() {
    echo "Deactivating IPv4 forwarding in current session..."
    sudo sysctl -w net.ipv4.ip_forward=0
    echo "Rewriting IPv4 in settings..."
    sudo sed -i 's/^net.ipv4.ip_forward=.*/net.ipv4.ip_forward=0/' /etc/sysctl.conf
    echo "Confirming..."
    sysctl net.ipv4.ip_forward
   
    echo "IPv4 Disabled"
   
    echo "Enabling TCP SYN cookies..."
    sudo sysctl -w net. ipv4. tcp_syncookies=1
    echo "Changing settings..."
    sudo sed -i 's/^net.ipv4.tcp_syncooktes=.*/net.ipv4.tcp_syncooktes=1/' /etc/sysctl.conf
    sysctl net. Ive. tep syncooktes
    echo "TCP SYN cookies have been activated"
}




# Disable a Service
disable_service() {
    echo "check for any unnecessary services using this following command line:"
    echo "systemctl list-units -–type=service --state=active"
    read -p "Which service would you like to disable? " service_name


    if systemctl list-units --type=service | grep -q "$service_name"; then
        sudo systemctl disable "$service_name"
        sudo systemctl stop "$service_name"
        echo "Service '$service_name' has been disabled and stopped successfully."
    else
        echo "Service '$service_name' does not exist or is not active."
    fi
}




# Manage SSH Remote Login
manage_ssh_remote_login() {
    echo "Do you want to enable or disable SSH remote login?"
    echo "Selection should be based off the READ.ME/Company policy"
    echo "1: Enable SSH remote login"
    echo "2: Disable SSH remote login"
    read -p "Please make a selection (1/2): " ssh_choice


    case $ssh_choice in
        1)
            echo "Enabling SSH remote login..."
            sudo sed -i 's/^#PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
            sudo systemctl restart ssh
            echo "SSH remote login has been enabled."
            ;;
        2)
            echo "Disabling SSH remote login..."
            sudo sed -i 's/^#PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
            sudo sed -i 's/^PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
            sudo systemctl restart ssh
            echo "SSH remote login has been disabled."
            ;;
        *)
            echo "Invalid selection. Returning to main menu."
            ;;
    esac
}


# Fix Permissions of /etc/shadow
fix_shadow_permissions() {
    echo "Checking permissions for /etc/shadow..."
    current_permissions=$(stat -c "%a" /etc/shadow)


    echo "Current permissions: $current_permissions"
    if [[ "$current_permissions" != "640" ]]; then
        echo "Fixing permissions for /etc/shadow to 640..."
        sudo chmod 640 /etc/shadow
        echo "Permissions for /etc/shadow have been set to 640."
    else
        echo "Permissions for /etc/shadow are already correct."
    fi


    echo "Verifying permissions..."
    ls -alF /etc/shadow
}






# Show Menu
show_menu() {
    clear
    echo "                                == READ ME ==                                   "
    echo ""
    echo "== This script does not manage Password Complexity"
    echo "== Manage Password Policies manually; Refer to Linux Notes"
    echo "== WARNING: PASSWORD COMPLEXITY SHOULD ONLY BE ADJUSTED/CHANGED AT THE VERY END "
    echo ""
    echo "================================================================================"
    echo "                  ==== Cyberpatriots Linux Script ====                "








    echo "01: Add user"
    echo "02: Delete user"
    echo "03: Add User to Group"
    echo "04: Enable firewall"
    echo "05: Change passwords"
    echo "06: Update system"
    echo "07: System audit"
    echo "08: Remove Application"
    echo "09: Set Default Password Settings (Password Policy: DO AT THE VERY END OF COMPETITION)"
    echo "10: Delete MP3/MP4 files"
    echo "11: Deactivate IPv4"
    echo "12: Disable a Service"
    echo "13: Manage SSH Remote Login"
    echo "14: Fix Shadow File Permissions"
    echo "Q:  Quit"
}




# Main Menu
while true; do
    show_menu
    read -p "Please make a selection: " selection
    case $selection in
        1) add_user ;;
        2) delete_user ;;
        3) add_user_to_group ;;
        4) enable_firewall ;;
        5) change_password ;;
        6) update_system ;;
        7) audit_system ;;
        8) remove_application ;;
        9) setDefault_passwordSettings ;;
        10) remove_media_files ;;
        11) deactivate_IPv4 ;;
        12) disable_service ;;
        13) manage_ssh_remote_login ;;
        14) fix_shadow_permissions ;;
        Q|q) exit 0 ;;
        *) echo "Invalid selection. Please try again." ;;
    esac
    read -p "Press Enter to continue..."
done
















# How to execute on Linux terminal
#    cd ~/Downloads
#    chmod +x linux.sh
#    ./linux.sh












# //check all services; find unnecessary ones ex) nginx; a high performance web server
# //dont script; manual
# systemctl list-units -–type=service --state=active








# //remove service command
# sudo systemctl disable –now [service_name]












# //make sure /etc/shadow file has correct permissions
# //script out
# ls -alF /etc/shadow
# //remove unwanted permission
# 640: removes world read permissions
# O+r: adds world read permissions




# ex) sudo chmod 640 /etc/shadow- removes world read permissions
