#!/bin/bash

set -e

# -------------------------- 配置区，按需修改 --------------------------
NGINX_BIN_PATH="/usr/local/nginx/sbin/nginx"
NGINX_PID_FILE="/usr/local/nginx/logs/nginx.pid"
NGINX_OLD_BK="${NGINX_BIN_PATH}.bak.$(date +%Y%m%d_%H%M%S)"
# ---------------------------------------------------------------------

# 检查nginx二进制是否存在
if [ ! -f "${NGINX_BIN_PATH}" ];then
	echo "[ERROR] 目标nginx不存在: ${NGINX_BIN_PATH}"
	exit 1
fi

if [ ! -f ./configure ];then
	echo "[ERROR] 当前目录不是nginx源码目录！请进入nginx新版本源码目录再执行"
	exit 1
fi

CONFIGURE_ARGS=$(${NGINX_BIN_PATH} -V 2>&1 | grep -oE 'configure arguments:.*' | sed 's/configure arguments: //')
if [ -z "${CONFIGURE_ARGS}" ];then
	echo "[ERROR] 获取nginx编译参数失败！"
	exit 1
fi
echo "[INFO] 原编译参数：${CONFIGURE_ARGS}"

echo "[INFO] 开始 ./configure ..."
./configure ${CONFIGURE_ARGS}
echo "[INFO] 开始 make ..."
make

if [ ! -f ./objs/nginx ];then
	echo "[ERROR] 编译失败，objs/nginx 不存在"
	exit 1
fi

echo "[INFO] 校验新版本二进制：./objs/nginx -t"
./objs/nginx -t

echo "[INFO] 备份旧二进制 -> ${NGINX_OLD_BK}"
cp ${NGINX_BIN_PATH} ${NGINX_OLD_BK}

# 原子替换，规避 text file busy
cp ./objs/nginx ${NGINX_BIN_PATH}.new
mv ${NGINX_BIN_PATH}.new ${NGINX_BIN_PATH}

echo "[INFO] 替换完成，使用全路径校验配置：${NGINX_BIN_PATH} -t"
${NGINX_BIN_PATH} -t

if [ -f ${NGINX_PID_FILE} ];then
	OLD_PID=$(cat ${NGINX_PID_FILE})
	echo "[INFO] 发送USR2，拉起新master，旧PID: ${OLD_PID}"
	kill -USR2 ${OLD_PID}
	sleep 2
	if [ -f "${NGINX_PID_FILE}.oldbin" ];then
		echo "[INFO] 升级成功！已经生成 ${NGINX_PID_FILE}.oldbin，新旧master同时运行"
		echo "---------------------------------------------------------"
		echo "✅ 业务验证正常后，执行下面命令优雅关闭旧进程："
		echo "kill -QUIT \$(cat ${NGINX_PID_FILE}.oldbin)"
		echo "❌ 如果业务异常，执行回滚："
		echo "bash nginx_rollback.sh ${NGINX_OLD_BK}"
		echo "---------------------------------------------------------"
	else
		echo "[WARN] 未发现 nginx.pid.oldbin，请手动检查进程 ps aux | grep nginx"
	fi
else
	echo "[WARN] pid文件不存在，跳过USR2信号，nginx可能未启动"
fi