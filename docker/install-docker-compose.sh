#!/bin/bash
COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep 'tag_name' | cut -d\" -f4)
echo "Latest version $COMPOSE_VERSION"
COMPOSE_VERSION="v2.23.1"
URL=https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-`uname -s`-`uname -m`
echo $URL
sudo sh -c "curl -L $URL  > /usr/local/bin/docker-compose"
sudo chmod +x /usr/local/bin/docker-compose
