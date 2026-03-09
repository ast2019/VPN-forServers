#!/bin/bash

CONTAINERS=("3proxy" "wireguard")

echo "==============================="
echo "  پاک‌سازی سرویس‌ها"
echo "==============================="
echo ""

# نمایش وضعیت کانتینرها
echo "کانتینرهای این پروژه:"
for c in "${CONTAINERS[@]}"; do
    STATUS=$(docker inspect --format='{{.State.Status}}' "$c" 2>/dev/null || echo "وجود ندارد")
    echo "  - $c : $STATUS"
done
echo ""

# نمایش sysctl های فعلی
echo "تنظیمات sysctl فعلی سیستم:"
echo "  net.ipv4.ip_forward              = $(sysctl -n net.ipv4.ip_forward)"
echo "  net.ipv4.conf.all.src_valid_mark = $(sysctl -n net.ipv4.conf.all.src_valid_mark)"
echo ""

read -p "آیا مطمئنی؟ فقط همین کانتینرها پاک می‌شوند (y/N): " CONFIRM
if [ "$CONFIRM" != "y" ] && [ "$CONFIRM" != "Y" ]; then
    echo "لغو شد."
    exit 0
fi

# حذف کانتینرها
for c in "${CONTAINERS[@]}"; do
    if docker inspect "$c" &>/dev/null; then
        echo "حذف کانتینر: $c"
        docker stop "$c" 2>/dev/null
        docker rm "$c" 2>/dev/null
    fi
done

docker compose down -v 2>/dev/null || true

# برگرداندن sysctl ها
echo ""
echo "برگرداندن sysctl ها..."
sysctl -w net.ipv4.ip_forward=0
sysctl -w net.ipv4.conf.all.src_valid_mark=0
echo "  net.ipv4.ip_forward              → 0"
echo "  net.ipv4.conf.all.src_valid_mark → 0"

# حذف از /etc/sysctl.conf اگر قبلاً نوشته شده بود
if grep -q "src_valid_mark\|ip_forward" /etc/sysctl.conf 2>/dev/null; then
    sed -i '/net.ipv4.ip_forward/d' /etc/sysctl.conf
    sed -i '/net.ipv4.conf.all.src_valid_mark/d' /etc/sysctl.conf
    echo "  /etc/sysctl.conf هم پاک شد."
fi

echo ""
read -p "فایل‌های کانفیگ هم پاک شوند؟ (y/N): " CONFIRM2
if [ "$CONFIRM2" = "y" ] || [ "$CONFIRM2" = "Y" ]; then
    rm -f 3proxy.cfg .env
    rm -rf wireguard/
    echo "کانفیگ‌ها پاک شدند."
fi

echo ""
echo "پاک‌سازی کامل شد. سرور به حالت اولیه برگشت."
