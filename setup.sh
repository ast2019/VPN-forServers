#!/bin/bash
set -e

echo "==============================="
echo "  Proxy + WireGuard Setup"
echo "==============================="
echo ""

# بررسی docker
if ! command -v docker &>/dev/null; then
    echo "[ERROR] Docker نصب نیست!"
    exit 1
fi

# ساخت .env از روی example
if [ ! -f .env ]; then
    cp .env.example .env
    echo "فایل .env ساخته شد."
fi

# گرفتن مقادیر از کاربر
read -p "آی‌پی سرور A - این سرور: " INPUT_A
read -p "آی‌پی سرور B - سرور بدون نت: " INPUT_B
read -p "تعداد کلاینت WireGuard [1]: " INPUT_PEERS
INPUT_PEERS=${INPUT_PEERS:-1}

sed -i "s|SERVER_A_IP=.*|SERVER_A_IP=$INPUT_A|" .env
sed -i "s|SERVER_B_IP=.*|SERVER_B_IP=$INPUT_B|" .env
sed -i "s|WG_PEERS=.*|WG_PEERS=$INPUT_PEERS|" .env

# ساخت 3proxy.cfg از template
sed "s|SERVER_B_IP_PLACEHOLDER|$INPUT_B|" 3proxy.cfg.template > 3proxy.cfg
echo "3proxy.cfg ساخته شد."

# اجرا
echo ""
echo "در حال راه‌اندازی سرویس‌ها..."
docker compose up -d

echo ""
echo "==============================="
echo "  اطلاعات اتصال"
echo "==============================="
source .env
echo "HTTP Proxy  : http://$INPUT_A:${PORT_HTTP}"
echo "SOCKS5      : socks5://$INPUT_A:${PORT_SOCKS}"
echo "WireGuard   : $INPUT_A:${PORT_WG}/udp"
echo ""
echo "در حال انتظار برای WireGuard..."
sleep 5
echo ""
echo "--- کانفیگ WireGuard Peer 1 ---"
docker exec wireguard cat /config/peer1/peer1.conf 2>/dev/null \
  || echo "هنوز آماده نشده، چند ثانیه صبر کن و دوباره اجرا کن:"
  echo "  docker exec wireguard cat /config/peer1/peer1.conf"
echo ""
echo "نصب کامل شد!"
