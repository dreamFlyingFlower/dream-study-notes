#!/bin/bash

#####################################################################
########       生成后端服务目录,deploy.sh,stop.sh配置文件,上传本脚本到服务器任意目录,赋权后执行即可      ########
########         赋权命令为chmod 755 server_back.sh,执行命令./server_back.sh或sh server_back.sh         ########
#####################################################################

read -p "请输入服务名称和Jar包名称(不用带后缀),若相同,可只输入一个:" PROJECT_NAME JAR_NAME

echo ""

if [ ! -n "$PROJECT_NAME" ];then
	echo -e "\e[31m----- 未输入服务名称,请重新运行脚本 -----\e[0m"
	exit
fi

if [ ! -n "$JAR_NAME" ];then
	echo -e "\e[33m----- 未输入jar包名称,默认和服务名相同 -----\e[0m"
	JAR_NAME=$PROJECT_NAME
fi

# 后端文件存放根目录
DIR_ROOT=/data
# 后端所有服务存放根目录
DIR_SERVER=$DIR_ROOT/server
# 后端单个服务项目根目录
DIR_SERVER_PROJECT=$DIR_SERVER/$PROJECT_NAME
# 后端单个服务JAR包存放目录
DIR_SERVER_JAR=$DIR_SERVER_PROJECT/app
# 后端单个服务配置文件目录
DIR_SERVER_CONFIG=$DIR_SERVER_JAR/config
# 自启动目录
DIR_OPEN_RUN=/etc/rc.d/rc.local

# 生成MINIO所有层级目录
if [ ! -d "$DIR_SERVER_CONFIG" ];then
	mkdir -p $DIR_SERVER_CONFIG
fi

# 生成deploy.sh脚本
cat>$DIR_SERVER_PROJECT/deploy.sh<<EOF
#!/bin/bash
# 自启动需要环境变量
source /etc/profile
#	jar包文件路径及名称(目录按照各自配置)
APP_NAME=${DIR_SERVER_JAR}/$JAR_NAME.jar

# 日志文件路径及名称(目录按照各自配置)
LOG_FILE=app.log

# 查询进程,并杀掉当前jar/java程序
kill -9 \`ps -ef|grep \$APP_NAME | grep -v grep | awk '{print \$2}'\`
echo "\$pid进程终止成功"
sleep 2

# 判断jar包文件是否存在,如果存在启动jar包,并时时查看启动日志
if test -e \$APP_NAME
then
	echo '文件存在,开始启动此程序...'

	# 启动jar包,指向日志文件,2>&1 & 表示打开或指向同一个日志文件
	nohup java -Xms512m -Xmx512m \\
		-jar \$APP_NAME \\
		--spring.config.additional-location=${DIR_SERVER_CONFIG}/ > /dev/null 2>&1 & 

	# 实时查看启动日志(此处正在想办法启动成功后退出)
	#tail -f \$LOG_FILE
	# 输出启动成功(上面的查看日志没有退出,所以执行不了,可以去掉)
	echo \$APP_NAME '启动成功...'
else
	echo \$APP_NAME '文件不存在,请检查...'
fi
EOF

chmod 755 $DIR_SERVER_PROJECT/deploy.sh

# 生成stop.sh
cat>$DIR_SERVER_PROJECT/stop.sh<<EOF
#!/bin/bash

# jar包文件路径及名称(目录按照各自配置)
APP_NAME=${DIR_SERVER_JAR}/$JAR_NAME.jar

# 查询进程,并强制杀掉当前jar/java程序
PID=\`ps -ef|grep \$APP_NAME | grep -v grep | awk '{print \$2}'\`

if [[ ! \$PID ]]; then
	echo -e "\\e[33m \$APP_NAME未运行 \\e[0m"
else
	echo -e "\\e[32m----- \$APP_NAME进程PID为\$PID -----\\e[0m"
	kill -9 \$PID
	echo -e "\\e[32m----- \$APP_NAME进程终止成功 -----\\e[0m"
fi
EOF


chmod 755 $DIR_SERVER_PROJECT/stop.sh

# 生成application.yml
cat>$DIR_SERVER_CONFIG/application.yml<<EOF
spring:
  application:
    name: $PROJECT_NAME
EOF

# 生成bootstrap.properties
cat>$DIR_SERVER_CONFIG/bootstrap.properties<<EOF
spring.cloud.nacos.config.server-addr=localhost:8848
spring.cloud.nacos.config.namespace=c2a120e8-5c92-4cd5-905d-1c2ffc14d763
spring.cloud.nacos.config.name=$PROJECT_NAME.yml
spring.cloud.nacos.config.group=$PROJECT_NAME
spring.cloud.nacos.config.file-extension=yml
spring.cloud.nacos.config.username=dev
spring.cloud.nacos.config.password=123456

spring.cloud.nacos.config.shared-configs[0].data-id=$PROJECT_NAME-secret.yml
spring.cloud.nacos.config.shared-configs[0].group=$PROJECT_NAME
spring.cloud.nacos.config.shared-configs[0].refresh=true

spring.cloud.nacos.discovery.server-addr=localhost:8848
spring.cloud.nacos.discovery.namespace=c2a120e8-5c92-4cd5-905d-1c2ffc14d763
spring.cloud.nacos.discovery.group=bjdv_service
spring.cloud.nacos.discovery.username=dev
spring.cloud.nacos.discovery.password=123456

spring.cloud.nacos.discovery.enabled=true
spring.cloud.nacos.discovery.register-enabled=true
spring.cloud.nacos.config.enabled=true
EOF

# 添加自启动
chmod +x $DIR_OPEN_RUN

EXIST_NUM=`cat $DIR_OPEN_RUN | grep ${DIR_SERVER_PROJECT}/deploy.sh | wc -l`
if [[ $EXIST_NUM -ge 1 ]]; then
	echo -e "\e[33m----- ${DIR_SERVER_PROJECT}/deploy.sh已经添加到开机自启任务,无需重复添加 -----\e[0m"
else
	echo sh ${DIR_SERVER_PROJECT}/deploy.sh >> $DIR_OPEN_RUN
	echo -e "\e[32m----- ${DIR_SERVER_PROJECT}/deploy.sh添加开机自启成功 -----\e[0m"
fi

echo ""

echo -e "\e[32m----- deploy.sh为启动和重启脚本,stop.sh为停止脚本,在$DIR_SERVER_PROJECT目录下 -----\e[0m"
echo ""
echo -e "\e[33m----- 请注意修改deploy.sh中JVM使用内存范围,默认为512M-512M...... -----\e[0m"
echo ""
echo -e "\e[33m----- 请将服务启动JAR包放入$DIR_SERVER_JAR下 -----\e[0m"
echo ""
echo -e "\e[33m----- 请注意修改$DIR_SERVER_CONFIG/bootstrap.properties中相关属性 -----\e[0m"
echo ""
echo -e "\e[33m----- 请注意修改$DIR_SERVER_CONFIG/application.yml中的项目名称 -----\e[0m"
echo ""
echo -e "\e[35m----- 请将其他配置文件放入$DIR_SERVER_CONFIG下,统一管理 -----\e[0m"

read -p "按任意键退出"

exit