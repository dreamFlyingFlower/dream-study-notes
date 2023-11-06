# Script



* `clearLog`: 清除/var/log/messages日志
* `color`: 输出带颜色的文字
* `cpu_monitor`:
  * 负载高时,查出占用比较高的进程脚本并存储或推送通知
  * 获取当前cpu 内存 磁盘io信息,并写入日志文件
  * 查找 Linux 系统中的僵尸进程
* `dosattack`: 判断是否遭受Dos攻击,封禁ip,单个单个的封禁,可使用docstacks,封禁单个文件
* `dosattacks`: 判断是否遭受Dos攻击,使用centos7的ipset配置
* `expect`: 使用 expect 工具自动交互密码远程其他主机安装 httpd 软件,如果没有进行密钥绑定(~/.ssh/known_hosts),ssh 远程任何主机都会询问是否确认要连接该主机
* `file_check_md5`: 检测两台服务器指定目录下的文件一致性
* `file_monitor`: 关于文件的多个脚本
  * 根据 md5 校验码,检测文件是否被修改 
* `file_operate`: 将文件中所有的小写字母转换为大写字母 
* `ftp`: ftp监控
* `http_monitor`: 
  * 监控HTTP状态,并发邮件报警
  * 监控网站是否正常
  * 查看有多少远程的 IP 在连接本机(不管是通过 ssh 还是 web 还是 ftp 都统计)
* `log_operate`: 多种对日志的操作脚本
  *  查看有多少个IP访问
  * 查看某一个页面被访问的次数
  * 查看每一个IP访问了多少个页面,配合sort进一步排序
  * 将每个IP访问的页面数进行从小到大排序
  * 查看某一个IP访问了哪些页面
  * 去掉搜索引擎统计的页面
  * 查看指定时间内有多少IP访问
  * 查看访问前十个ip地址,uniq -c 相当于分组统计并把统计数放在最前面
  * 访问次数最多的10个文件或页面
  * 访问量最大的前20个ip
  * 通过子域名访问次数,依据referer来计算,稍有不准
  * 列出传输大小最大的几个文件
  * 列出输出大于200000byte(约200kb)的页面以及对应页面发生次数
  * 如果日志最后一列记录的是页面文件传输时间,则有列出到客户端最耗时的页面
  * 列出最最耗时的页面(超过60秒的)的以及对应页面发生次数
  * 列出传输时间超过 30 秒的文件
  * 列出当前服务器每一进程运行的数量,倒序排列
  * 查看apache当前并发访问数,对比httpd.conf中MaxClients的数字差距多少
  * 查看系统当前网络链接状态
  * 提取出已建立连接的信息
  * 输出每个ip的连接数,以及总的各个状态的连接数
  * 分析日志文件下 指定时间内访问页面最高的前20个 URL 并排序
  * 查询受访问页面的URL地址中 含有 www.abc.com 网址的 IP 地址
  * 获取访问最高的10个IP地址 同时也可以按时间来查询
  * 时间段查询日志时间段的情况
  * 分析 2015/8/15 到 2015/8/16 访问”/index.php?g=Member&m=Public&a=sendValidCode”的IP倒序排列
  * 列出最最耗时的页面(超过60秒的)的以及对应页面发生次数
  * 统计网站流量
  * 统计404的连接
  * 统计http status
  * 每秒并发
  * 带宽统计
  * 找出某天访问次数最多的10个IP
  * 当天ip连接数最高的ip都在干些什么
  * 小时单位里ip连接数最多的10个时段
  * 找出访问次数最多的几个分钟
  * 查看tcp的链接状态
  * 查找请求数前20个IP（常用于查找攻来源）
  * 用tcpdump嗅探80端口的访问看看谁最高
  * 查找较多time_wait连接
  * 找查较多的SYN连接
  * 根据端口列进程
  * 查看连接数和当前的连接数
  * 查看IP访问次数
  * Linux命令分析当前的链接状况
