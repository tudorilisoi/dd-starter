#!/bin/bash
script_path=$(dirname "$(readlink -f "$0")")
export CURRENT_UID=$(id -u)
export CURRENT_GUID=$(id -g)
export HOST_APP_PATH=$(realpath "$script_path/../")
echo "HOST_APP_PATH=$HOST_APP_PATH" >"$script_path/.env.generated"

output=$("$script_path/check-docker-rootless.sh")
exit_code=$?

echo "Script output was: $output"
if [ $exit_code -eq 1 ]; then
  echo "Preparing for rootless operations..."
  # Configure for rootless mode
  export CURRENT_UID=root
  export CURRENT_GUID=root
else
  echo "Preparing for standard root operations..."
  # Configure for root mode
fi

if grep -sq 'docker\|lxc' /proc/1/cgroup; then
  echo "Cannot run inside a container"
  exit 1
fi
BUILD_CMD="cd /app;\
npm install --no-update-notifier;\
npm run build;\
"
EXTRA_ARGS="-d"
export WEB_MEM_LIMIT="1G"

# NOTE running without WS
if [ "$1" == "dev" ]; then
  echo "Running development command"
  export WEB_MEM_LIMIT="4G"
  export WEB_CMD='npm run dev'
elif [ "$1" == "start" ]; then
  echo "Running start command"
  export WEB_CMD="npm run start"
elif [ "$1" == "stop" ]; then
  echo "Running stop command"
  docker compose -f "$script_path/docker-compose.yml" down 2>&1
  exit 0
elif [ "$1" == "build" ]; then
  echo "Running build command"
  export WEB_MEM_LIMIT="4G"
  export WEB_CMD=$BUILD_CMD
  EXTRA_ARGS="--abort-on-container-exit" # no detach
elif [ "$1" == "logs" ]; then
  echo "Running logs command"
  docker compose -f "$script_path/docker-compose.yml" logs -f
  exit 0
else
  echo "Invalid argument. Usage: $0 [dev|start|stop|build|logs]"
  exit 1
fi

mkdir -p /tmp/rp-web-tmp
mkdir -p /tmp/rp-web-cache
docker compose -f "$script_path/docker-compose.yml" down 2>&1
docker compose -f "$script_path/docker-compose.yml" up --build $EXTRA_ARGS
