#!/bin/bash
EXIST_NUM=`ps -C nginx --no-header |wc -l`
if [ $EXIST_NUM -eq 0 ];then
    /usr/local/nginx/sbin/nginx
    sleep 2
    if [ `ps -C nginx --no-header |wc -l` -eq 0 ];then
        killall keepalived
    fi
fi