* `mysql_db_bak`: MySQL备份
* `mysql_monitor`: MySQL监控,检测MySQL是否存活,连接数等
* `mysql_slave`: MySQL主从配置
* `mysql_start`: MySQL启动脚本
* `nginx_monitor_log`: 
  * 切割 Nginx 日志文件
  * 统计访问最多的10个IP
  * 统计时间段访问最多的IP
  * 统计访问最多的10个页面
  * 统计访问页面状态码数量
* `nginx_start`: nginx 启动脚本 
* `random_password`: 生成随机密码
* `rsync`: 启动,停止rsync,并加入到自启动中.rsync启动时会在指定目录下新建一个pid文件,判断该文件是否存在判断rsync是否启动或停止
* `server_port_status`: 扫描主机端口状态
* `ssl_check`: 检查SSL证书是否到期,同时通知微信,需要加入到定时任务中.需要创建一个企业微信账号,并创建一个组,在组里面配置企业微信提供的机器人,将机器人提供的 WebHook 地址保存
* `statistics_gc`: 从 test.log 中截取当天的所有 gc 信息日志,并统计 gc 时间的平均值和时长最长的时间
* `svnBak`: SVN完全备份
* `tomcat_monitor`: 统计tomcat访问量,IP地址等
* `wxwarn`: 微信预警
* `zabbix_monitor`: 用于 Zabbix 监控 Linux 系统用户(shell 为 /bin/bash 和 /bin/sh)密码过期,密码有效期剩余 7 天触发加自动发现用户



# 简单脚本



