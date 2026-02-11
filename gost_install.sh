#!/bin/bash

# 提示输入变量值
read -p "请输入 gost 版本号 (如: v2.11.1): " gost_version
read -p "请输入 入口端口 (如: 8080): " upport_val
read -p "请输入 本地转发端口 (如: 1080): " localport_val

# 提取文件名
filename=$(echo $gost_version | sed 's/^v//')_linux_amd64.tar.gz
filename="gost_$filename"

# 下载并安装二进制文件
mkdir -p /tmp/gost_install && cd /tmp/gost_install
wget https://github.com/go-gost/gost/releases/download/$gost_version/$filename
tar -zxvf $filename
mv gost /bin/
chmod +x /bin/gost
cd / && rm -rf /tmp/gost_install

# --- 系统判定与服务配置 ---

if [ -f /etc/alpine-release ]; then
    echo "检测到 Alpine Linux，正在配置 OpenRC 服务..."
    
    cat > /etc/init.d/gost <<EOF
#!/sbin/openrc-run

name="gost"
description="GO Simple Tunnel service"
command="/bin/gost"
command_args="-L relay+tls://:${upport_val}/:${localport_val}"
command_background="yes"
pidfile="/run/\${RC_SVCNAME}.pid"

depend() {
    need net
}
EOF
    chmod +x /etc/init.d/gost
    rc-update add gost default
    rc-service gost restart

elif [ -f /etc/debian_version ] || [ -f /etc/lsb-release ]; then
    echo "检测到 Debian/Ubuntu，正在配置 systemd 服务..."
    
    cat > /etc/systemd/system/gost.service <<EOF
[Unit]
Description=GO Simple Tunnel
After=network.target
Wants=network.target

[Service]
Type=simple
ExecStart=/bin/gost -L relay+tls://:${upport_val}/:${localport_val}
Restart=always

[Install]
WantedBy=multi-user.target
EOF
    systemctl daemon-reload
    systemctl enable gost
    systemctl restart gost

else
    echo "未能识别的系统类型，仅安装了二进制文件，请手动配置服务。"
fi

echo "gost 服务安装与配置尝试完成。"
