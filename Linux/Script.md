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



