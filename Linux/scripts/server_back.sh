#!/bin/bash

#####################################################
######## 	生成后端服务目录,deploy.sh脚本,配置文件
########	1.上传本脚本到服务器任意目录,赋权后执行即可
########	2.赋权:chmod 755 server_back.sh 或 chmod +x server_back.sh
######## 	3.执行命令./server_back.sh 或 sh server_back.sh
#####################################################

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

echo -e 服务名:$PROJECT_NAME

echo -e JAR名:$JAR_NAME.jar

# 后端文件存放根目录
DIR_ROOT=/app
# 所有脚本存放目录
DIR_SCRIPT=$DIR_ROOT/script
# 后端所有服务存放根目录
DIR_SERVER=$DIR_ROOT/backend
# 后端单个服务项目根目录,JAR包存放在根目录下
DIR_SERVER_PROJECT=$DIR_SERVER/$PROJECT_NAME
# 后端单个服务配置文件目录
DIR_SERVER_CONFIG=$DIR_SERVER_PROJECT/config
# 自启动目录
DIR_OPEN_RUN=/etc/rc.d/rc.local

# 生成脚本目录
if [ ! -d "$DIR_SCRIPT" ];then
    mkdir -p $DIR_SCRIPT
fi

# 生成所有层级目录
if [ ! -d "$DIR_SERVER_CONFIG" ];then
	mkdir -p $DIR_SERVER_CONFIG
fi

# 移动当前脚本到新目录
mv "$0" $DIR_SCRIPT
echo ""
echo -e "\e[33m----- 当前脚本已经移动到 $DIR_SCRIPT -----\e[0m"

# 生成deploy.sh脚本
cat>$DIR_SERVER_PROJECT/deploy.sh<<EOF
#!/bin/bash

#####################################################################
########      Java程序启动脚本.若不输入任何参数,默认调用start方法,直接启动程序
########      1.上传脚本到服务器执行目录
########      2.赋权:chmod 755 deploy.sh或chmod +x deploy.sh
########      3.若APP_NAME为相对路径,脚本需要根据路径移动当前脚本
########      4.若APP_NAME为绝对路径,脚本可放在任意目录
########      5.启动./deploy.sh 或 ./deploy.sh start
#####################################################################

# 遇到错误立即退出
set -e

# JDK执行程序
JDK_HOME=\$(readlink -f \$(which java 2>/dev/null))
# vm options虚拟机选项,可根据实际情况修改
VM_OPTS=" -Xms512m -Xmx512m "
# 运行程序名称.若需要开机自启,建议修改为绝对路径
APP_NAME=${DIR_SERVER_PROJECT}/$JAR_NAME.jar
# program arguments,程序参数,如--spring.profiles.active=dev.若需要开机自启,建议修改为绝对路径
SPB_OPTS=" -Dspring.config.additional-location=$DIR_SERVER_CONFIG "
# 当前程序运行进程PID
PID_CMD="ps -ef |grep \$APP_NAME |grep -v grep |awk '{print \$2}'"

start() {
 echo "=============================start=============================="
 PID=\$(eval \$PID_CMD)
 if [[ -n \$PID ]]; then
    echo "\$APP_NAME is already running, PID is \$PID"
 else
    if [[ -e \$APP_NAME ]]; then
       echo "The \$APP_NAME is exit !"
    else
       echo "The \$APP_NAME is not exit !!!"
       exit 1
    fi
    nohup \$JDK_HOME \$VM_OPTS -jar \$APP_NAME \$SPB_OPTS >/dev/null 2>&1 &
    echo "nohup \$JDK_HOME \$VM_OPTS -jar \$APP_NAME \$SPB_OPTS >/dev/null 2>&1 & echo \$! > cmd.pid"
    PID=\$(eval \$PID_CMD)
    if [[ -n \$PID ]]; then
       echo "Start \$APP_NAME successfully, PID is \$PID"
    else
       echo "Failed to start \$APP_NAME !!!"
    fi
 fi  
 echo "=============================start=============================="
}

