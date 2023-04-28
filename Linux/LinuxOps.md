# Linux运维



# 系统性能监控



* uptime:同top
* vmstat:统计系统的CPU,内存,swap,io等情况
  * vmstat n1 n2:n1,n2分别表示采样频率和采样次数
  * CPU占用率很高,上下文切换频繁,说明系统有线程正在频繁切换
* pidstat [] n1  n2:细致观察进程,需要额外安装程序.主要监控CPU,IO,内存
  * n1:表示采样的时间间隔,单位秒
  * n2:采样次数
  * -p pid:指定监控的进程pid
  * -u:表示监控CPU
  * -t:显示线程



# 增加硬盘



## 虚拟机添加硬盘



* 添加一块SCSI硬盘,添加后看到不到,需要重启才可以看到



## 分区



* `lsblk -f`:查看新建的分区名称,假设此处为sdb
* `fdisk /dev/sdb`:对新增的硬盘进行处理,硬盘设备都是在dev中
  * 会提示是否需要帮助,输入m可以查看帮助,也可以直接输入n进入下一步,n表示新增一个分区
  * 输入n之后会有2个选项:e表示新增一个扩展分区,p表示一个主分区,此处可自行选择
  * 输入p,新增一个主分区
  * partition number(1-4):选择分区块1-4,输入1
  * 其他默认即可,之后会再次到Command,输入w即可
* 分区完成为sdb1,但是没有格式化



## 格式化



* `mkfs -t ext4 /dev/sdb1`:用mkfs格式化设备,ext4为磁盘类型.格式化之后会生成唯一标识符(一串UUID)



## 挂载



* 在根目录或其他目录中创建一个新的目录,将/dev/sdb1挂载到新的目录,如新目录为app
* `mount /dev/sdb1 /app`:挂载硬盘到app,但是重启之后该挂载关系将消除



## 自动挂载



* 修改/etc/fstab,可以永久挂载,不会因为重启而导致挂载失效

  ```shell
  # 设备地址		挂载目录	格式化类型		默认			默认
  /dev/sdb1    	   /app    	         ext4    		     defaults              0 1
  # 设备地址也可以写成UUID=sdb1的uuid,该uuid可以用lsblk -f查看
  ```

* mount -a:自动挂载,挂载生效



## 卸载挂载点



* 如需要修改挂载点,可以使用umount  /dev/sdb1或umount /app
* 修改/etc/fstab



# 常用软件

* /etc/profile:环境变量的配置文件,所有环境变量都在该文件中.可以使用$PATH来引用系统环境变量
* export:在系统变量中新增或删除指定内容,只在当前连接中有效
* $:引用该文件中的其他变量,多个环境变量之间用:分割
* source /etc/profle:重启环境变量



## JDK

* 解压jdk压缩包,如/app/jdk

* 编辑文件:vi /etc/profile,添加以下内容

  ```shell
  export JAVA_HOME=JDK的绝对路径
  export PATH=$JAVA_HOME/bin:$PATH
  # classpath在jdk低于1.7的时候需要配置
  export CLASSPATH=$JAVA_HOME/bin/dt.jar:$JAVA_HOME/bin/tools.jar
  ```

* 重启环境变量:source /etc/profile



## Tomcat

* 解压tomcat压缩包,如/app/tomcat

* 编辑文件:vi /etc/profile,添加如下内容

  ```shell
  export TOMCAT_HOME=tomcat的绝对路径
  export CATALINA_HOME=tomcat的绝对路径
  ```

* 重启环境变量:source /etc/profile




## Keepalived



### 概述



* 对应用进行负载均衡
* 若主挂掉,则由备顶上.当主恢复的时候,主会抢占资源,而不是一直在背上运行
* 若直接kill主的keepalived,则keepalived来不及删除主机上的虚拟网卡,而备机此时已经接受不到主的心跳,在备机上也会新建一个同样ip的网卡,这样就会出现2个相同的ip地址,造成ip冲突,这是一个小bug



### yum安装



```shell
yum -y install keepalived # 安装
service keepalived start # 启动
```

* 配置文件:/etc/keepalived/keepalived.conf
* 日志:/var/log/message



### 压缩包安装



* 先安装依赖: `yum install -y curl gcc openssl-devel libnl3-devel net-snmp-devel`

* 解压并安装

  ```shell
  tar -zxf keepalived.tar.gz
  cd keepalived
  ./configure --prefix=/usr/local/keepalived
  make && make install
  ```



### 配置为服务



```shell
mkdir /etc/keepalived
cp /usr/local/keepalived/etc/keepalived/keepalived.conf /etc/keepalived/
# 复制keepalived 服务脚本到默认的地址
cp /usr/local/keepalived/etc/rc.d/init.d/keepalived /etc/init.d/
cp /usr/local/keepalived/etc/sysconfig/keepalived /etc/sysconfig/
ln -s /usr/local/keepalived/sbin/keepalived /usr/sbin/
ln -s /usr/local/keepalived/sbin/keepalived /sbin/
# 设置keepalived 服务开机启动
chkconfig keepalived on
```



