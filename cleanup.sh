#!/bin/bash

echo "==============================="
echo "  پاک‌سازی سرویس‌ها"
echo "==============================="
echo ""

docker compose down -v
echo ""

read -p "فایل‌های کانفیگ هم پاک شوند؟ (y/N): " CONFIRM
if [ "$CONFIRM" = "y" ] || [ "$CONFIRM" = "Y" ]; then
    rm -f 3proxy.cfg .env
    rm -rf wireguard/
    echo "کانفیگ‌ها پاک شدند."
fi

echo ""
echo "پاک‌سازی کامل شد."
