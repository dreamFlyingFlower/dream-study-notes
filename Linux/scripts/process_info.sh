#!/bin/bash

################## 1 ##################


# 根据用户输入的PID,过滤出该PID所有的信息
read -p "请输入要查询的PID: " P
n=`ps -aux| awk '$2~/^'$P'$/{print $11}'|wc -l`
if [ $n -eq 0 ];then
 echo "该PID不存在！！"
 exit
fi
echo "--------------------------------"
echo "进程PID: $P"
echo "进程命令：`ps -aux| awk '$2~/^'$P'$/{print $11}'`"
echo "进程所属用户: `ps -aux| awk '$2~/^'$P'$/{print $1}'`"
echo "CPU占用率：`ps -aux| awk '$2~/^'$P'$/{print $3}'`%"
echo "内存占用率：`ps -aux| awk '$2~/^'$P'$/{print $4}'`%"
echo "进程开始运行的时刻：`ps -aux| awk '$2~/^'$P'$/{print $9}'`"
echo "进程运行的时间：`ps -aux| awk '$2~/^'$P'$/{print $10}'`"
echo "进程状态：`ps -aux| awk '$2~/^'$P'$/{print $8}'`"
echo "进程虚拟内存：`ps -aux| awk '$2~/^'$P'$/{print $5}'`"
echo "进程共享内存：`ps -aux| awk '$2~/^'$P'$/{print $6}'`"
echo "--------------------------------"


################## 2 ##################


# 根据输入的程序的名字过滤出所对应的PID,并显示出详细信息,如果有几个PID,则全部显示
read -p "请输入要查询的进程名：" NAME
N=`ps -aux | grep $NAME | grep -v grep | wc -l` ##统计进程总数
if [ $N -le 0 ];then
  echo "该进程名没有运行！"
fi
i=1
while [ $N -gt 0 ]
do
  echo "进程PID: `ps -aux | grep $NAME | grep -v grep | awk 'NR=='$i'{print $0}'| awk '{print $2}'`"
  echo "进程命令：`ps -aux | grep $NAME | grep -v grep | awk 'NR=='$i'{print $0}'| awk '{print $11}'`"
  echo "进程所属用户: `ps -aux | grep $NAME | grep -v grep | awk 'NR=='$i'{print $0}'| awk '{print $1}'`"
  echo "CPU占用率：`ps -aux | grep $NAME | grep -v grep | awk 'NR=='$i'{print $0}'| awk '{print $3}'`%"
  echo "内存占用率：`ps -aux | grep $NAME | grep -v grep | awk 'NR=='$i'{print $0}'| awk '{print $4}'`%"
  echo "进程开始运行的时刻：`ps -aux | grep $NAME | grep -v grep | awk 'NR=='$i'{print $0}'| awk '{print $9}'`"
  echo "进程运行的时间：` ps -aux | grep $NAME | grep -v grep | awk 'NR=='$i'{print $0}'| awk '{print $11}'`"
  echo "进程状态：`ps -aux | grep $NAME | grep -v grep | awk 'NR=='$i'{print $0}'| awk '{print $8}'`"
  echo "进程虚拟内存：`ps -aux | grep $NAME | grep -v grep | awk 'NR=='$i'{print $0}'| awk '{print $5}'`"
  echo "进程共享内存：`ps -aux | grep $NAME | grep -v grep | awk 'NR=='$i'{print $0}'| awk '{print $6}'`"
  echo "***************************************************************"
  let N-- i++
done