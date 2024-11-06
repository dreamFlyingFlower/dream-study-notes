#!/bin/bash

# 清理缓存,可加入到定时任务中

Mem=$(free -m | awk 'NR==2' | awk '{print $4}')

# 当可用缓存小于1024M时清理
if [ $Mem -gt 1024 ];
     then
	echo "Service memory capacity is normal!" > /dev/null
     else
	sync
	echo "1" > /proc/sys/vm/drop_caches
	echo "2" > /proc/sys/vm/drop_caches
	echo "3" > /proc/sys/vm/drop_caches
	sync
fi