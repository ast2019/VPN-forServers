#!/bin/bash
set -e

get_compose_cmd() {
    if docker compose version >/dev/null 2>&1; then
        echo "docker compose"
    elif command -v docker-compose >/dev/null 2>&1; then
        echo "docker-compose"
    else
        return 1
    fi
}

echo "==============================="
echo "  Proxy + WireGuard Setup"
echo "==============================="
echo ""

# بررسی docker
if ! command -v docker &>/dev/null; then
    echo "[ERROR] Docker is not installed."
    exit 1
fi

if ! COMPOSE_CMD=$(get_compose_cmd); then
    echo "[ERROR] Docker Compose is not available."
    echo "Install the Compose plugin or docker-compose and run setup again."
    exit 1
fi

# ساخت .env از روی example
if [ ! -f .env ]; then
    cp .env.example .env
    echo ".env file created."
fi

# گرفتن مقادیر از کاربر
read -p "Server A IP (this server): " INPUT_A
read -p "Server B IP (offline server): " INPUT_B
read -p "Number of WireGuard clients [1]: " INPUT_PEERS
INPUT_PEERS=${INPUT_PEERS:-1}

sed -i "s|SERVER_A_IP=.*|SERVER_A_IP=$INPUT_A|" .env
sed -i "s|SERVER_B_IP=.*|SERVER_B_IP=$INPUT_B|" .env
sed -i "s|WG_PEERS=.*|WG_PEERS=$INPUT_PEERS|" .env

# ساخت 3proxy.cfg از template
sed "s|SERVER_B_IP_PLACEHOLDER|$INPUT_B|" 3proxy.cfg.template > 3proxy.cfg
echo "3proxy.cfg created."

# اجرا
echo ""
echo "Starting services..."
$COMPOSE_CMD up -d

echo ""
echo "==============================="
echo "  Connection details"
echo "==============================="
source .env
echo "HTTP Proxy  : http://$INPUT_A:${PORT_HTTP}"
echo "SOCKS5      : socks5://$INPUT_A:${PORT_SOCKS}"
echo "WireGuard   : $INPUT_A:${PORT_WG}/udp"
echo ""
echo "Waiting for WireGuard..."
sleep 5
echo ""
echo "--- WireGuard Peer 1 config ---"
docker exec wireguard cat /config/peer1/peer1.conf 2>/dev/null \
  || echo "Not ready yet. Wait a few seconds and run:"
  echo "  docker exec wireguard cat /config/peer1/peer1.conf"
echo ""
echo "Setup completed successfully."
