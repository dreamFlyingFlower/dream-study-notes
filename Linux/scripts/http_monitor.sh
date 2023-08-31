#!/bin/bash

################## 1 ##################


# 监控 HTTP 服务器的状态(测试返回码)

# 设置变量,url为你需要检测的目标网站的网址(IP 或域名),比如百度
url=http://183.232.231.172/index.html

# 定义函数 check_http:
# 使用 curl 命令检查 http 服务器的状态
# ‐m 设置curl不管访问成功或失败,最大消耗的时间为 5 秒,5 秒连接服务为相应则视为无法连接
# ‐s 设置静默连接,不显示连接时的连接速度、时间消耗等信息
# ‐o 将 curl 下载的页面内容导出到/dev/null(默认会在屏幕显示页面内容)
# ‐w 设置curl命令需要显示的内容%{http_code},指定curl返回服务器的状态码
check_http(){
	status_code=$(curl -m 5 -s -o /dev/null -w %{http_code} $url)
}

while :
do
	check_http
	date=$(date +%Y%m%d‐%H:%M:%S)
	# 生成报警邮件的内容
	echo "当前时间为:$date,$url 服务器异常,状态码为${status_code}.请尽快排查异常." > /tmp/http$$.pid

	# 指定测试服务器状态的函数,并根据返回码决定是发送邮件报警还是将正常信息写入日志
	if [ $status_code -ne 200 ];then
		mail -s Warning root < /tmp/http$$.pid
	else
		echo "$url 连接正常" >> /var/log/http.log
	fi
	sleep 5
done


################## 2 ##################


# 检查网站是否异常:参数1为需要检测的url地址
# 加载系统函数库
[ -f /etc/init.d/functions ]&&. /etc/init.d/functions
usage(){
	echo "USAGE:$0 url"
	exit 1
}

checkNetwork(){
	# 方法1,ping2次,每次等待2秒
	CMD="ping -W 2 -c 2"
	IP="192.168.1."
	for i in $(seq 254); do
		$CMD $IP$i > /dev/null
		if [ $? -eq 0 ]; then
			echo $IP$i is ok
		fi
	done
	# 方法2,nmap ping网段,nmap需要安装
	nmap -sP 10.0.0.0/24
	# 方式3,nc
	nc -w 2 $1 -z 1-100
}


################## 3 ##################


# 检查网站是否异常:参数1为需要检测的url地址
# 加载系统函数库
[ -f /etc/init.d/functions ] &&. /etc/init.d/functions
usage(){
	echo "USAGE:$0 url"
	exit 1
}

RETVAL=0
checkUrl(){
	# 方法1
	# -T:超时时间,单位s;-t:重试次数
	wget -T 10 --spider -t 2 $1 &>/dev/null
	# 方法2
	# STATUS=`curl -sL $1 -o /dev/null -w "{http_code}\n"|grep -E "200|302"|wc -l`,判断STATUS=1成功
	# 方法3,查看端口号
	# STATUS=`netstat -lntup|grep -w 80|wc -l`,判断STATUS>=1成功
	RETVAL=$?
	if [ $RETVAL -eq 0 ]; then
		# 成功
		action "$1 url" /bin/true
	else
		action "$1 url" /bin/false
	fi
	return $RETVAL
}
main(){
	if [ $# -ne 1 ]; then
		usage
	fi
	checkUrl $1
}
main $*


################## 4 ##################


# 查看有多少远程的 IP 在连接本机(不管是通过 ssh 还是 web 还是 ftp 都统计) 

# 使用 netstat ‐atn 可以查看本机所有连接的状态,‐a 查看所有,
# -t仅显示 tcp 连接的信息,‐n 数字格式显示
# Local Address(第四列是本机的 IP 和端口信息)
# Foreign Address(第五列是远程主机的 IP 和端口信息)
# 使用 awk 命令仅显示第 5 列数据,再显示第 1 列 IP 地址的信息
# sort 可以按数字大小排序,最后使用 uniq 将多余重复的删除,并统计重复的次数
netstat -atn  |  awk  '{print $5}'  | awk  '{print $1}' | sort -nr  |  uniq -c


################## 5 ##################


# 检测网卡流量,并按规定格式记录在日志中,一分钟记录一次 

while :
do
	# 设置语言为英文,保障输出结果是英文,否则会出现bug
	LANG=en
	logfile=/tmp/`date +%d`.log
	# 将下面执行的命令结果输出重定向到logfile日志中
	exec >> $logfile
	date +"%F %H:%M"
	# sar命令统计的流量单位为kb/s,日志格式为bps,因此要*1000*8
	sar -n DEV 1 59|grep Average|grep ens33|awk '{print $2,"\t","input:","\t",$5*1000*8,"bps","\n",$2,"\t","output:","\t",$6*1000*8,"bps"}'
	echo "####################"
	# 因为执行sar命令需要59秒,因此不需要sleep
done


################## 6 ##################


# 监控 httpd 的进程数,根据监控情况做相应处理
# 1.每隔10s监控httpd的进程数,若进程数大于等于500,则自动重启Apache服务,并检测服务是否重启成功
# 2.若未成功则需要再次启动,若重启5次依旧没有成功,则向管理员发送告警邮件,并退出检测
# 3.如果启动成功,则等待1分钟后再次检测httpd进程数,若进程数正常,则恢复正常检测(10s一次),否则放弃重启并向管理员发送告警邮件,并退出检测
  
#计数器函数  
check_service(){
	j=0
	for i in `seq 1 5`
	do
		# 重启Apache的命令
		/usr/local/apache2/bin/apachectl restart 2> /var/log/httpderr.log
		# 判断服务是否重启成功
		if [ $? -eq 0 ] then
			break
		else
			j=$[$j+1] 
		fi
		# 判断服务是否已尝试重启5次
		if [ $j -eq 5 ];then
			mail.py exit
		fi
	done
}
while :
do
	n=`pgrep -l httpd|wc -l`
	# 判断httpd服务进程数是否超过500
	if [ $n -gt 500 ] then
		/usr/local/apache2/bin/apachectl restart
		if [ $? -ne 0 ];then
			check_service
		else
			sleep 60
			n2=`pgrep -l httpd|wc -l`
			# 判断重启后是否依旧超过500
			if [ $n2 -gt 500 ]
			then
				mail.py exit
			fi
		fi
	fi
	# 每隔10s检测一次
	sleep 10
done  