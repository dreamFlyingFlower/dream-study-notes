#!/bin/bash

### CentOS,Rocky专属Docker安装脚本

# 遇到错误脚本直接退出
set -e

echo "===== CentOS/RockyLinux 使用yum源安装Docker ====="
yum install -y yum-utils
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

yum install -y docker-ce docker-ce-cli containerd.io

echo "===== 启动Docker并设置开机自启 ====="
systemctl start docker
systemctl enable docker

echo "===== 配置国内镜像加速 ====="
tee /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": [
    "https://docker.mirrors.ustc.edu.cn",
    "https://hub-mirror.c.163.com"
  ]
}
EOF

systemctl daemon-reload
systemctl restart docker

echo "===== 将当前用户加入docker组（免sudo） ====="
usermod -aG docker $USER

echo ""
echo "✅ Docker安装完成！"
docker --version
echo "👉 重要：请重新登录终端，免sudo权限才生效！"
echo "👉 测试命令：docker run hello-world"
