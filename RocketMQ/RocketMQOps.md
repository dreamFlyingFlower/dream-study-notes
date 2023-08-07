# RocketMQOps



# 安装



## 服务安装



* 要求JDK1.8,Maven3.2,[下载地址](http://archive.apache.org/dist/rocketmq),按需下载版本,解压到/app/rocketmq中
* 修改bin/runserver.sh,根据服务器情况调整内存大小

```shell
set "JAVA_OPT=%JAVA_OPT% -server -Xms512m -Xmx512m -Xmn512m -XX:MetaspaceSize=128m -XX:MaxMetaspaceSize=320m" 
```

* 修改bin/runbroker.sh,调整磁盘利用率大小,默认磁盘空间超过85%不再接收消息

```shell
set "JAVA_OPT=%JAVA_OPT% -server -Drocketmq.broker.diskSpaceWarningLevelRatio=0.85 -Xms512m -Xmx512m -Xmn512m -XX:MetaspaceSize=128m -XX:MaxMetaspaceSize=320m"
```

* 启动NameServer:nohup sh mqnamesrv &

* 启动Broker:sh mqbroker -n 127.0.0.1:9876,-n指定nameserver的地址

* 查看NameServer日志:tail -f ~/logs/rocketmqlogs/namesrv.log

* 查看Broker日志:tail -f ~/logs/rocketmqlogs/broker.log

* 配置环境变量:vi /etc/profile,修改后source /etc/profile

  ```shell
  ROCKETMQ_HOME=/usr/local/rocketmq/rocketmq-all-4.4.0-bin-release
  PATH=$PATH:$ROCKETMQ_HOME/bin
  export ROCKETMQ_HOME PATH
  ```

* 发送消息

  ```sh
  # 设置环境变量
  export NAMESRV_ADDR=localhost:9876
  # 使用安装包的Demo发送消息
  sh bin/tools.sh org.apache.rocketmq.example.quickstart.Producer
  ```


* 接收消息

  ```shell
  # 设置环境变量
  export NAMESRV_ADDR=localhost:9876
  # 接收消息
  sh bin/tools.sh org.apache.rocketmq.example.quickstart.Consumer
  ```

* 关闭RocketMQ:sh bin/mqshutdown namesrv,sh bin/mqshutdown broker

* 防火墙设置:RocketMQ默认使用3个端口:9876,10911,11011

  * `nameserver` 默认使用 9876 端口
  * `master` 默认使用 10911 端口
  * `slave` 默认使用11011 端口




## Web界面安装



* [下载](https://github.com/apache/rocketmq-externals/tree/master/rocketmq-console),解压,是一个springboot的源码程序
* 修改application.properties中的rocketmq.config.namesrvAddr为RocketMQ服务的端口
* 打包成Jar:mvn clean package -Dmaven.test.skip=true
* 运行Jar包,访问ip:port



## 目录文件



* abort:该文件在Broker启动后会自动创建,正常关闭Broker,该文件消失.若没有启动Broker该文件就存在,说明Broker是非正常关闭,可能存在数据丢失
* checkpoint:存储commitlog,consumequeue,index文件的最后刷盘时间
* commitlot:存储commitlot文件,消息就写在commitlog文件中
* config:存储Broker运行期间的配置数据
* consumequeue:存储consumequeue文件,队列存储在该目录中
* index:消息索引文件indexFile
* lock:运行期间使用到的全局锁资源



## 配置文件



* conf目录下有多个配置文件:

  * 2m-2s-async:双主双从异步复制模式
  * 2m-2s-sync:双主双从同步双写模式
  * 2m-noslave:双主模式

* 双主模式:需要在broker-a.properties 与 broker-b.properties 末尾追加 NameServer 集群的地址

  ```properties
  # broker-a.properties
  # 集群名称,同一个集群下的 broker 要求统一
  brokerClusterName=DefaultCluster
  # broker名称,不同配置文件不一样
  brokerName=broker-a
  # brokerId=0 代表主节点,大于零代表从节点
  brokerId=0
  # 删除日志文件时间点,默认凌晨2点
  deleteWhen=02
  # 日志文件保留时间,默认48小时
  fileReservedTime=48
  # Broker的角色:ASYNC_MASTER->异步复制Master;SYNC_MASTER->同步双写Master;SLAVE->从节点
  brokerRole=SYNC_MASTER
  # 刷盘方式:ASYNC_FLUSH->异步刷盘,性能好宕机会丢数;SYNC_FLUSH->同步刷盘,性能较差不会丢数
  flushDiskType=SYNC_FLUSH
  # 末尾追加,NameServer节点列表,使用分号分割
  namesrvAddr=192.168.1.200:9876;192.168.1.201:9876
  # 在发送消息时,自动创建服务器不存在的topic,默认创建的队列数
  defaultTopicQueueNums=4
  # 是否允许 Broker 自动创建Topic,建议线下开启,线上关闭
  autoCreateTopicEnable=true
  # 是否允许 Broker 自动创建订阅组,建议线下开启,线上关闭
  autoCreateSubscriptionGroup=true
  # Broker 对外服务的监听端口
  listenPort=10911
  # commitLog每个文件的大小默认1G
  mapedFileSizeCommitLog=1073741824
  # ConsumeQueue每个文件默认存30W条,根据业务情况调整
  mapedFileSizeConsumeQueue=300000
  # destroyMapedFileIntervalForcibly=120000
  # redeleteHangedFileInterval=120000
  # 检测物理文件磁盘空间,超过该值不继续提供写服务
  diskMaxUsedSpaceRatio=88
  # 存储路径
  storePathRootDir=/app/data/rocketmq/store
  # commitLog 存储路径
  storePathCommitLog=/app/data/rocketmq/store/commitlog
  # 消费队列存储路径存储路径
  storePathConsumeQueue=/app/data/rocketmq/store/consumequeue
  # 消息索引存储路径
  storePathIndex=/app/data/rocketmq/store/index
  # checkpoint 文件存储路径
  storeCheckpoint=/app/data/rocketmq/store/checkpoint
  # abort 文件存储路径
  abortFile=/app/data/rocketmq/store/abort
  # 限制的消息大小
  maxMessageSize=65536
  # commitLog刷盘方式
  #flushCommitLogLeastPages=4
  #flushConsumeQueueLeastPages=2
  #flushCommitLogThoroughInterval=10000
  #flushConsumeQueueThoroughInterval=60000
  #checkTransactionMessageEnable=false
  # 发消息线程池数量
  #sendMessageThreadPoolNums=128
  # 拉消息线程池数量
  #pullMessageThreadPoolNums=128
  ```

  ```properties
  # broker-b.properties,只有brokerName不同,其他一样
  # 集群名称,同一个集群下的 broker 要求统一
  brokerClusterName=DefaultCluster
  # broker名称
  brokerName=broker-b
  # brokerId=0 代表主节点,大于零代表从节点
  brokerId=0
  # 删除日志文件时间点,默认凌晨2点
  deleteWhen=02
  # 日志文件保留时间,默认48小时
  fileReservedTime=48
  # Broker的角色:ASYNC_MASTER->异步复制Master;SYNC_MASTER->同步双写Master
  brokerRole=SYNC_MASTER
  # 刷盘方式:ASYNC_FLUSH->异步刷盘,性能好宕机会丢数;SYNC_FLUSH->同步刷盘,性能较差不会丢数
  flushDiskType=SYNC_FLUSH
  # 末尾追加,NameServer节点列表,使用分号分割
  namesrvAddr=192.168.1.200:9876;192.168.1.201:9876
  ```

  ```shell
  # 从节点配置broker-a-s.properties,broker-b-s.properties和a差不多,只有brokerName不同
  brokerClusterName=DefaultCluster
  # broker名字,注意此处的名称要和所属主节点名称相同
  brokerName=broker-a
  brokerId=1
  namesrvAddr=192.168.1.200:9876;192.168.1.201:9876
  defaultTopicQueueNums=4
  autoCreateTopicEnable=true
  autoCreateSubscriptionGroup=true
  listenPort=11011
  deleteWhen=02
  fileReservedTime=48
  mapedFileSizeCommitLog=1073741824
  mapedFileSizeConsumeQueue=300000
  diskMaxUsedSpaceRatio=88
  storePathRootDir=/app/data/rocketmq/store
  storePathCommitLog=/app/data/rocketmq/store/commitlog
  storePathConsumeQueue=/app/data/rocketmq/store/consumequeue
  storePathIndex=/app/data/rocketmq/store/index
  storeCheckpoint=/app/data/rocketmq/store/checkpoint
  abortFile=/app/data/rocketmq/store/abort
  maxMessageSize=65536
  # 从节点此处为SLAVE
  brokerRole=SLAVE
  flushDiskType=ASYNC_FLUSH
  ```

* 根据需求修改启动脚本中的内存使用大小

  ```shell
  # runserver.sh
  JAVA_OPT="${JAVA_OPT} -server -Xms256m -Xmx256m -Xmn128m -XX:MetaspaceSize=128m -XX:MaxMetaspaceSize=320m"
  ```

* 双主启动:在a,b的broker上执行:-c表示使用哪个配置文件

  ```shell
  # 启动master-a
  nohup sh mqbroker -c rocketmq/conf/2m-2s-syncbroker-a.properties &
  # 启动slave-b
  nohup sh mqbroker -c rocketmq/conf/2m-2s-sync/broker-b-s.properties &
  # 启动master-b
  nohup sh mqbroker -c rocketmq/conf/2m-2s-sync/broker-b.properties &
  # 启动slave-a
  nohup sh mqbroker -c rocketmq/conf/2m-2s-sync/broker-a-s.properties &
  ```

* 查看集群状态:`sh mqadmin clusterList -n nameserverip:port`

* 使用RocketMQ自带的tools.sh工具通过生成演示数据来测试MQ生产者实际的运行情况

  ```shell
  export NAME_ADDR = 192.168.0.150:9876(nameserver地址)
  sh tools.sh org.apache.rocketmq.example.quickstart.Producer
  ```

* 如果broker-a,broker-b交替出现,说明集群已经生效

* 测试消费者

  ```shell
  export NAME_ADDR = 192.168.0.150:9876(nameserver地址)
  sh tools.sh org.apache.rocketmq.example.quickstart.Consumer
  ```



## mqadmin管理工具



* 进入RocketMQ安装位置,在bin目录下执行`./mqadmin {command} {args}`



### Topic相关



* mqadmin updateTopic []:创建更新Topic配置
  * -b:Broker 地址,表示 topic 所在Broker,只支持单台Broker,地址为ip:port
  * -c:cluster 名称,表示 topic 所在集群,集群可通过clusterList 查询
  * -h:帮助
  * -n:NameServer服务地址,格式 ip:port
  * -p:指定新topic的读写权限( W=2|R=4|WR=6 )
  * -r:可读队列数,默认为 8
  * -w:可写队列数,默认为 8
  * -t:topic 名称.名称只能使用字符^[a-zA-Z0-9_-]+$
* mqadmin deleteTopic []:删除Topic
  * -c:cluster 名称,表示删除某集群下的某个 topic ,集群可通过 clusterList 查询
  * -h:帮助
  * -n:NameServer服务地址
  * -t:topic 名称
* mqadmin topicList []:查看Topic列表信息
  * -c:不配置-c只返回topic列表,增加-c返回clusterName,topic,consumerGroup信息,即topic的所属集群和订阅关系,没有参数
  * -c clustername:查看指定集群名下的主题
  * -n NameServer服务地址:查看指定NameServer下的主题
* mqadmin topicRoute []:查看Topic路由信息
  * -n:NameServer服务地址
  * -t:topic 名称
* mqadmin topicStauts []:查看Topic消息队列offset
  * -n:NameServer服务地址
  * -t:topic 名称
* mqadmin topicClusterList []:查看 Topic 所在集群列表
  * -n:NameServer服务地址
  * -t:topic 名称
* mqadmin updateTopicPerm []:更新 Topic 读写权限
  * -n:NameServer服务地址
  * -t:topic 名称
  * -b:Broker 地址,表示 topic 所在Broker,只支持单台Broker,地址为ip:port
  * -c:cluster 名称,表示 topic 所在集群,-b优先,如果没有-b,则对集群中所有Broker执行命令
  * -p:指定新topic的读写权限( W=2|R=4|WR=6 )
* mqadmin updateOrderConf []:从NameServer上创建、删除、获取特定命名空间的kv配置
  * -n:NameServer服务地址
  * -t:topic 名称,键
  * -v:orderConf,值
  * -m:method,可用get,put,delete
* mqadmin allocateMQ []:以平均负载算法计算消费者列表负载消息队列的负载结果
  * -n:NameServer服务地址
  * -t:topic 名称
  * -i:ipList,用逗号分隔,计算这些ip去负载Topic的消息队列
* mqadmin statsAll []:打印Topic订阅关系、TPS、积累量、24h读写总量等信息
  * -n:NameServer服务地址
  * -t:topic 名称
  * -a:是否只打印活跃Topic



### Cluster相关



* mqadmin clusterList []:查看集群信息,集群、BrokerName、BrokerId、TPS等信息

  * -n:NameServer服务地址

  * -i:打印间隔,单位秒

  * -m:打印更多信息 (增加打印出如下信息 #InTotalYest, #OutTotalYest, #InTotalToday ,#OutTotalToday)

* mqadmin clusterListRT []:发送消息检测集群各Broker RT,消息发往${BrokerName} Topic

  * -n:NameServer服务地址

  * -p: 是否打印格式化日志,以|分割,默认不打印

  * -a:amount,每次探测的总数,RT = 总时间 / amount
  * -s: 消息大小,单位B
  * -c: 探测哪个集群
  * -m: 所属机房,打印使用
  * -i:发送间隔,单位秒



### Broker相关



* mqadmin updateBrokerConfig []: 更新 Broker 配置文件,会修改Broker.conf

  * -n:NameServer服务地址

  * -b: Broker 地址,格式为ip:port

  * -c: cluster名称
  * -k: key值
  * -v: value值

* mqadmin  brokerStatus []: 查看 Broker 统计信息、运行状态

  * -n:NameServer服务地址

  * -b: Broker 地址,格式为ip:port

* mqadmin brokerConsumeStats []: Broker中各个消费者的消费情况,按Message Queue维度返回Consume Offset,Broker Offset,Diff,TImestamp等信息

  * -n:NameServer服务地址
  * -b: Broker 地址,格式为ip:port

  * -t: 请求超时时间

  * -l: diff阈值,超过阈值才打印
  * -o: 是否为顺序topic,一般为false

* mqadmin getBrokerConfig []: 获取Broker配置

  * -n:NameServer服务地址

  * -b: Broker 地址,格式为ip:port

* mqadmin  wipeWritePerm []: 从NameServer上清除 Broker写权限

  * -n:NameServer服务地址

  * -b: Broker 地址,格式为ip:port

* mqadmin cleanExpiredCQ []: 清理Broker上过期的Consume Queue,如果手动减少对列数可能产生过期队列

  * -n:NameServer服务地址

  * -b: Broker 地址,格式为ip:port
  * -c: cluster名称

* mqadmin cleanUnusedTopic []: 清理Broker上不使用的Topic,从内存中释放Topic的Consume Queue,如果手动删除Topic会产生不使用的Topic

  * -n:NameServer服务地址

  * -b: Broker 地址,格式为ip:port

  * -c: cluster名称

* mqadmin  sendMsgStatus []: 向Broker发消息,返回发送状态和RT

  * -n:NameServer服务地址

  * -b: BrokerName

  * -s: 消息大小,单位B
  * -c: 发送次数



### 消息相关



* mqadmin queryMsgById []: 清根据offsetMsgId查询msg,如果使用开源控制台,应使用offsetMsgId,此命令还有其他参数,具体作用请阅读QueryMsgByIdSubCommand

  * -n: NameServer服务地址

  * -i: msgId

* mqadmin  queryMsgByKey []: 根据消息 Key 查询消息

  * -n:NameServer服务地址

  * -k: msgKey

  * -t: Topic名称

* mqadmin queryMsgByOffset []: 根据 Offset 查询消息

  * -n:NameServer服务地址

  * -b: Broker 名称

  * -i: query队列id
  * -o: offset值
  * -t: Topic名称

* mqadmin  queryMsgByUniqueKey  []: 根据msgId查询

  * -n:NameServer服务地址

  * -i: unique msg id

  * -t: Topic名称
  * -g: consumerGroup
  * -d: clientId

* mqadmin checkMsgSendRT []: 检测向topic发消息的RT,功能类似clusterRT

  * -n:NameServer服务地址

  * -t: Topic名称

  * -s: 消息大小,单位B
  * -a: 发送次数

* mqadmin  sendMessage []: 发送一条消息,可以根据配置发往特定Message Queue,或普通发送

  * -n:NameServer服务地址

  * -b: BrokerName

  * -t: Topic名称
  * -p: body,消息体
  * -k: keys
  * -c: tags
  * -i: queueId

* mqadmin consumeMessage []: 消费消息.可以根据offset、开始&结束时间戳、消息队列消费消息,配置不同执行不同消费逻辑,详见ConsumeMessageCommand

  * -n: NameServer服务地址

  * -b: BrokerName

  * -t: Topic名称
  * -i: queueId
  * -o: offset值
  * -g: consumerGroup
  * -s: 开始时间戳,格式详见-h
  * -d: 结束时间戳
  * -c: 消费多少条消息

* mqadmin  printMsg []: 从Broker消费消息并打印,可选时间段

  * -n:NameServer服务地址

  * -t: Topic名称

  * -c: 字符集,如UTF-8
  * -s: subExpress,过滤表达式
  * -b: 开始时间戳,格式详见-h
  * -e: 结束时间戳
  * -d: 是否打印消息体

* mqadmin printMsgByQueue []: 类似printMsg,但指定Message Queue

  * -n: NameServer服务地址

  * -i: queueId

  * -t: Topic名称
  * -a: BrokerName
  * -c: 字符集,如UTF-8
  * -s: subExpress,过滤表达式
  * -b: 开始时间戳,格式详见-h
  * -e: 结束时间戳
  * -p: 是否打印消息
  * -d: 是否打印消息体
  * -f: 是否统计tag数量并打印

* mqadmin  resetOffsetByTime []: 按时间戳重置offset,Broker和consumer都会重置

  * -n: NameServer服务地址

  * -g: 消费者分组
  * -t: Topic名称

  * -s: 重置为此时间戳对应的offset
  * -f: 是否强制重置,如果false,只支持回溯offset,如果true,不管时间戳对应offset与consumeOffset关系
  * -c: 是否重置c++客户端offset



### 消费者、消费组相关



* mqadmin  consumerProgress []: 查看订阅组消费状态,可以查看具体的client IP的消息积累量

  * -n: NameServer服务地址

  * -g: 消费者分组

  * -s: 是否打印client IP

* mqadmin  consumerStatus []: 查看消费者状态,包括同一个分组中是否都是相同的订阅,分析Process Queue是否堆积,返回消费者jstack结果,内容较多,参见ConsumerStatusSubCommand

  * -n: NameServer服务地址

  * -g: 消费者分组
  * -i: ClientId

  * -s: 是否执行jstack

* mqadmin  getConsumerStatus []: 获取 Consumer 消费进度

  * -n: NameServer服务地址

  * -g: 消费者分组
  * -t: Topic名称

  * -i: Consumer 客户端 ip

* mqadmin  updateSubGroup []: 更新或创建订阅关系

  * -n: NameServer服务地址
  * -b: Broker地址
  * -c: 集群名称

  * -g: 消费者分组
  * -s: 分组是否允许消费

  * -m: 是否从最小offset开始消费
  * -d: 是否是广播模式
  * -q: 重试队列数量
  * -r: 最大重试次数
  * -i: 当slaveReadEnable开启时有效,且还未达到从slave消费时建议从哪个BrokerId消费,可以配置备机id,主动从备机消费
  * -w: 如果Broker建议从slave消费,配置决定从哪个slave消费,配置BrokerId,例如1
  * -a: 当消费者数量变化时是否通知其他消费者负载均衡

* mqadmin  deleteSubGroup []: 从Broker删除订阅关系

  * -n: NameServer服务地址
  * -b: Broker地址
  * -c: 集群名称

  * -g: 消费者分组

* mqadmin  cloneGroupOffset []: 在目标群组中使用源群组的offset

  * -n: NameServer服务地址

  * -d: 目标消费者组
  * -t: Topic名称

  * -s: 源消费者组



### 连接相关



* mqadmin  consumerConnection []: 查询 Consumer 的网络连接

  * -n: NameServer服务地址

  * -g: 消费者分组名

* mqadmin  producerConnection []: 查询 Producer 的网络连接

  * -n: NameServer服务地址

  * -g: 生产者所属组名
  * -t: Topic名称



### NameServer相关



* mqadmin  updateKvConfig []: 更新NameServer的kv配置

  * -n: NameServer服务地址

  * -s: 命名空间
  * -k: Key

  * -v: Value

* mqadmin  deleteKvConfig []: 删除NameServer的kv配置

  * -n: NameServer服务地址

  * -s: 命名空间
  * -k: Key

* mqadmin  getNamesrvConfig []: 获取NameServer配置

  * -n: NameServer服务地址

* mqadmin  updateNamesrvConfig []: 修改NameServer配置

  * -n: NameServer服务地址

  * -k: Key

  * -v: Value



### 其他



* mqadmin  startMonitoring []: 开启监控进程,监控消息误删、重试队列消息数等
  * -n: NameServer服务地址



# 系统配置



## JVM选项



* 设置Xms和Xmx一样大,防止JVM重新调整堆空间大小影响性能

  ```shell
  -server -Xms8g -Xmx8g -Xmn4g
  ```

* 设置DirectByteBuffer内存大小,当DirectByteBuffer占用达到这个值,就会触发Full GC

  ```shell
  -XX:MaxDirectMemorySize=15g
  ```

* 如果不太关心RocketMQ的启动时间,可以设置pre-touch,这样在JVM启动的时候就会分配完整的页空间

  ```shell
  -XX:+AlwaysPreTouch
  ```

* 禁用偏向锁,因为偏向锁在获取锁之前会判断当前线程是否拥有锁,如果有,就不再获取锁.在并发小时使用有利于提升JVM效率,在高并发场合禁用掉

  ```java
  -XX:-UseBiasedLocking
  ```

* 如果分配给RocketMQ的内存超过4G,推荐使用G1回收器.当在GC日志中看到 to-space overflow 或者 to-space exhausted 时,表示G1没有足够的内存使用,这时候表示Java堆已经达到了最大值.为了解决这个问题,可以做以下调整:

  * 增加预留内存:增大参数 -XX:G1ReservePercent 的值(相应的增加堆内存)来增加预留内存
  * 更早的开始标记周期:减小 -XX:InitiatingHeapOccupancyPercent 参数的值,以更早的开 始标记周期
  * 增加并发收集线程数:增大 -XX:ConcGCThreads 参数值,以增加并行标记线程数

* 对G1而言,大小超过region大小50%的对象将被认为是大对象,这种大对象将直接被分配到老年代的humongous regions中,humongous regions是连续的region集合,StartsHumongous表记集合从那里开始,ContinuesHumongous标记连续集合

  * 在分配大对象之前,将会检查标记阈值,如果有必要的话,还会启动并发周期

  * 死亡的大对象会在标记周期的清理阶段和发生Full GC的时候被清理

  * 为了减少复制开销,任何转移阶段都不包含大对象的复制,在Full GC时,G1在原地压缩大对象

  * 因为每个独立的humongous regions只包含一个大对象,因此从大对象的结尾到它占用的最后一个region的结尾的那部分空间是没有被使用的,对于那些大小略大于region整数倍的对象,这些没有被使用的内存将导致内存碎片化

  * 如果因为大对象的分配导致不断的启动并发收集,并且这种分配使得老年代碎片化不断加剧,那么增加-XX:G1HeapRegionSize的值,这样大对象将不再被G1认为是大对象,它会走普通对象的分配流程

    ```shell
    # G1回收器将堆空间划分为1024个region,此选项指定堆空间region的大小
    -XX:+UseG1GC -XX:G1HeapRegionSize=16m -XX:G1ReservePercent=25 -XX:InitiatingHeapOccupancyPercent=30
    ```

  * 上述设置可能有点儿激进,但是对于生产环境,性能很好

* -XX:MaxGCPauseMillis不要设置的太小,否则JVM会使用小的年轻代空间以达到此设置的值,同时引起很频繁的minor GC



## Linux内核参数



* os.sh脚本在bin文件夹中列出了许多内核参数,可以进行微小的更改然后用于生产用途

* 下面的参数需要注意,更多细节请参考/proc/sys/vm/*的文档 

  * vm.extra_free_kbytes:告诉VM在后台回收(kswapd)启动的阈值与直接回收(通过分配进程)的阈值之间保留额外的可用内存.RocketMQ使用此参数来避免内存分配中的长延迟

  * vm.min_free_kbytes:如果将其设置为低于1024KB,将会巧妙的将系统破坏,并且系统在高负载下容易出现死锁

  * vm.max_map_count:限制一个进程可能具有的最大内存映射区域数.RocketMQ将使用mmap加载CommitLog和ConsumeQueue,因此建议将为此参数设置较大

  * vm.swappiness:定义内核交换内存页面的积极程度.较高的值会增加攻击性,较低的值会减少交换量.建议将值设置为10来避免交换延迟

  * File descriptor limits:RocketMQ需要为文件和网络连接打开文件描述符.建议设置文件描述符的值为655350

    ```shell
    echo '* hard nofile 655350' >> /etc/security/limits.conf
    ```

  * Disk scheduler:RocketMQ建议使用I/O截止时间调度器,它试图为请求提供有保证的延迟

    ```
    echo 'deadline' > /sys/block/${DISK}/queue/scheduler
    ```



# 集群



## 集群特点



- NameServer是一个几乎无状态节点,可集群部署,节点之间无任何信息同步

- Broker分为Master与Slave,一个Master可以对应多个Slave,但是一个Slave只能对应一个Master,Master与Slave的对应关系通过指定相同的BrokerName,不同的BrokerId来定义,BrokerId为0表示Master,非0表示Slave.Master也可以部署多个.每个Broker与NameServer集群中的所有节点建立长连接,定时注册Topic信息到所有NameServer
- Master角色的Broker支持读写,Slave角色的Broker仅支持读,也就是 Producer只能和Master角色的Broker连接写入消息;Consumer可以连接 Master角色的Broker,也可以连接Slave角色的Broker来读取消息
- Producer与NameServer集群中的其中一个节点(随机选择)建立长连接,定期从NameServer取Topic路由信息,并向提供Topic服务的Master建立长连接,且定时向Master发送心跳.Producer完全无状态,可集群部署
- Consumer与NameServer集群中的其中一个节点(随机选择)建立长连接,定期从NameServer取Topic路由信息,并向提供Topic服务的Master、Slave建立长连接,且定时向Master、Slave发送心跳.Consumer既可以从Master订阅消息,也可以从Slave订阅消息,订阅规则由Broker配置决定



## 多Master 



* 最简单的模式,同时也是使用最多的形式
* 优点是单个 Master 宕机或重启维护对应用无影响,在磁盘配置为 RAID10 时,即使机器宕机不可恢复情况下,由于 RAID10 磁盘非常可靠,同步刷盘消息也不会丢失,性能也是最高的
* 缺点是单台机器宕机期间,这台机器上未被消费的消息在机器恢复之前不可订阅,消息实时性会受到影响



## 多Master多Slave异步复制



* 每个 Master 配置一个 Slave,有多对 Master-Slave,HA 采用异步复制方式,主备有短暂消息毫秒级延迟,即使磁盘损坏只会丢失少量消息,且消息实时性不会受影响
* 同时 Master 宕机后,消费者仍然可以从 Slave 消费,而且此过程对应用透明,不需要人工干预,性能同多 Master 模式几乎一样
* 缺点是 Master 宕机,磁盘损坏情况下会丢失少量消息



## 多Master多Slave同步双写



* HA 采用同步双写方式,即只有主备都写成功,才向应用返回成功,该模式数据与服务都无单点故障
* Master 宕机情况下,消息无延迟,服务可用性与数据可用性都非常高
* 缺点是性能比异步复制模式低 10% 左右,发送单个消息的执行时间会略高,且目前版本在主节点宕机后,备机不能自动切换为主机



## 集群工作流程



* 启动NameServer,NameServer起来后监听端口,等待Broker、Producer、Consumer连上来,相当于一个路由控制中心
* Broker启动,跟所有的NameServer保持长连接,定时发送心跳包.心跳包中包含当前Broker信息(IP+端口等)以及存储所有Topic信息.注册成功后,NameServer集群中就有Topic跟Broker的映射关系
* 收发消息前,先创建Topic,创建Topic时需要指定该Topic要存储在哪些Broker上,也可以在发送消息时自动创建Topic
* Producer发送消息,启动时先跟NameServer集群中的其中一台建立长连接,并从NameServer中获取当前发送的Topic存在哪些Broker上,轮询从队列列表中选择一个队列,然后与队列所在的Broker建立长连接从而向Broker发消息
* Consumer跟Producer类似,跟其中一台NameServer建立长连接,获取当前订阅Topic存在哪些Broker上,然后直接跟Broker建立连接通道,开始消费消息



# 案例



## 电商下单支付



### 下单



1. 用户请求订单系统下单
2. 订单系统通过RPC/HTTP调用订单服务下单
3. 订单服务调用优惠券服务,扣减优惠券
4. 订单服务调用调用库存服务,校验并扣减库存
5. 订单服务调用用户服务,扣减用户余额
6. 订单服务完成确认订单



### 支付



1. 用户请求支付系统
2. 支付系统调用第三方支付平台API进行发起支付流程
3. 用户通过第三方支付平台支付成功后,第三方支付平台回调通知支付系统
4. 支付系统调用订单服务修改订单状态
5. 支付系统调用积分服务添加积分
6. 支付系统调用日志服务记录日志



### 关键点1



* 用户提交订单后,扣减库存成功、扣减优惠券成功、使用余额成功,但是在确认订单操作失败,需要对库存、库存、余额进行回退
* 如何保证数据的完整性
* 使用MQ保证在下单失败后系统数据的完整性



![](F:/repository/dream-study-notes/RocketMQ/img/034.png)



### 关键点2



* 用户通过第三方支付平台(支付宝、微信)支付成功后,第三方支付平台要通过回调API异步通知商家支付系统用户支付结果,支付系统根据支付结果修改订单状态、记录支付日志和给用户增加积分
* 商家支付系统如何保证在收到第三方支付平台的异步通知时,如何快速给第三方支付凭条做出回应



![](F:/repository/dream-study-notes/RocketMQ/img/035.png)

* 通过MQ进行数据分发,提高系统处理性能



![](F:/repository/dream-study-notes/RocketMQ/img/036.png)



### 新下单



![](F:/repository/dream-study-notes/RocketMQ/img/037.png)



#### 下单流程



![](F:/repository/dream-study-notes/RocketMQ/img/038.png)





* 校验订单
  * 校验订单是否存在
  * 校验订单中的商品是否存在
  * 校验下单用户是否存在
  * 校验商品单价是否合法
  * 校验订单商品数量是否合法

* 生成预订单
  * 设置订单状态为不可见
  * 核算运费是否正确
  * 计算订单总价格是否正确
  * 判断优惠券信息是否合法
  * 判断余额是否正确
  * 计算订单支付总价
  * 设置订单添加时间
  * 保存预订单
* 扣减库存
* 扣减优惠券
* 扣减用户余额



![](F:/repository/dream-study-notes/RocketMQ/img/039.png)



* 确认订单



#### 失败补偿



![](F:/repository/dream-study-notes/RocketMQ/img/040.png)





* 回退库存
* 回退优惠券
* 回退余额
* 取消订单



### 支付



#### 创建支付订单



![](F:/repository/dream-study-notes/RocketMQ/img/041.png)



#### 支付回调



![](F:/repository/dream-study-notes/RocketMQ/img/042.png)



* 支付成功后,支付服务payService发送MQ消息,订单服务、用户服务、日志服务需要订阅消息进行处理
* 订单服务修改订单状态为已支付
* 日志服务记录支付日志
* 用户服务负责给用户增加积分

* 接受订单支付成功消息