#!/bin/bash

# nginx非系统服务,直接使用安装目录下的执行文件进行启动等

# 安装目录根目录
ROOT_DIR=/usr/local/nginx
# 执行文件
EXEC_FILE=${ROOT_DIR}/sbin/nginx
# 默认配置文件
CONFIG_FILE=${ROOT_DIR}/conf/nginx.conf
# 默认PID文件
PID_FILE=${ROOT_DIR}/logs/nginx.pid
# 返回值,0表示正常
RETVAL=0
# Nginx程序运行名称
SERVER_NAME="nginx"

# Source function library
. /etc/rc.d/init.d/functions
# Source networking configuration
. /etc/sysconfig/network

# Check that networking is up
[ ${NETWORKING} = "no" ] && exit 0
# Check nginx has execute permission
[ -x $EXEC_FILE ] || exit 0

if [ $A -eq 0 ];then
    /usr/local/nginx/sbin/nginx
    sleep 2
    if [ `ps -C nginx --no-header |wc -l` -eq 0 ];then
        killall keepalived
    fi
fi

# Start nginx daemons functions
start() {
        # Nginx当前是否运行
        EXIST=`ps -C nginx --no-header |wc -l`

        if [ $EXIST -eq 0 ];then
           echo -n $"Starting $SERVER_NAME: "
           daemon $EXEC_FILE -c ${CONFIG_FILE}
           RETVAL=$?
           echo
           [ $RETVAL = 0 ] && touch /var/lock/subsys/nginx
           return $RETVAL
        fi
           echo "nginx already running...."
           exit 1
}

# Stop nginx daemons functions
stop() {
        echo -n $"Stopping $SERVER_NAME: "
        killproc $EXEC_FILE
        RETVAL=$?
        echo
        [ $RETVAL = 0 ] && rm -f /var/lock/subsys/nginx /usr/local/nginx/logs/nginx.pid
}

# Reload nginx service functions
reload() {
        echo -n $"Reloading $SERVER_NAME: "
        #kill -HUP `cat ${PID_FILE}`
        killproc $EXEC_FILE -HUP
        RETVAL=$?
        echo
}

# See how we were called.
case "$1" in
start)
        start
        ;;
stop)
        stop
        ;;
reload)
        reload
        ;;
restart)
        stop
        sleep 2
        start
        ;;
status)
        status $SERVER_NAME
        RETVAL=$?
        ;;
*)
        echo $"Usage: $SERVER_NAME {start|stop|restart|reload|status|help}"
        exit 1
esac
exit $RETVAL