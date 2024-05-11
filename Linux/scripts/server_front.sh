#!/bin/bash

#####################################################################
########					生成前端服务目录,nginx配置文件,上传本脚本到服务器任意目录,赋权后执行即可				########
########			赋权命令:chmod 755 server_front.sh,执行命令:./server_front.sh或sh server_front.sh		########
#####################################################################

read -p "请输入服务名称以及端口号:" PROJECT_NAME SERVER_PORT

if [ ! -n "$PROJECT_NAME" ];then
    echo -e "\e[31m----- 未输入服务名称,请重新运行脚本 -----\e[0m"
	exit
fi

if [ ! -n "$SERVER_PORT" ];then
    echo -e "\e[31m----- 未输入端口号,请重新运行脚本 -----\e[0m"
	exit
fi

# 前端nginx文件存放根目录
DIR_ROOT=/data/nginx
# 前端所有服务存放根目录
DIR_SERVER=$DIR_ROOT/html
# 前端单个服务项目根目录
DIR_SERVER_PROJECT=$DIR_SERVER/$PROJECT_NAME

# 前端nginx配置文件目录
DIR_NGINX_CONF=$DIR_ROOT/conf

# 生成后端所有层级目录
if [ ! -d "$DIR_SERVER_PROJECT" ];then
	mkdir -p $DIR_SERVER_PROJECT
fi

# 生成nginx配置文件所有层级目录
if [ ! -d "$DIR_NGINX_CONF" ];then
	mkdir -p $DIR_NGINX_CONF
fi

# 生成项目conf配置文件
cat>$DIR_NGINX_CONF/$PROJECT_NAME.conf<<EOF
server {
    listen       $SERVER_PORT;
    server_name  127.0.0.1;

    location / {
        root $DIR_SERVER_PROJECT/$PROJECT_NAME;
        index  index.html index.htm;
        try_files \$uri \$uri/ /index.html;
    }

    # 若有网关服务,则coconut配置为网关服务地址,uim可以不配置;若无网关服务,coconut可以不配置
    location /coconut/ {
        proxy_pass http://127.0.0.1:3007/;
        proxy_redirect off;
        proxy_set_header Host \$http_host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        client_max_body_size  100m;
    }

    location /oauth/ {
        proxy_pass http://127.0.0.1:3008/oauth/;
        proxy_redirect off;
        proxy_set_header Host \$http_host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        client_max_body_size  100m;
    }

    location /uim/ {
        proxy_pass http://127.0.0.1:3006/;
        proxy_redirect off;
        proxy_set_header Host \$http_host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        client_max_body_size  100m;
    }

    location /$PROJECT_NAME/ {
        proxy_pass http://127.0.0.1:8080/;
        proxy_redirect off;
        proxy_set_header Host \$http_host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        client_max_body_size  100m;
    }
}
EOF

echo -e "\e[35m----- 请将所有前端nginx配置文件都放入${DIR_NGINX}下,方便统一管理 -----\e[0m"
echo ""
echo -e "\e[32m----- 每个前端项目都会生成单独的nginx配置文件,项目名称请不要重名,否则会覆盖配置 -----\e[0m"
echo ""
echo -e "\e[33m----- 请注意修改${DIR_NGINX}/${PROJECT_NAME}.conf中coconut,oauth,uim后端服务IP以及端口 -----\e[0m"
echo ""
echo -e "\e[33m----- 请注意修改${DIR_NGINX}/${PROJECT_NAME}.conf中location为${PROJECT_NAME}的属性为相应业务后端服务地址,修改IP以及端口 -----\e[0m"
echo ""
echo -e "\e[32m----- 若需要修改文件上传最大限制,请修改单个location中的client_max_body_size属性 -----\e[0m"

read -p "按任意键退出"

exit