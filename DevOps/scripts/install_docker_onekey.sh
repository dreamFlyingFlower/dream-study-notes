#!/bin/bash

### 官方一键安装脚本,全发行版通用:Ubuntu/Debian/CentOS/Rocky
### 脚本上传到服务器之后,授权,直接执行即可

# 遇到错误脚本直接退出
set -e

echo "===== 开始使用官方一键脚本安装Docker ====="
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

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
