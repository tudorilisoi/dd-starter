#!/bin/bash

# Check if docker is installed
if ! command -v docker &> /dev/null; then
    echo "Docker is not installed. Please install Docker first."
    exit 1
fi

# Check if dialog is installed
if ! command -v dialog &> /dev/null; then
    echo "This script requires 'dialog'. Please install it first:"
    echo "  Ubuntu/Debian: sudo apt-get install dialog"
    echo "  RHEL/CentOS: sudo yum install dialog"
    echo "  MacOS: brew install dialog"
    exit 1
fi

# Check if prefix is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <container_prefix>"
    exit 1
fi

prefix=$1

# Get list of containers with the given prefix
containers=($(docker ps --format "{{.Names}}" | grep "^${prefix}"))

# Check if any containers found
if [ ${#containers[@]} -eq 0 ]; then
    echo "No containers found with prefix '$prefix'"
    exit 1
fi

# Prepare dialog menu options
menu_options=()
for i in "${!containers[@]}"; do
    menu_options+=("$i" "${containers[$i]}")
done

# Show interactive menu
choice=$(dialog --clear \
                --backtitle "Docker Container Selection" \
                --title "Containers with prefix: $prefix" \
                --menu "Choose a container to exec into:" \
                15 40 4 \
                "${menu_options[@]}" \
                2>&1 >/dev/tty)

clear

# Handle selection
if [ -n "$choice" ]; then
    selected_container="${containers[$choice]}"
    echo "Executing /bin/bash in $selected_container..."
    docker exec -it "$selected_container" /bin/bash
else
    echo "No container selected. Exiting..."
fi