stop() {
 echo "=============================stop=============================="
 PID=\$(eval \$PID_CMD)
 if [[ -n \$PID ]]; then
    # 发送信号优雅关闭
    kill -15 \$PID
    sleep 5
    PID=\$(eval \$PID_CMD)
    if [[ -n \$PID ]]; then
      echo "Stop \$APP_NAME failed by kill -15 \$PID, begin to kill -9 \$PID"
      # 暴力停止程序
      kill -9 \$PID
      sleep 2
      echo "Stop \$APP_NAME successfully by kill -9 \$PID"
    else 
      echo "Stop \$APP_NAME successfully by kill -15 \$PID"
    fi 
 else
    echo "\$APP_NAME is not running!!!"
 fi
 echo "=============================stop=============================="
}

restart() {
  echo "=============================restart=============================="
  stop
  start
  echo "=============================restart=============================="
}

status() {
  echo "=============================status==============================" 
  PID=\$(eval \$PID_CMD)
  if [[ -n \$PID ]]; then
       echo "\$APP_NAME is running,PID is \$PID"
  else
       echo "\$APP_NAME is not running!!!"
  fi
  echo "=============================status=============================="
}

info() {
  echo "=============================info=============================="
  echo "APP_NAME: \$APP_NAME"
  echo "JDK_HOME: \$JDK_HOME"
  echo "VM_OPTS: \$VM_OPTS"
  echo "SPB_OPTS: \$SPB_OPTS"
  echo "=============================info=============================="
}

help() {
   echo "start: start server"
   echo "stop: shutdown server"
   echo "restart: restart server"
   echo "status: display status of server"
   echo "info: display info of server"
   echo "help: help info"
}

if [[ \$# -eq 0 ]]; then
    start
else
    case \$1 in
        start)
            start
            ;;
        stop)
            stop
            ;;
        restart)
            restart
            ;;
        status)
            status
            ;;
        info)
            info
            ;;
        help)
            help
            ;;
        *)
            help
            ;;
    esac
fi
EOF

chmod 755 $DIR_SERVER_PROJECT/deploy.sh

echo "当前脚本可移动到专门的脚本目录$DATA_SCRIPT中,以便管理"

# 生成application.yml
cat>$DIR_SERVER_CONFIG/application.yml<<EOF
spring:
  application:
    name: $PROJECT_NAME
EOF

# 生成bootstrap.properties
cat>$DIR_SERVER_CONFIG/bootstrap.properties<<EOF
spring.cloud.nacos.config.enabled=true
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

spring.cloud.nacos.discovery.enabled=true
spring.cloud.nacos.discovery.register-enabled=true
spring.cloud.nacos.discovery.server-addr=localhost:8848
spring.cloud.nacos.discovery.namespace=c2a120e8-5c92-4cd5-905d-1c2ffc14d763
spring.cloud.nacos.discovery.group=bjdv_service
spring.cloud.nacos.discovery.username=dev
spring.cloud.nacos.discovery.password=123456
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

echo -e "\e[32m----- deploy.sh为启动,停止,重启脚本,在$DIR_SERVER_PROJECT目录下 -----\e[0m"
echo ""
echo -e "\e[33m----- 请注意修改deploy.sh中JVM使用内存范围,默认为512M-512M -----\e[0m"
echo ""
echo -e "\e[33m----- 请将服务启动JAR包放入$DIR_SERVER_PROJECT下 -----\e[0m"
echo ""
echo -e "\e[33m----- 请注意修改$DIR_SERVER_CONFIG/bootstrap.properties中相关属性 -----\e[0m"
echo ""
echo -e "\e[33m----- 请注意修改$DIR_SERVER_CONFIG/application.yml中的项目名称 -----\e[0m"
echo ""
echo -e "\e[35m----- 请将其他配置文件放入$DIR_SERVER_CONFIG下,统一管理 -----\e[0m"

read -p "按任意键退出"

exit