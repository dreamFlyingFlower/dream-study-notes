#!/bin/bash

### 启动程序.若不输入任何参数,默认调用start方法,直接启动程序
#####################################################################
########                Java程序启动脚本
########                1.上传脚本到服务器执行目录
########                2.赋权:chmod 755 startup.sh或chmod +x startup.sh
########                3.若APP_NAME为相对路径,需要根据路径移动当前脚本
########                4.若APP_NAME为绝对路径,可放在任意目录
########                5.启动./startup.sh 或 ./startup.sh start 或 sh startup.sh 或 sh startup.sh start
#####################################################################

# 遇到错误立即退出
set -e

# JDK执行程序
JDK_HOME=$(readlink -f $(which java 2>/dev/null))
# vm options虚拟机选项,可根据实际情况修改
VM_OPTS=" -Xms256m -Xmx512m "
# 运行程序名称.若需要开机自启,建议修改为绝对路径
APP_NAME="./app/emes-web-dev-1.0.0.jar"
# program arguments,程序参数,如--spring.profiles.active=dev.若需要开机自启,建议修改为绝对路径
SPB_OPTS=" -Dspring.config.additional-location=./app/config/ "
# 当前程序运行进程PID
PID_CMD="ps -ef |grep $APP_NAME |grep -v grep |awk '{print \$2}'"

start() {
 echo "=============================start=============================="
 PID=$(eval $PID_CMD)
 if [[ -n $PID ]]; then
    echo "$APP_NAME is already running,PID is $PID"
 else
    if [[ -e $APP_NAME ]]; then
       echo "The $APP_NAME is exit"
    else
       echo "The $APP_NAME is not exit !!!"
       exit 1
    fi
    nohup $JDK_HOME $VM_OPTS -jar $APP_NAME $SPB_OPTS >/dev/null 2>&1 &
    echo "nohup $JDK_HOME $VM_OPTS -jar $APP_NAME $SPB_OPTS >/dev/null 2>&1 & echo $! > cmd.pid"
    PID=$(eval $PID_CMD)
    if [[ -n $PID ]]; then
       echo "Start $APP_NAME successfully,PID is $PID"
    else
       echo "Failed to start $APP_NAME !!!"
    fi
 fi  
 echo "=============================start=============================="
}

stop() {
 echo "=============================stop=============================="
 PID=$(eval $PID_CMD)
 if [[ -n $PID ]]; then
    kill -15 $PID
    sleep 5
    PID=$(eval $PID_CMD)
    if [[ -n $PID ]]; then
      echo "Stop $APP_NAME failed by kill -15 $PID,begin to kill -9 $PID"
      kill -9 $PID
      sleep 2
      echo "Stop $APP_NAME successfully by kill -9 $PID"
    else 
      echo "Stop $APP_NAME successfully by kill -15 $PID"
    fi 
 else
    echo "$APP_NAME is not running!!!"
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
  PID=$(eval $PID_CMD)
  if [[ -n $PID ]]; then
       echo "$APP_NAME is running,PID is $PID"
  else
       echo "$APP_NAME is not running!!!"
  fi
  echo "=============================status=============================="
}

info() {
  echo "=============================info=============================="
  echo "APP_NAME: $APP_NAME"
  echo "JDK_HOME: $JDK_HOME"
  echo "VM_OPTS: $VM_OPTS"
  echo "SPB_OPTS: $SPB_OPTS"
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

if [[ $# -eq 0 ]]; then
    start
else
    case $1 in
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
# exit $?