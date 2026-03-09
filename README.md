# VPN for Servers

پروکسی + WireGuard در Docker برای اتصال سرور بدون اینترنت به اینترنت.

## سرویس‌ها

| سرویس | پروتکل | پورت |
|-------|--------|------|
| 3proxy | HTTP | 33128 |
| 3proxy | SOCKS5 | 31080 |
| WireGuard | UDP | 51820 |

## نصب

```bash
git clone https://github.com/ast2019/VPN-forServers.git
cd VPN-forServers
chmod +x setup.sh cleanup.sh
./setup.sh
```

## حذف کامل

```bash
./cleanup.sh
```

## تنظیم سرور B

**apt:**
```bash
echo 'Acquire::http::Proxy "http://SERVER_A_IP:33128";' > /etc/apt/apt.conf.d/99proxy
echo 'Acquire::https::Proxy "http://SERVER_A_IP:33128";' >> /etc/apt/apt.conf.d/99proxy
```

**Docker:**
```bash
mkdir -p /etc/systemd/system/docker.service.d
cat > /etc/systemd/system/docker.service.d/proxy.conf <<EOF
[Service]
Environment="HTTP_PROXY=http://SERVER_A_IP:33128"
Environment="HTTPS_PROXY=http://SERVER_A_IP:33128"
EOF
systemctl daemon-reload && systemctl restart docker
```

**Git SSH:**
```bash
cat >> ~/.ssh/config <<EOF
Host github.com
    ProxyCommand nc -x SERVER_A_IP:31080 %h %p
EOF
```
