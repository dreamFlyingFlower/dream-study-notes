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



## Server.properties



* broker.id: brokerId,只能是数字,集群中唯一
* listeners: Kafka监听地址
* log.dirs: kafka存放数据的路径,可以是多个,逗号分割.每当创建新的partition时,都会选择在包含最少partitions的路径下选择
* zookeeper.connect: zookeeper集群地址,多个用逗号分割
* zookeeper.connection.timeout.ms: zookeeper连接超时时间
* message.max.bytes: server可以接收的消息最大尺寸.producer和consumer的该属性必须相同
* num.network.threads: server用来处理网络请求的网络线程数
* num.io.threads: server用来处理请求的IO线程数,该值至少等于硬盘的个数
* background.threads: 用于后台处理的线程数,例如文件删除
* queued.max.requests: 在网络线程停止读取新请求之前,可以排队等待IO线程处理的最大请求数
* host.name: broker的hostname.如果hostname已经设置,broker将只会绑定到该地址;如果不设置,将绑定到所有接口
* advertised.host.name: 如果设置,则将作为broker的hostname发往producer,consumer以及其他broker
* advertised.port: 该端口将给予producer,consumer以及其他broker,会在建立连接时用到.它仅在实际端口和server需要绑定的端口不一样时才需要设置
* socket.send.buffer.bytes: SO_SNDBUFF缓存大小,server进行socket连接所用
* socket.receive.buffer.bytes: SO_RCVBUFF缓存大小,server进行socket连接时所用
* socket.request.max.bytes: server允许的最大请求尺寸,避免server溢出,应该小于java heap size
* num.partitions: 如果创建topic时没有给出划分partitions个数,该数字将是topic下partitions数据的默认值
* log.segement.bytes: topic partition的日志存放在某个目录下诸多文件中,这些文件就爱你个partition的日志切分成一段一段的;该属性就是每个文件的最大尺寸.当尺寸达到该属性值时,就会创建新文件.该设置可由每个topic基础设置时覆盖
* log.roll.hours: 即使文件没有达到log.segment.bytes,只要文件创建时间达到此属性,就会创建新文件.该设置也可以由topic层面的设置进行覆盖
* log.cleanup.policy: 文件清除策略,默认delete
* log.retention.hours: 每个日志文件删除之前保存的时间,默认7天
* log.retention.bytes: 每个topic每个partition保存数据的总量.这个是每个partition的上限.如果log.retention.bytes和log.retention.hours都设置了,则任务一个超过上限都会删除segment文件
* log.retention.check.interval.ms: 检查日志分段文件的间隔时间,以确定是否文件属性达到删除要求
* log.cleaner.enable: 当该属性设置为false时,一旦日志的保存时间达到上限时,就会被删除;如果设置为true,则当保存属性达到上限时,就会进行log compaction(日志压缩)
* log.cleaner.threads: 进行日志压缩的线程数
* log.cleaner.io.max.bytes.per.second: 进行log compaction时,log cleaner可以拥有的最大IO数
* log.cleaner.io.buffer.size: log cleaner清除过程中针对日志进行索引化以及精简化所用到的缓存大小,最好设置大点
* log.cleaner.backoff.ms: 进行日志清理检查的时间间隔
* log.cleaner.min.cleanable.ratio: 这项配置控制log compactor试图清理日志的频率(假定log compaction是打开的).默认避免清理压缩超过50%的日志,这个比率绑定了备份日志所消耗的最大空间(50%的日志备份时压缩率为50%).更高的比率则意味着浪费消耗更少,也就可以更有效的清理更多的空间
* log.cleaner.delete.retention.ms: 保存压缩日志的最长时间,也是客户端消费消息的最长时间,和log.retention.minutes的区别在于一个控制未压缩数据,一个控制压缩后的数据;会被topic创建时的指定时间覆盖
* log.index.size.max.bytes: 每个log segment的最大尺寸.如果log尺寸达到该值,即使尺寸没有超过log.segment.bytes,也需要产生新的log segment
* log.index.interval.bytes: 当执行一次fetch后,需要一定的空间扫描最近的offset,设置的越大越好,一般默认值就可以
* log.flush.interval.messages: log文件sync到磁盘之前累积的消息条数.因为磁盘IO操作是一个慢操作,但又是一个数据可靠性的必要手段,所以检查是否需要固化到硬盘的时间间隔.需要在数据可靠性与性能之间做必要的权衡,如果此值过大,将会导致每次发sync的时间过长(IO阻塞),如果此值过小,将会导致fsync的时间较长(IO阻塞),fsync的次数较多,这也就意味着整体的client请求有一定的延迟,物理server故障,将会导致没有fsync的消息丢失
* log.flush.scheduler.interval.ms: 检查是否需要fsync的时间间隔
* log.flush.interval.ms: 仅仅通过interval来控制消息的磁盘写入时机是不足的,这个数用来控制fsync的时间间隔,如果消息量始终没有达到固化到磁盘的消息数,但是离上次磁盘同步的时间间隔达到阈值,也将触发磁盘同步
* log.delete.delay.ms: 文件在索引中清除后的保留时间,一般不需要修改
* auto.create.topics.enable controller.socket.timeout.ms controller.message.queue.s default.replication.factor replica.lag.time.max.ms replica max.messages replica .socket.timeout.ms replica .socket. receive. buffer.bytes true 30000 Int.MaxValue 1 10000 4000 30 * 1000 64 * 1024 是 否 允 许 自 动 创 建 topic, 如 果 是 真 的 ， 则 produce 或 者 fetch 不 存 在 的 topic 时 ， 会 自 动 创 建 这 个 topic, 否 则 需 要 使 用 命 令 行 创 建 topic partition 管 理 控 制 器 进 行 备 份 时 ， socket 的 超 时 时 间 。 controller-to-broker-channles 的 buffer 尺 寸 默 认 备 份 份 数 ， 仅 指 自 动 创 建 的 topics 如 果 一 个 fo № wer 在 这 个 时 间 内 没 有 发 送 fetch 请 求 ， leader 将 从 ISR 重 移 除 这 个 follower ， 并 认 为 这 个 follower 己 经 挂 了 如 果 一 个 replica 没 有 备 份 的 条 数 超 过 这 个 数 值 ， 则 leader 将 移 除 这 个 follower ， 并 认 为 这 个 follower 己 经 挂 了 leader 备 份 数 据 时 的 socket 网 络 请 求 的 超 时 时 间 备 份 时 向 leader 发 送 网 络 请 求 时 的 socket recei ve buffer



