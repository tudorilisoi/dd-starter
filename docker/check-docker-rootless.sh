#!/bin/bash

# Function to check if Docker is running in rootless mode
check_docker_rootless() {
    local is_rootless=0

    # Method 1: Check Docker socket location
    if [[ -n "$DOCKER_HOST" && "$DOCKER_HOST" == unix://* ]]; then
        if [[ "$DOCKER_HOST" == *"/run/user/"* ]]; then
            echo "Method 1: Docker socket is in user namespace (rootless)"
            is_rootless=1
            return $is_rootless
        fi
    fi

    # Method 2: Check process owner
    if command -v dockerd &>/dev/null; then
        if [[ $(ps -o user= -p $(pgrep dockerd)) == "$USER" ]]; then
            echo "Method 2: Docker daemon running as current user (rootless)"
            is_rootless=1
            return $is_rootless
        fi
    fi

    # Method 3: Check docker info output
    if command -v docker &>/dev/null; then
        if docker info 2>/dev/null | grep -q "rootless"; then
            echo "Method 3: 'docker info' reports rootless mode"
            is_rootless=1
            return $is_rootless
        fi
    fi

    # Method 4: Check user socket file
    if [[ -S "/run/user/$UID/docker.sock" ]]; then
        echo "Method 4: Found user-level Docker socket (rootless)"
        is_rootless=1
        return $is_rootless
    fi

    # Method 5: Check systemd user service
    if command -v systemctl &>/dev/null; then
        if systemctl --user is-active docker.service &>/dev/null; then
            echo "Method 5: Docker user service is active (rootless)"
            is_rootless=1
            return $is_rootless
        fi
    fi

    # If none of the rootless indicators were found
    echo "Docker appears to be running in root mode"
    return $is_rootless
}

# Main execution
check_docker_rootless
exit_code=$?

if [ $exit_code -eq 1 ]; then
    echo "Docker is running in rootless mode"
else
    echo "Docker is running in root mode (or not detected)"
fi

exit $exit_code
