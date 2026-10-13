#!/bin/bash

### CentOS,Rocky专属Docker升级脚本,需要CentOS Stream版本

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

if [ "$(id -u)" -ne 0 ]; then
    echo -e "${RED}[ERROR] 必须root执行${NC}"
    exit 1
fi

echo -e "${GREEN}===== CentOS Stream9 Docker CE 升级脚本 =====${NC}"
echo "说明：只做升级，不修改源、不卸载任何包，daemon.json保留原样"
echo -e "${YELLOW}⚠️ 升级会重启docker服务，运行中的容器会停机${NC}"

# 记录当前版本
OLD_VER=$(docker --version 2>/dev/null || echo "未检测到docker")
echo "当前版本: ${OLD_VER}"

# 检查是否存在docker-ce源文件
if [ ! -f /etc/yum.repos.d/docker-ce.repo ]; then
    echo -e "${RED}[ERROR] 找不到docker-ce.repo源文件，请先执行安装脚本配置源！${NC}"
    exit 1
fi

# 询问确认
read -p "确认已经完成容器&镜像备份，继续升级？输入 YES 继续: " CONFIRM
if [ "${CONFIRM}" != "YES" ];then
    echo "取消升级"
    exit 0
fi

# 执行升级
dnf update -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# 重载+重启服务
systemctl daemon-reload
systemctl restart docker
systemctl restart containerd

echo -e "\n${GREEN}===== 升级完成 =====${NC}"
docker --version
docker compose version

echo -e "${YELLOW}提示：容器会按照restart策略自动拉起，请核对业务状态${NC}"