# Shell命令



* 启动: bin/kafka-server-start.sh config/server.properties &
* 停止: bin/kafka-server-stop.sh
* 创建Topic: bin/kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 1 --partitions 1 --topic dream-topic
* 查看已经创建的Topic信息: bin/kafka-topics.sh --list --zookeeper localhost:2181
* 发送消息: bin/kafka-console-producer.sh --broker-list 192.168.1.150:9092 --topic dream-topic
* 接收消息: bin/kafka-console-consumer.sh --bootstrap-server 192.168.1.150:9092 --topic dream-topic --from-beginning



# 消息重复消费



* 比如A服务消费了MQ中的消息,A刚要回复MQ时挂了,而MQ没有等到A的回复,那MQ就认为该消息还没被消费
* 当A服务重启的时候,发现上次消费了的消息还在,继续消费,此时就发生了重复消费
* 解决的办法是没有的,只能减少,比如每次消费前从Redis中查询该消息是否被消费,没有就继续消费,有就跳过.但该方法只是换汤不换药,若是在A服务向Redis中写消息的时候挂了,一样会出现重复消费



# 消息丢失





# 顺序消费

* 将需要进行顺序消费的数据都放在一个queue中,而不是放在多个queue中,即放在单个partition中



# 数据积压

* 临时增加queue数量



# 节点故障处理



* Kafka基本不会因为节点故障而丢失数据,因为有集群做保证
* Kafka的语义担保也很大程度上避免数据丢失
* Kafka会对消息进行集群内平衡,减少消息在某些节点热度过高



# Leader选举



* Kafka并没有采用多数投票来选举leader,而是在每个节点中维护一组Leader数据的副本(ISR,一个列表)
* Kafka会在ISR中选择一个速度比较快的设为Leader