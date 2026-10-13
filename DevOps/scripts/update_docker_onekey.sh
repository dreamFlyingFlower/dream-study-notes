#!/bin/bash

### 官方一键升级脚本,全发行版通用:Ubuntu/Debian/CentOS/Rocky
### 脚本上传到服务器之后,授权,直接执行即可

set -e
echo "===== 升级Docker（get.docker 脚本方式） ====="
# 拉取最新官方脚本
curl -fsSL https://get.docker.com -o get-docker.sh
# 执行，自动升级已有docker
sh get-docker.sh

echo "===== 重启docker服务 ====="
systemctl daemon-reload
systemctl restart docker

echo "===== 验证新版本 ====="
docker --version
echo "✅ 升级完成，执行 docker ps -a 查看原有容器全部保留，手动启动容器：docker start 容器ID"
