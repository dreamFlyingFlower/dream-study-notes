#!/bin/bash

#####################################################################
########		生成后端服务目录,deploy.sh,stop.sh配置文件,上传本脚本到服务器任意目录,赋权后执行即可		########
########		  赋权命令为chmod 755 server_back.sh,执行命令./server_back.sh或sh server_back.sh			########
#####################################################################

# minio运行根目录
DIR_SERVER_ROOT=/data/server/minio
# minio执行文件目录
DIR_SERVER_EXECUTE=$DIR_SERVER_ROOT/app
# minio数据存放目录
DIR_DATA=/data/minio

# 生成MINIO所有层级目录
if [ ! -d "$DIR_SERVER_EXECUTE" ];then
	mkdir -p $DIR_SERVER_EXECUTE
fi

if [ ! -d "$DIR_DATA" ];then
	mkdir -p $DIR_DATA
fi

# 生成minio启动脚本
cat>$DIR_SERVER_ROOT/start.sh<<EOF
#!/bin/bash
source /etc/profile

export MINIO_ACCESS_KEY=admin
export MINIO_SECRET_KEY=admin123456

${DIR_SERVER_EXECUTE}/minio server --address ":9001" ${DIR_DATA}/data1 ${DIR_DATA}/data2 ${DIR_DATA}/data3 ${DIR_DATA}/data4 &
EOF

chmod 755 $DIR_SERVER_ROOT/start.sh

# 生成minio启动脚本
cat>$DIR_SERVER_ROOT/stop.sh<<EOF
#!/bin/bash
kill -9 \`ps -ef|grep ${DIR_SERVER_EXECUTE}/minio | grep -v grep | awk '{print \$2}'\`

echo "\$pid进程终止成功......"
EOF

chmod 755 $DIR_SERVER_ROOT/stop.sh

# 添加自启动
chmod +x $DIR_OPEN_RUN

EXIST_NUM=`cat $DIR_OPEN_RUN | grep ${DIR_SERVER_ROOT}/start.sh | wc -l`
if [[ $EXIST_NUM -ge 1 ]]; then
	echo -e "\e[33m----- ${DIR_SERVER_ROOT}/start.sh已经添加到开机自启任务,无需重复添加 -----\e[0m"
else
	echo sh  ${DIR_SERVER_ROOT}/start.sh >> $DIR_OPEN_RUN
	echo -e "\e[32m----- ${DIR_SERVER_ROOT}/start.sh添加开机自启成功 -----\e[0m"
fi

echo ""

echo -e "\e[32m----- ${DIR_SERVER_ROOT}/start.sh为启动脚本,${DIR_SERVER_ROOT}/stop.sh为停止脚本 -----\e[0m"
echo ""
echo -e "\e[33m----- 请先将minio启动文件上传到${DIR_SERVER_EXECUTE}下,之后给minio赋执行权限,之后再执行${DIR_SERVER_ROOT}/start.sh启动 -----\e[0m"
echo ""
echo -e "\e[32m----- 若需要修改minio的登录帐号密码,请直接修改${DIR_SERVER_ROOT}/start.sh中的MINIO_ACCESS_KEY和MINIO_SECRET_KEY.之后重启minio -----\e[0m"
echo ""
echo -e "\e[32m----- 若需要修改minio的访问端口,请直接修改${DIR_SERVER_ROOT}/start.sh中的9001为指定端口.之后重启minio -----\e[0m"
echo ""

read -p "按任意键退出"

exit