- [ ] ```shell
  # 删除0字节文件
  find -type f -size 0 -exec rm -rf {} \;
  
  # 查看进程,按内存从大到小排列
  PS -e -o "%C : %p : %z : %a"|sort -k5 -nr
  
  # 按 CPU 利用率从大到小排列
  ps -e -o "%C : %p : %z : %a"|sort -nr
  
  # 打印 cache 里的URL
  grep -r -a jpg /data/cache/* | strings | grep "http:" | awk -F'http:' '{print "http:"$2;}'
  
  # 查看 http 的并发请求数及其 TCP 连接状态
  netstat -n | awk '/^tcp/ {++S[$NF]} END {for(a in S) print a, S[a]}'
  
  # sed 在这个文里 Root 的一行,匹配 Root 一行,将 no 替换成 yes
  sed -i '/Root/s/no/yes/' /etc/ssh/sshd_config
  
  # 如何杀掉 MySQL 进程
  ps aux |grep mysql |grep -v grep  |awk '{print $2}' |xargs kill -9
  killall -TERM mysqld
  kill -9 `cat /usr/local/apache2/logs/httpd.pid`   #试试查杀进程PID
  
  # 显示运行 3 级别开启的服务
  ls /etc/rc3.d/S* |cut -c 15-
  
  # 如何在编写 SHELL 显示多个信息,用 EOF
  cat << EOF
  +--------------------------------------------------------------+
  |       === Welcome to Tunoff services ===                  |
  +--------------------------------------------------------------+
  EOF
  
  # for 的巧用,给 MySQL 建软链接
  cd /usr/local/mysql/bin
  for i in *
  do ln /usr/local/mysql/bin/$i /usr/bin/$i
  done
  
  # 取 IP 地址
  ifconfig eth0 |grep "inet addr:" |awk '{print $2}'| cut -c 6-
  # 或者
  ifconfig | grep 'inet addr:'| grep -v '127.0.0.1' | cut -d: -f2 | awk '{ print $1}'
  
  # 内存的大小
  free -m |grep "Mem" | awk '{print $2}'
  
  # 查看指定端口是否正在使用
  netstat -an -t | grep ":80" | grep ESTABLISHED | awk '{printf "%s %s\n",$5,$6}' | sort
  
  # 查看 Apache 的并发请求数及其 TCP 连接状态
  netstat -n | awk '/^tcp/ {++S[$NF]} END {for(a in S) print a, S[a]}'
  
  # 统计服务器所有的 jpg 的文件的大小
  find / -name *.jpg -exec wc -c {} \;|awk '{print $1}'|awk '{a+=$1}END{print a}'
  
  # CPU 的数量,多核算多个CPU
  cat /proc/cpuinfo |grep -c processor
  
  # CPU负载
  cat /proc/loadavg
  
  # CPU负载
  mpstat 1 1
  
  # 内存空间
  free
  
  # 检查 free 值是否过低
  cat /proc/meminfo
  
  # SWAP 空间,观察 si 和 so 值是否较大
  free
  # 检查 swap used 值是否过高,如果 swap used 值过高,进一步检查 swap 动作是否频繁
  vmstat 1 5
  
  
  # 检查是否有分区使用率（Use%）过高（比如超过90%）如发现某个分区空间接近用尽,可以进入该分区的挂载点,用以下命令找出占用空间最多的文件或目
  df -h
  du -cks * | sort -rn | head -n 10
  
  # 磁盘 I/O 负载,检查I/O使用率（%util）是否超过 100%
  iostat -x 1 2
  
  # 网络负载,检查网络流量（rxbyt/s, txbyt/s）是否过高
  sar -n DEV
  
  # 网络错误,检查是否有网络错误（drop fifo colls carrier）,也可以用命令:# cat /proc/net/dev
  netstat -i
  
  # 网络连接数目
  netstat -an | grep -E “^(tcp)” | cut -c 68- | sort | uniq -c | sort -n
  
  # 进程总数
  ps aux | wc -l
  
  # 可运行进程数目,列给出的是可运行进程的数目,检查其是否超过系统逻辑 CPU 的 4 倍
  vmwtat 1 5
  
  # 网络状态,检查DNS,网关等是否可以正常连通
  ping traceroute nslookup dig
  
  # 用户,检查登录用户是否过多 (比如超过50个)   也可以用命令：# uptime
  who | wc -l
  
  # 系统日志
  cat /var/log/rflogview/*errors
  
  # 检查是否有异常错误记录,也可以搜寻一些异常关键字
  grep -i error /var/log/messages
  grep -i fail /var/log/messages
  
  # 核心日志
  dmesg
  
  # 打开文件数目
  lsof | wc -l
  
  # 日志
  # logwatch –print
  # 配置 /etc/log.d/logwatch.conf,将 Mailto 设置为自己的 email 地址,启动 mail 服务(sendmail或者postfix),这样就可以每天收到日志报告了
  # 缺省 logwatch 只报告昨天的日志,可以用 # logwatch –print –range all 获得所有的日志分析结果
  # 可以用 logwatch –print –detail high 获得更具体的日志分析结果(而不仅仅是出错日志)
  
  # 杀掉80端口相关的进程
  lsof -i :80|grep -v “ID”|awk ‘{print “kill -9”,$2}’|sh
  
  # 清除僵死进程
  ps -eal | awk '{ if ($2 == "Z") {print $4}}' | kill -9
  
  # tcpdump 抓包,用来防止80端口被人攻击时可以分析数据
  tcpdump -c 10000 -i eth0 -n dst port 80 > /root/pkts
  
  # 然后检查IP的重复数并从小到大排序 注意 “-t\ +0”   中间是两个空格
  less pkts | awk {'printf $3"\n"'} | cut -d. -f 1-4 | sort | uniq -c | awk {'printf $1" "$2"\n"'} | sort -n -t\ +0
  
  # 查看有多少个活动的 php-cgi 进程
  netstat -anp | grep php-cgi | grep ^tcp | wc -l
  
  # 查看系统自启动的服务
  chkconfig --list | awk '{if ($5=="3:on") print $1}'
  
  # kudzu 查看网卡型号
  kudzu --probe --class=network
  ```



