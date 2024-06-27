#!/bin/bash

# 提示输入变量值
read -p "请输入 gost 版本号 (如: v2.11.1 或 v3.0.0-nightly.20240625): " gost_version
read -p "请输入 upport (如: 8080): " upport
read -p "请输入 localport (如: 1080): " localport

# 提取文件名
filename=$(echo $gost_version | sed 's/^v//')_linux_amd64.tar.gz
filename="gost_$filename"

# 切换到根目录
cd /

# 创建目标目录
mkdir -p /app/gost/

# 切换到目标目录
cd /app/gost/

# 下载指定版本的 gost
wget https://github.com/go-gost/gost/releases/download/$gost_version/$filename

# 解压下载的文件
tar -zxvf $filename

# 移动 gost 可执行文件到 /bin 目录
mv gost /bin/

# 清理下载的文件
rm -f $filename

# 赋予 gost 可执行权限
chmod +x /bin/gost

# 创建 systemd 服务配置文件
cat > /etc/systemd/system/gost.service <<-EOF
[Unit]
Description=GO Simple Tunnel
After=network.target
Wants=network.target

[Service]
Type=simple
ExecStart=/bin/gost -L relay+tls://:$upport/:$localport
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# 启用并重启 gost 服务
systemctl enable gost
systemctl restart gost

echo "gost 服务已成功安装并启动"
