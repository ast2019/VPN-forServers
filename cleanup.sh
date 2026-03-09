#!/bin/bash

get_compose_cmd() {
    if docker compose version >/dev/null 2>&1; then
        echo "docker compose"
    elif command -v docker-compose >/dev/null 2>&1; then
        echo "docker-compose"
    else
        return 1
    fi
}

# Project containers
CONTAINERS=("3proxy" "wireguard")

echo "==============================="
echo "  Service cleanup"
echo "==============================="
echo ""

if ! command -v docker &>/dev/null; then
    echo "[ERROR] Docker is not installed."
    exit 1
fi

if ! COMPOSE_CMD=$(get_compose_cmd); then
    echo "[ERROR] Docker Compose is not available."
    echo "Install the Compose plugin or docker-compose and run cleanup again."
    exit 1
fi

# Show only this project's containers
echo "Project containers:"
for c in "${CONTAINERS[@]}"; do
    STATUS=$(docker inspect --format='{{.State.Status}}' "$c" 2>/dev/null || echo "not found")
    echo "  - $c : $STATUS"
done
echo ""

read -p "Are you sure? Only these containers will be removed (y/N): " CONFIRM
if [ "$CONFIRM" != "y" ] && [ "$CONFIRM" != "Y" ]; then
    echo "Canceled."
    exit 0
fi

for c in "${CONTAINERS[@]}"; do
    if docker inspect "$c" &>/dev/null; then
        echo "Removing container: $c"
        docker stop "$c" 2>/dev/null || true
        docker rm "$c" 2>/dev/null || true
    fi
done

$COMPOSE_CMD down -v 2>/dev/null || true

echo ""
read -p "Remove config files too? (y/N): " CONFIRM2
if [ "$CONFIRM2" = "y" ] || [ "$CONFIRM2" = "Y" ]; then
    rm -f 3proxy.cfg .env
    rm -rf wireguard/
    echo "Config files removed."
fi

echo ""
echo "Cleanup completed."
