#!/bin/bash

### CentOS,Rocky专属Docker升级脚本

# 遇到错误脚本直接退出
set -e
echo "===== CentOS/Rocky yum源升级Docker ====="
yum update -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

echo "===== 重启服务 ====="
systemctl daemon-reload
systemctl restart docker

echo "===== 验证 ====="
docker --version
echo "✅ 升级完成，原有镜像、容器、卷全部保留，手动启动容器"
