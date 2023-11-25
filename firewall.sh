#!/bin/bash

login() {
    user_name=$(zenity --title="Enter Your Name" --entry --text="Please enter your name:" --width=300)
    if [ -n "$user_name" ]; then
        if [ "$user_name" = "Cosmin" ]; then
            zenity --info --text="Hello, $user_name! Login successful."
            return 0
        else
            zenity --warning --text="Login failed. Invalid user: $user_name"
        fi
    else
        zenity --warning --text="Login failed. No name provided."
    fi
    return 1
}

handle_firewall_action() {
    # Display action options using Zenity list dialog
    action=$(zenity --width=600 --height=400 --list --radiolist \
        --title 'Firewall' --text 'Select option:' --column 'Choose' --column 'Option' \
        TRUE 'Firewall informations' \
        FALSE 'Enable' \
        FALSE 'Disable' \
        FALSE 'Block the port' \
        FALSE 'Open the port' \
        FALSE 'Manage iptables rules' \
        FALSE 'Network Statistics' \
        FALSE 'Block SSH' \
        FALSE 'Block DDoS' \
        FALSE 'Allow HTTP' \
        FALSE 'Block Man-in-the-middle')

    case "$action" in
        'Firewall informations')
            firewall_info_action=$(zenity --width=600 --height=400 --list --radiolist \
                --title 'Firewall' --text 'Select option:' --column 'Choose' --column 'Option' \
                TRUE 'Unable' \
                FALSE 'Disable' )

            if [ "$firewall_info_action" == 'Unable' ]; then
                sudo ufw enable
                zenity --info --text "The firewall is active."
            elif [ "$firewall_info_action" == 'Disable' ]; then
                sudo ufw disable
                zenity --info --text "The firewall is inactive."
            else
                zenity --error --text "You didn't choose a valid option."
            fi
            ;;
        'Enable')
            sudo ufw enable
            zenity --info --text "The firewall is active."
            ;;
        'Disable')
            sudo ufw disable
            zenity --info --text "The firewall is inactive."
            ;;
        'Block the port')
            # Prompt user for the port to block
            portblock=$(zenity --entry --title "Port blocking" --text "Enter the port you want to block:")

            # Block the specified port
            sudo iptables -A INPUT -p tcp --dport "$portblock" -j DROP
            sudo iptables -A INPUT -p udp --dport "$portblock" -j DROP

            zenity --info --text "The port $portblock was blocked."
            ;;
        'Open the port')
            # Prompt user for the port to open
            portopen=$(zenity --entry --title "Port opening" --text "Enter the port you want to open:")

            # Open the specified port
            sudo iptables -A INPUT -p tcp --dport "$portopen" -j ACCEPT
            sudo iptables -A INPUT -p udp --dport "$portopen" -j ACCEPT

            zenity --info --text "The port $portopen was opened."
            ;;
        'Manage iptables rules')
            manage_iptables_rules
            ;;
        'Network Statistics')
            display_network_statistics
            ;;
        'Block SSH')
            block_ssh
            ;;
        'Block DDoS')
            block_DDoS
            ;;
        'Allow HTTP')
            allow_http
            ;;
        'Block Man-in-the-Middle')
            block_mitm
            ;;
        *)
            zenity --error --text "You didn't choose a valid option."
            ;;
    esac
}

display_network_statistics() {
    network_stats=$(netstat -s)
    if [[ -n "$network_stats" ]]; then
        zenity --text-info --title="Network Statistics" --width=600 --height=400 --text="$network_stats"
    else
        zenity --info --text="Failed to retrieve network statistics."
    fi
}

manage_iptables_rules() {
    iptables_rules=$(sudo iptables -L -n)
    exit_status=$?

if [ "$exit_status" -eq 0 ]; then
if [ -n "{iptables_rules}" ]; then
	zenity --text-info --title="iptables Rules" --width=600 --height=400 --text="$iptables_rules"
else
zenity --info --text= "No iptables rules found. "
fi
else
        zenity --error --text= "Failed to retrieve iptables rules. Exit status: ${exit_status}"


fi
}
block_ssh() {
    blocked_region='10.0.2.1'
    sudo iptables -A INPUT -p tcp --dport 22 -s --src-range "$blocked_region" -j DROP
    if [[ $? -eq 0 ]]; then
        zenity --info --text "SSH connection from a specific region has been blocked."
    else
        zenity --error --text "Failed to block SSH connection from the specified region."
    fi
}

block_DDoS() {
    sudo iptables -A INPUT -p tcp --dport 80 -m limit --limit 25/sec --limit-burst 100 -j ACCEPT
    sudo iptables -A INPUT -p tcp --dport 80 -j DROP
    if [[ $? -eq 0 ]]; then
        zenity --info --text "DDoS protection has been enabled."
    else
        zenity --error --text "Failed to enable DDoS protection."
    fi
}

allow_http() {
    sudo iptables -A INPUT -p tcp --dport 80 -j ACCEPT
    if [[ $? -eq 0 ]]; then
        zenity --info --text "HTTP traffic is allowed."
    else
        zenity --error --text "Failed to allow HTTP traffic."
    fi
}

block_mitm() {
sudo ufw deny 80
sudo ufw deny 443

    if [[ $? -eq 0 ]]; then
        zenity --info --text "Man-in-the-Middle attacks have been blocked."
    else
        zenity --error --text "Failed to block Man-in-the-Middle attacks."
    fi
}

zenity --info --title="Firewall GUI" --text="Welcome to Firewall GUI!" --width=400 --height=150

if [ $? = 0 ]; then
    handle_firewall_action
else
    zenity --info --text="Firewall not started."
fi
