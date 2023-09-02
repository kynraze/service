#!/bin/bash

# Define menu items and actions
menu_items=("Install Node" "Install Snapshot" "Install Statesync" "Exit")
node_submenu=("Mainnet" "Testnet" "Back")
snapshot_submenu=("Mainnet" "Testnet" "Back")
projects=("Arkeo" "Router" "Planq" "Back")

# URLs for installation scripts
install_scripts=("https://raw.githubusercontent.com/kynraze/service/main/mainnet/planq/install-planq.sh" "https://raw.githubusercontent.com/kynraze/service/main/mainnet/arkeo/install-arkeo.sh")

# Initialize variables
selected=0
submenu_selected=0

# Function to display the main menu
show_main_menu() {
    while true; do
        clear
        echo "Main Menu"
        echo "---------"
        for ((i = 0; i < ${#menu_items[@]}; i++)); do
            if [ $i -eq $selected ]; then
                echo "> ${menu_items[i]}"
            else
                echo "  ${menu_items[i]}"
            fi
        done

        read -s -n 1 key
        case $key in
            "A") # Up arrow
                ((selected--))
                if [ $selected -lt 0 ]; then
                    selected=$(( ${#menu_items[@]} - 1 ))
                fi
                ;;
            "B") # Down arrow
                ((selected++))
                if [ $selected -ge ${#menu_items[@]} ]; then
                    selected=0
                fi
                ;;
            "") # Enter key
                case $selected in
                    0)
                        show_node_menu
                        ;;
                    1)
                        show_snapshot_menu
                        ;;
                    2)
                        install_statesync
                        ;;
                    3)
                        echo "Exiting..."
                        exit 0
                        ;;
                esac
                ;;
        esac
    done
}

# Function to display the node menu
show_node_menu() {
    while true; do
        clear
        echo "Node Menu"
        echo "---------"
        for ((i = 0; i < ${#node_submenu[@]}; i++)); do
            if [ $i -eq $submenu_selected ]; then
                echo "> ${node_submenu[i]}"
            else
                echo "  ${node_submenu[i]}"
            fi
        done

        read -s -n 1 key
        case $key in
            "A") # Up arrow
                ((submenu_selected--))
                if [ $submenu_selected -lt 0 ]; then
                    submenu_selected=$(( ${#node_submenu[@]} - 1 ))
                fi
                ;;
            "B") # Down arrow
                ((submenu_selected++))
                if [ $submenu_selected -ge ${#node_submenu[@]} ]; then
                    submenu_selected=0
                fi
                ;;
            "") # Enter key
                case $submenu_selected in
                    0)
                        show_project_menu "Mainnet"
                        ;;
                    1)
                        show_project_menu "Testnet"
                        ;;
                    2)
                        break
                        ;;
                esac
                ;;
        esac
    done
}

# Function to display the snapshot menu
show_snapshot_menu() {
    while true; do
        clear
        echo "Snapshot Menu"
        echo "--------------"
        for ((i = 0; i < ${#snapshot_submenu[@]}; i++)); do
            if [ $i -eq $submenu_selected ]; then
                echo "> ${snapshot_submenu[i]}"
            else
                echo "  ${snapshot_submenu[i]}"
            fi
        done

        read -s -n 1 key
        case $key in
            "A") # Up arrow
                ((submenu_selected--))
                if [ $submenu_selected -lt 0 ]; then
                    submenu_selected=$(( ${#snapshot_submenu[@]} - 1 ))
                fi
                ;;
            "B") # Down arrow
                ((submenu_selected++))
                if [ $submenu_selected -ge ${#snapshot_submenu[@]} ]; then
                    submenu_selected=0
                fi
                ;;
            "") # Enter key
                case $submenu_selected in
                    0)
                        show_project_menu "Mainnet"
                        ;;
                    1)
                        show_project_menu "Testnet"
                        ;;
                    2)
                        break
                        ;;
                esac
                ;;
        esac
    done
}

# Function to display the project menu
show_project_menu() {
    local network="$1"
    while true; do
        clear
        echo "${network^} Menu"
        echo "--------------"
        for ((i = 0; i < ${#projects[@]}; i++)); do
            if [ $i -eq $submenu_selected ]; then
                echo "> ${projects[i]}"
            else
                echo "  ${projects[i]}"
            fi
        done

        read -s -n 1 key
        case $key in
            "A") # Up arrow
                ((submenu_selected--))
                if [ $submenu_selected -lt 0 ]; then
                    submenu_selected=$(( ${#projects[@]} - 1 ))
                fi
                ;;
            "B") # Down arrow
                ((submenu_selected++))
                if [ $submenu_selected -ge ${#projects[@]} ]; then
                    submenu_selected=0
                fi
                ;;
            "") # Enter key
                case $submenu_selected in
                    0)
                        install_project "$network" "Arkeo"
                        ;;
                    1)
                        install_project "$network" "Router"
                        ;;
                    2)
                        install_project "$network" "Planq"
                        ;;
                    3)
                        break
                        ;;
                esac
                ;;
        esac
    done
}

# Function to install a project
install_project() {
    local network="$1"
    local project="$2"
    clear
    echo "Installing $project on $network..."
    
    # Check if the project index is within the array bounds
    if [ $submenu_selected -ge 0 ] && [ $submenu_selected -lt ${#install_scripts[@]} ]; then
        local script_url="${install_scripts[$submenu_selected]}"
        source <(curl -sSL "$script_url")
        install_node
    else
        echo "Invalid selection."
    fi
    
    read -n 1 -s -r -p "Press any key to continue..."
}

# Function to install Statesync
install_statesync() {
    clear
    echo "Installing Statesync..."
    # Add your installation commands for Statesync here
    echo "Statesync installed successfully."
    read -n 1 -s -r -p "Press any key to continue..."
}

# Start the main menu
show_main_menu
