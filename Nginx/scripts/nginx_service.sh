#!/bin/bash

### CentOS安装完Nginx之后将Nginx注册为系统服务

vi /usr/lib/systemd/system/nginx.service<<EOF
[Unit]
# 描述服务
Description=nginx
# 描述服务类别
After=network.target

# 服务运行参数的设置,注意【Service】的启动、重启、停止命令都要用对路径
[Service]
# 后台运行的形式
Type=forking
# 服务具体运行的命令
ExecStart=/usr/local/nginx/sbin/nginx -c /usr/local/nginx/conf/nginx.conf
# 重启命令
ExecReload=/usr/local/nginx/sbin/nginx -s reload
# 停止命令
ExecStop=/usr/local/nginx/sbin/nginx -s quit
# 表示给服务分配独立的临时空间
PrivateTmp=true

# 运行级别下服务安装的相关设置,可设置为多用户,即系统运行级别为3
[Install]
WantedBy=multi-user.target
EOF

systemctl enable nginx.service