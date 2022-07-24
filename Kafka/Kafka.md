# Kafka



# 概述



* Kafka由多个broker组成,每个broker是一个节点,可以认为是一台服务器
* 创建一个Topic,这个Topic可以划分为多个分区(Partition),每个Partition可以存在于不同的broker上,每个Partition就放一部分数据,数据是均匀地放在多个分区中的
* 每个分区中数据是严格按照顺序排列的,但多个分区中的顺序并不是严格的按照生产者放入消息的顺序排列
* 分区中的每条消息都会有一个唯一的offset做标识,只在当前分区中唯一
* 消费者可以以任意顺序消费分区中的消息,不需要按照消息在分区中的顺序进行消费.只要消息没有过期,可以重复消费消息
* 消费者消费消息之后,并不会立刻从队列中删除,而是指定时间后删除,默认7天,可配置
* 这就是天然的分布式消息队列,一个Topic的数据,是分散放在多个机器上的,每个机器就放一部分数据
* Kafka提供了HA机制,就是replica副本机制
* 每个Partition的数据都会同步到其他机器上,形成自己的多个replica副本
* 然后所有replica会选举一个leader出来,那么生产和消费都跟这个leader打交道,然后其他replica就是follower
* 写数据的时候,leader会负责把数据同步到所有follower上去,读的时候就直接读leader上数据即可
* 写数据时,生产者就写leader,其他follower主动从leader来pull数据,一旦所有follower同步好数据了,就会发送ack给leader,leader收到所有follower的ack之后,就会返回写成功的消息给生产者
* Kafka会均匀的将一个Partition的所有replica分布在不同的机器上,这样才可以提高容错性
* 消费者组:Kafka会把一条消息路由到组中的某一个服务,这样有助于消息的负载均衡,也方便扩展消费者
* 如果消费者组中有多个消费者,则同组中只会有一个收费消息.如果消费者在不同组中,则都会受到消息



# 组件



## Broker

* 节点,可以认为是一台服务器
* Kafka由多个节点组成,每个节点可以存储多个Topic
* 生产者将消息发送到Broker,消费者从Broker中消费消息
* 多个Broker组成集群,集群中的机器通过心跳检查服务是否还存活



## Topic

* 主题,主要用来区分消息和存储消息,Topic存在于Broker上
* 多个生产者可以向同一个或多个Topic发消息,多个消费者个可以消费同一个或多个Topic
* Topic有分区和副本的概念,主要是用来做高可用以及负载均衡
* Kafka的每一条消息都会归属于一个Topic



## Partition



* 分区,是主题下的逻辑概念,一个Topic可以有多个分区
* 每个分区都是一个有序的,不可变的消息序列,后续的新消息会不停的往后面添加,消费则是从头部开始
* 同一个Topic中的分区中的消息不一定顺序相同,多个分区之间消息顺序没有关系
* 分区中的每个消息都会被分配一个id(即offset),作为区分消息的唯一标识
* 分区中消息是存储在日志中,且严格有序的.该日志对应磁盘上个一个目录
* 一个日志由多个Segment(段)组成,每个Segment对应一个日志文件和一个索引文件
* 分区可以通过集群不停的水平扩展,还可以通过分区进行数据的并行处理



## Record



* 消息,由key和value组成,本质上是字节数组
* key的作用主要是根据指定的策略,将消息发送到指定的分区中.若对消息的消费策略没有要求,可不写



## Controller



* 控制器,也是一台Broker,主要是控制这台Broker之外的其他Broker
* 负责整个集群分区的状态,管理每个分区的副本状态,监听Zookeeper中数据变化并做出处理等
* 所有Broker也会监听控制器的状态,若控制器发生故障,会重新进行选举



## Consumer Group



* 消费者组
* 多个消费者可以属于同一个消费者组,但是一个消费者只能属于一个消费者组
* 消费者组最重要的功能是实现单播和广播
* 一个消费者组能确保其订阅的Topic的每个分区只被组内的一个消费者消费
* 如果不同的消费者组订阅了同一个Topic,他们之间是互不影响的
* Consumer从Partition中消费消息是顺序的,默认从头开始消费



# 模式



## 点对点

* 消费者主动从队列中拉取数据,消息收到后消息清除



## 发布/订阅

* 一条消息对应多个消费者,数据产生后,将推送给所有订阅的消费者



# 客户端



## AdminClient API



* 允许管理和检测Topic,Broker以及其他kafka对象



## Producer API



* 发布消息到1个或多个Topic



## Consumer API



* 订阅一个或多个Topic,并处理产生的消息



## Streams API



* 高效地将输入流转换到输出流



## Connector API



* 从一些源系统或应用程序中拉取数据到Kafka



# 安装



# 配置文件







# Shell命令



* 启动: bin/kafka-server-start.sh config/server.properties &
* 停止: bin/kafka-server-stop.sh
* 创建Topic: bin/kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 1 --partitions 1 --topic jiangzh-topic
* 查看已经创建的Topic信息: bin/kafka-topics.sh --list --zookeeper localhost:2181
* 发送消息: bin/kafka-console-producer.sh --broker-list 192.168.220.128:9092 --topic jiangzh-topic
* 接收消息: bin/kafka-console-consumer.sh --bootstrap-server 192.168.220.128:9092 --topic jiangzh-topic --from-beginning



# 消息重复消费

* 比如A服务消费了MQ中的消息,A刚要回复MQ时挂了,而MQ没有等到A的回复,那MQ就认为该消息还没被消费
* 当A服务重启的时候,发现上次消费了的消息还在,继续消费,此时就发生了重复消费
* 解决的办法是没有的,只能减少,比如每次消费前从Redis中查询该消息是否被消费,没有就继续消费,有就跳过.但该方法只是换汤不换药,若是在A服务向Redis中写消息的时候挂了,一样会出现重复消费



# 消息丢失





# 顺序消费

* 将需要进行顺序消费的数据都放在一个queue中,而不是放在多个queue中,即放在单个partition中



# 数据积压

* 临时增加queue数量