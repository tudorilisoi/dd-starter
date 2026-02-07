#!/bin/bash

# Get the current hostname
current_hostname=$(hostname)

if grep -sq 'docker\|lxc' /proc/1/cgroup; then
    echo "Cannot run inside a container"
    exit 1;
fi

# Check if the hostname is "mintbox"
if [ "$current_hostname" = "mintbox" ]; then
  echo "Exiting script because the hostname is mintbox."
  exit 1
else
  echo "Continuing script execution with hostname: $current_hostname"
fi

script_path=$(dirname "$(readlink -f "$0")")

cd "$script_path"
echo "git reset --hard"
git reset --hard
echo "git pull"
git pull
cd -

echo "$script_path/run-compose.sh build"
$script_path/run-compose.sh build

echo "$script_path/run-compose.sh start"
$script_path/run-compose.sh start


