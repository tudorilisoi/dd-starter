#!/bin/bash

# One time setup 3 steps
# 1)
# sudo apt-get install pass gnupg2

# 2) create a gpg2 key
# gpg2 --gen-key

# 3) create the password store using the gpg user id
# pass init $gpg_id



if [ $# -eq 0 ]; then
    echo  "Usage: $0 folderName [-u]"
    echo  "-u: uninstall"
    exit 1;
fi
# TODO make a copy and substitute workdir and $1

clear

BASE_DIR="/home/tudor/Documents/dev"
# production @ionos
BASE_DIR="/home/tudor/www"

SRV_NAME=$1
SERVICE_FILE="docker-compose@$SRV_NAME.service"

if [ "$2" == "-u" ]; then
    sudo systemctl stop "$SERVICE_FILE"
    sudo systemctl disable "$SERVICE_FILE"
    sudo rm -f "/etc/systemd/system/$SERVICE_FILE"
    sudo systemctl daemon-reload
    echo "Service $SERVICE_FILE removed."
    exit 0;
fi


# cp docker-compose@.service "$SERVICE_FILE"
WDIR="$BASE_DIR/$SRV_NAME/docker"

rm "/tmp/$SERVICE_FILE" 2>&1
sed "s#WDIR#$WDIR#g" docker-compose@.service > "/tmp/$SERVICE_FILE"

cat "/tmp/$SERVICE_FILE"
read -p "Press enter to continue"

#debug
# exit

sudo cp "/tmp/$SERVICE_FILE" "/etc/systemd/system/$SERVICE_FILE"
rm "/tmp/$SERVICE_FILE"
sudo systemctl enable "$SERVICE_FILE"
sudo systemctl daemon-reload
sudo systemctl restart "$SERVICE_FILE"

journalctl -f -u "$SERVICE_FILE"
