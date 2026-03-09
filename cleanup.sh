#!/bin/bash

# نام کانتینرهای این پروژه
CONTAINERS=("3proxy" "wireguard")
VOLUMES=("vpn-forservers_default" "$(basename "$PWD")_default")

echo "==============================="
echo "  پاک‌سازی سرویس‌ها"
echo "==============================="
echo ""

# نمایش کانتینرهایی که قرار است حذف شوند
echo "کانتینرهای این پروژه:"
for c in "${CONTAINERS[@]}"; do
    STATUS=$(docker inspect --format='{{.State.Status}}' "$c" 2>/dev/null || echo "وجود ندارد")
    echo "  - $c : $STATUS"
done
echo ""

read -p "آیا مطمئنی؟ فقط همین کانتینرها پاک می‌شوند (y/N): " CONFIRM
if [ "$CONFIRM" != "y" ] && [ "$CONFIRM" != "Y" ]; then
    echo "لغو شد."
    exit 0
fi

# فقط کانتینرهای این پروژه را متوقف و حذف کن
for c in "${CONTAINERS[@]}"; do
    if docker inspect "$c" &>/dev/null; then
        echo "حذف کانتینر: $c"
        docker stop "$c" 2>/dev/null
        docker rm "$c" 2>/dev/null
    fi
done

# فقط volume های این پروژه را حذف کن
docker compose down -v 2>/dev/null || true

echo ""
read -p "فایل‌های کانفیگ هم پاک شوند؟ (y/N): " CONFIRM2
if [ "$CONFIRM2" = "y" ] || [ "$CONFIRM2" = "Y" ]; then
    rm -f 3proxy.cfg .env
    rm -rf wireguard/
    echo "کانفیگ‌ها پاک شدند."
fi

echo ""
echo "پاک‌سازی کامل شد."
