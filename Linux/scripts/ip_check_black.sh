#!/bin/bash


################## 1 ##################


# iptables 自动屏蔽访问网站频繁的IP,根据访问日志,Nginx为例

DATE=$(date +%d/%b/%Y:%H:%M)
ABNORMAL_IP=$(tail -n5000 access.log |grep $DATE |awk '{a[$1]++}END{for(i in a)if(a[i]>100)print i}')

# 先tail防止文件过大,读取慢,数字可调整每分钟最大的访问量.awk不能直接过滤日志,因为包含特殊字符
for IP in $ABNORMAL_IP;
do
	if [ $(iptables -vnL |grep -c "$IP") -eq 0 ];then
    	iptables -I INPUT -s $IP -j DROP
	fi
done


################## 2 ##################


# iptables 自动屏蔽访问网站频繁的IP,通过TCP建立的连接

ABNORMAL_IP=$(netstat -an |awk '$4~/:80$/ && $6~/ESTABLISHED/{gsub(/:[0-9]+/,"",$5);{a[$5]++}}END{for(i in a)if(a[i]>100)print i}')

# gsub是将第五列（客户端IP）的冒号和端口去掉
for IP in $ABNORMAL_IP; do
    if [ $(iptables -vnL |grep -c "$IP") -eq 0 ]; then
        iptables -I INPUT -s $IP -j DROP
    fi
done


################## 3 ##################


# 屏蔽每分钟SSH尝试登录超过10次的IP,通过lastb获取登录状态

DATE=$(date +"%a %b %e %H:%M") #星期月天时分  %e单数字时显示7,而%d显示07
ABNORMAL_IP=$(lastb |grep "$DATE" |awk '{a[$3]++}END{for(i in a)if(a[i]>10)print i}')
for IP in $ABNORMAL_IP; do
	if [ $(iptables -vnL |grep -c "$IP") -eq 0 ]; then
		iptables -I INPUT -s $IP -j DROP
    fi
done


################## 4 ##################


# 屏蔽每分钟SSH尝试登录超过10次的IP,通过日志获取登录状态

DATE=$(date +"%b %d %H")
ABNORMAL_IP="$(tail -n10000 /var/log/auth.log |grep "$DATE" |awk '/Failed/{a[$(NF-3)]++}END{for(i in a)if(a[i]>5)print i}')"
for IP in $ABNORMAL_IP; do
    if [ $(iptables -vnL |grep -c "$IP") -eq 0 ]; then
        iptables -A INPUT -s $IP -j DROP
        echo "$(date +"%F %T") - iptables -A INPUT -s $IP -j DROP" >>~/ssh-login-limit.log
    fi
done


################## 5 ##################


# 根据web访问日志,封禁请求量异常的IP,如IP在半小时后恢复正常,则解除封禁

logfile=/data/log/access.log
# 显示一分钟前的小时和分钟  
d1=`date -d "-1 minute" +%H%M`
d2=`date +%M`
ipt=/sbin/iptables
ips=/tmp/ips.txt

block(){
    # 将一分钟前的日志全部过滤出来并提取IP以及统计访问次数
    grep '$d1:' $logfile|awk '{print $1}'|sort -n|uniq -c|sort -n > $ips
    # 利用for循环将次数超过100的IP依次遍历出来并予以封禁
    for i in `awk '$1>100 {print $2}' $ips`
    do
    $ipt -I INPUT -p tcp --dport 80 -s $i -j REJECT
    echo "`date +%F-%T` $i" >> /tmp/badip.log
    done
}

unblock(){
    # 将封禁后所产生的pkts数量小于10的IP依次遍历予以解封
    for a in `$ipt -nvL INPUT --line-numbers |grep '0.0.0.0/0'|awk '$2<10 {print $1}'|sort -nr`
    do
    $ipt -D INPUT $a
    done
    $ipt -Z
}

# 当时间在00分以及30分时执行解封函数
if [ $d2 -eq "00" ] || [ $d2 -eq "30" ]
then
    # 要先解再封,因为刚刚封禁时产生的pkts数量很少
    unblock
    block
else
    block
fi