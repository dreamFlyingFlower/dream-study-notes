#!/bin/bash

### CentOS,Rocky专属Docker安装脚本,需要CentOS Stream版本

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

if [ "$(id -u)" -ne 0 ]; then
    echo -e "${RED}[ERROR] 必须root执行${NC}"
    exit 1
fi

echo -e "${GREEN}===== CentOS Stream9 Docker CE 安装/升级脚本 =====${NC}"

# 1. 安装dnf依赖插件
echo -e "\n${YELLOW}[1/5] 安装 dnf-plugins-core${NC}"
dnf install -y dnf-plugins-core

# 2. 清理失效的官方docker源，替换阿里云源
echo -e "\n${YELLOW}[2/5] 配置阿里云Docker CE源${NC}"
rm -f /etc/yum.repos.d/docker-ce.repo
dnf config-manager --add-repo https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
sed -i 's+download.docker.com+mirrors.aliyun.com/docker-ce+' /etc/yum.repos.d/docker-ce.repo

# 3. 重建缓存
echo -e "\n${YELLOW}[3/5] 重建dnf元数据缓存${NC}"
dnf clean all
dnf makecache

# 4. 安装/升级docker全套（已存在则升级，不存在则新装）
echo -e "\n${YELLOW}[4/5] 执行 install（等价于存在就update）${NC}"
dnf install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# 5. 配置镜像加速（daemon.json，不存在才写入，已有则保留原有配置）
echo -e "\n${YELLOW}[5/5] 检查镜像加速配置${NC}"
if [ ! -f /etc/docker/daemon.json ]; then
    mkdir -p /etc/docker
    tee /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": ["https://docker.mirrors.ustc.edu.cn"]
}
EOF
else
    echo "daemon.json 已存在，跳过覆盖，保留原有配置"
fi

# 重载并启动服务
systemctl daemon-reload
systemctl enable --now docker

echo -e "\n${GREEN}==== 完成 ====${NC}"
docker --version
docker compose version