### 配置文件



* 基本分为3大块,每个都是一个大的对象,大括号和key之间的空白不能去掉

  ```shell
  vrrp_instance_VI_1 { # 中间的空白不能去掉
  	state MASTER # 是主机还是从机,从机则是BACKUP
  	interface eth0 # 使用的网卡
  	virtual_router_id 51 # 网络中一个标识
  	priority 100 # 优先级,master一般是100,背必须必主小,否则会有抢占
  	advert_int 1
  	authentication { # 主备之间进行通信的认证
  		auth_type PASS
  		auth_pass 1111
  	}
  	virtual_ipaddress {
  		# 可以只写IP,24为子网掩码,dev表示网卡设备为eth0,label表示标签的子接口
  		# ip1/24 dev eth0 label eth0:3
  	}
  }
  # virtual_server后面的是需要进行转发的服务器ip地址和端口,多个服务器写多个virtual_sever
  virtual_server 192.168.1.100 443 {
  	lb_algo rr # 主备之间切换的算法,rr表示轮询,还有其他算法,见keepalived文档
  	lb_kind DR # 模式
  	nat_mask 255.255.255.0 # 子网掩码
  	persistence_timeout 50 # 持久化时间,单位s,表示在50秒内同一个客户端访问lvs时,keepalived将会把请求转到同一台服务器上,而不是进行轮询,这样可以节省资源
  	protocol TCP # 协议类型
  }
  ```





## Prometheus

![](F:\repository\dream-study-notes\Linux\Prometheus01.png)



### 概述

* 开源监控工具,主要是度量工具
* 时间序列数据库,由golang实现
* 多维度标签,pull模式(相对应的还有push模式)
* 白盒,黑盒监控都支持,DevOps友好
* Metrics & Alert,不是logging/tracing
* 单机性能每秒消费百万级时间序列,上千个targets
* 可整合Springboot



### Metrics种类

* Counter:计数.始终增加,http请求数,下单数
* Gauge:测量仪.当前值的一次快照测量,可增可减.磁盘使用率,当前同时在线用户数
* Histogram:直方图.通过分桶(bucket)方式统计样本分布
* Summary:汇总.根据样本统计出百分位,客户端计算



### AlertManager

* 告警,可以将信息推送到邮件,微信,短信
* 支持去重,分组和路由



## Grafana



* 作用同Prometheus,但功能,界面更友好,但Prometheus对docker,k8s支持更好



## ZMon



### 概述

* 分布式监控告警系统
* 拉模式
* Python定义Check/Alert
* DevOps团队自治



## Nethogs



* 查看进程占用带宽情况,网络流量监控工具,可以直观的显示每个进程占用的带宽



## IOZone



* 一款Linux文件系统性能测试工具,可以测试不同的操作系统中文件系统的读写性能
* 下载:`http://www.iozone.org/src/current/`



## Rancher



* Docker图形化界面管理



## Cadvisor



* 监控Docker容器



## SkyWalking



* 分布式系统的应用程序性能监控,服务追踪工具,专为微服务,云原生架构和基于容器的架构设计





# 挖矿病毒处理



* 参考:[ 挖矿木马分析之肉鸡竟是我自己_](https://blog.csdn.net/Appleteachers/article/details/117259776)

* `ps auxw|head -1;ps auxw|sort -rn -k3|head -10` :查看CPU占用最多的前10个进程

* `ls -ail /proc/PID`:查看占用最高的程序pid绝对路径,一般是在`root/.configrc/a/kswapd0*`

* `rm -rf .configrc/`:删除文件,如果提示无权限,可使用`chattr -i .configrc`赋权,如果chattr找不到,可以从其他正常的机器复制一个放到`/bin`下

* `kill -9 PID`:杀掉挖矿进程

* 查看定时任务,一般会有以下几个定时任务,全部干掉

  ```shell
  1 1 */2 * * /root/.configrc4/a/upd>/dev/null 2>&1
  @reboot /root/.configr4c/a/upd>/dev/null 2>&1
  5 8 * * 0 /root/.configrc4/b/sync>/dev/null 2>&1
  @reboot /root/.configrc4/b/sync>/dev/null 2>&1  
  0 0 */3 * * /tmp/.X25-unix/.rsync/c/aptitude>/dev/null 2>&1
  ```

* 把密钥登陆中的密钥删除了(`/root/.ssh`)

* 查看`/tmp`是否有`.X25-unix`目录,有就删除,没有就把`.unix`结尾的文件直接全删了

* 查看`/tmp`是否有kdevtmpfsi开头的文件,也是挖矿病毒,全部删除



