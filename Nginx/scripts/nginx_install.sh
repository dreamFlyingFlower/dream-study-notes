#!/bin/bash
# nginx压缩包安装,配置全局命令,自启动

# nginx压缩包上传目录
NGINX_PACKAGE=/data/software/

# 复制改名
cp $NGINX_PACKAGE/nginx-*.tar.gz nginx.tar.gz
# 解压缩
tar -zxvf nginx.tar.gz
cd nginx

# 安装依赖
yum install -y readline-devel pcre-devel openssl-devel zlib-devel gcc-c++ gcc
# 编译安装,并添加https模块.安装完成,默认目录为/usr/local/nginx
./configure --with-http_stub_status_module --with-http_ssl_module
make && make install

# 添加到全局命令
sudo ln -s /usr/local/nginx/sbin/nginx /usr/bin/nginx
