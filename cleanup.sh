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

# نمایش sysctl های فعلی و مقادیر اصلی ذخیره‌شده
echo "وضعیت sysctl:"
echo "  فعلی  | net.ipv4.ip_forward              = $(sysctl -n net.ipv4.ip_forward)"
echo "  فعلی  | net.ipv4.conf.all.src_valid_mark = $(sysctl -n net.ipv4.conf.all.src_valid_mark)"
if [ -f .sysctl_backup ]; then
    source .sysctl_backup
    echo "  اصلی | net.ipv4.ip_forward              = $ORIG_IP_FORWARD"
    echo "  اصلی | net.ipv4.conf.all.src_valid_mark = $ORIG_SRC_VALID"
else
    echo "  [هشدار] فایل backup پیدا نشد — sysctl برگردانده نمی‌شود"
fi
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

# برگرداندن مقادیر اصلی sysctl
if [ -f .sysctl_backup ]; then
    source .sysctl_backup
    echo ""
    echo "برگرداندن sysctl به مقادیر قبل از نصب..."
    sysctl -w net.ipv4.ip_forward=$ORIG_IP_FORWARD
    sysctl -w net.ipv4.conf.all.src_valid_mark=$ORIG_SRC_VALID
    echo "  net.ipv4.ip_forward              → $ORIG_IP_FORWARD"
    echo "  net.ipv4.conf.all.src_valid_mark → $ORIG_SRC_VALID"
    rm -f .sysctl_backup
else
    echo ""
    echo "  [هشدار] backup پیدا نشد — sysctl دست نخورده ماند. بعد از ریبوت وضعیت عادی می‌شود."
fi

echo ""
read -p "فایل‌های کانفیگ هم پاک شوند؟ (y/N): " CONFIRM2
if [ "$CONFIRM2" = "y" ] || [ "$CONFIRM2" = "Y" ]; then
    rm -f 3proxy.cfg .env
    rm -rf wireguard/
    echo "کانفیگ‌ها پاک شدند."
fi

echo ""
echo "پاک‌سازی کامل شد."
