#!/bin/bash
set -e
if [ $# -ne 1 ];then
    echo "用法：bash nginx_rollback.sh 旧备份文件路径"
    echo "示例：bash nginx_rollback.sh /usr/local/nginx/sbin/nginx.bak.20261105_153000"
    exit 1
fi
BK_FILE="$1"
NGINX_BIN_PATH="/usr/local/nginx/sbin/nginx"
NGINX_PID_FILE="/usr/local/nginx/logs/nginx.pid"

if [ ! -f "${BK_FILE}" ];then
    echo "[ERROR] 备份文件不存在: ${BK_FILE}"
    exit 1
fi

# 停止新master
if [ -f ${NGINX_PID_FILE} ];then
    NEW_PID=$(cat ${NGINX_PID_FILE})
    echo "[INFO] 停止新master pid: ${NEW_PID}"
    kill -QUIT ${NEW_PID}
    sleep 2
fi

# 原子恢复二进制
cp ${BK_FILE} ${NGINX_BIN_PATH}.new
mv ${NGINX_BIN_PATH}.new ${NGINX_BIN_PATH}

echo "[INFO] 回滚后校验配置：${NGINX_BIN_PATH} -t"
${NGINX_BIN_PATH} -t

if [ -f "${NGINX_PID_FILE}.oldbin" ];then
    OLD_PID=$(cat ${NGINX_PID_FILE}.oldbin)
    echo "[INFO] 唤醒旧master pid: ${OLD_PID}"
    kill -HUP ${OLD_PID}
    echo "[INFO] 回滚完成！"
else
    echo "[WARN] 未找到oldbin pid文件，直接启动nginx"
    ${NGINX_BIN_PATH}
fi
