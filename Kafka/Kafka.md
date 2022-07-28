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



# 核心



## Leader选举



* Kafka并没有采用多数投票来选举leader,而是在每个节点中维护一组Leader数据的副本(ISR,一个列表)
* Kafka会在ISR中选择一个速度比较快的设为Leader,ISR列表中的follower数据和leader相同
* 如果ISR全部宕机,Kafka会进行unclean leader选举(脏选举):
  * 等待follower或leader自动上线,或人工干预.该方法可以保证数据的完整性
  * 使用ISR之外的其他follower作为leader,无法保证数据的完整性
* 生产中应禁用unclean leader,同时手动指定最小ISR



# 安装



# 配置文件



## Server



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
* auto.create.topics.enable: 是否允许自动创建topic, 如果为true,则produce或者fetch不存在的topic时,会自动创 建这个topic,否则需要使用命令行创建topic
* controller.socket.timeout.ms: partition管理控制器进行备份时,socket的超时时间
* controller.message.queue.size: controller-to-broker-channles的buffer尺寸
* default.replication.factor: 默认备份份数,仅指自动创建的topics
* replica.lag.time.max.ms: 如果一个follower在这个时间内没有发送fetch请求,leader将从ISR中移除这个follower, 并认为这个follower己经挂了
* replica.lag.max.messages: 如果一个replica没有备份的条数超过这个数值,则leader将移除这个follower,并认为这个follower己经挂了
* replica.socket.timeout.ms: leader备份数据时的socket网络请求的超时时间 
* replica.socket.receive.buffer.bytes: 备份时向leader发送网络请求时的socket receive buffer
* replica.fetch.max.bytes: 备份时每次fetch 的最大值
* replica.fetch.wait.max.ms: leader 发出备份请求时,数据到达 leader的最长等待时间
* replica.fetch.min.bytes: 备份时每次 fetch之后回应的最小尺寸,默认1
* num.replica.fetchers: 从leader备份数据的线程数,默认1
* replica.high.watermark.checkpoint.interval.ms: 每个replica检查是否将最高水位进行固化的频率,默认5000
* fetch.purgatory.purge.interval.requests: fetch请求清除时的清除间隔,默认1000
* producer.purgatory.purge.interval.requests: producer请求清除时的清除间隔,默认1000
* zookeeper.session.timeout.ms: zookeeper会话超时时间,默认6000
* zookeeper.connection.timeout.ms: 客户端等待和zookeeper建立连接的最大时间,默认6000
* zookeeper.sync.time.ms: zk follower落后于zk leader的最长时间,默认2000
* controlled.shutdown.enable: 是否能够控制broker的关闭.如果true, broker将可以移动所有leaders到其他的 broker 上,在关闭之前,这减少了不可用性在关机过程中.默认true
* controlled.shutdown.max.retries: 在执行不彻底的关机之前,可以成功执行关机的命令数,默认3
* controlled.shutdown.retry.backoff.ms =5000: 每次关闭尝试的时间间隔
* auto.leader.rebalance.enable =true: 是否自动平衡broker之间的分配策略
* leader.imbalance.per.broker.percentage =10: 每个broker允许leader的不平衡比例,若是超过这个数值,会对分区进行重新的平衡
* leader.imbalance.check.interval.seconds =300: 检查leader是否不平衡的时间间隔
* offset.metadata.max.bytes = 4096: 客户端保留offset信息的最大空间大小
* max.connections.per.ip: 每个ip地址上每个broker可以被连接的最大数
* max.connections.per.ip.overrides: 每个ip或hostname默认的连接的最大覆盖
* connections.max.idle.ms = 60000: 空连接的超时限制
* num.recovery.threads.per.data.dir = 1: 每个数据目录用来日志恢复的线程数
* unclean.leader.ecection.enable = true: 指明了是否能够使不在ISR中replicas设置用来作为leader
* delete.topic.enable = false: 是否能够删除topic
* offsets.topic.retention.minutes = 1440: 存在时间超过这个时间限制的offsets都将被标记为待删除
* offsets.retention.check.interval.ms = 600000: offset管理器检查陈旧offsets的频率
* offsets.topic.replication.factor = 3: topic的offset的备份份数,建议设置更高的数字保证更高的可用性
* offset.topic.segment.bytes = 104857600: offsets topic的segment尺寸
* offsets.load.buffer.size = 5242880: 这项设置与批量尺寸相关,当从offsets segment中读取时使用
* offsets.commit.required.acks = -1: 在offset  commit可以接受之前,需要设置确认的数目,一般不需要更改
* cleanup.policy = delete: 全局默认值为server.properties的log.cleanup.policy,指明了针对旧日志部分的利用方式
  * delete: 默认,将会丢弃旧的部分当他们的回收时间或者尺寸限制到达时
  * compact: 将会进行日志压缩

* delete.retention.ms = 86400000: 全局默认值为server.properties的log.cleaner.delete.retention.ms,对于压缩日志保留的最长时间,也是客户端消费消息的最长时间,同log.retention.minutes的区别在于一个控制未压缩数据,一个控制压缩后的数据.此项配置可以在topic创建时的置顶参数覆盖
* flush.messages: 全局默认值为server.properties的log.flush.interval.messages,此项配置指定文件刷新次数间隔:强制进行fsync日志.例如,如果这个选项设置为1,那么每条消息之后都需要进行fsync,如果设置为5,则每5条消息就需要进行一次fsync.此参数的设置,需要在数据可靠性与性能之间做必要的权衡,如果此值过大,将会导致每次fsync的时间较长(IO阻塞),如果此值过小,将会导致fsync的次数较多,这也意味着整体的client请求有一定的延迟.物理server故障,将会导致没有fsync的消息丢失
* flush.ms: 全局默认值为server.properties的log.flush.interval.ms,此项配置用来置顶强制进行fsync日志到磁盘的时间间隔,单位ms
* index.interval.bytes = 4096: 全局默认值为server.properties的log.index.interval.bytes,默认设置保证了每4096个字节就对消息添加一个索引,更多的索引使得阅读的消息更加靠近,但是索引规模却会由此增大.一般不需要改变这个选项
* max.message.bytes = 1000000: 全局默认值为server.properties的max.message.bytes,kafka追加消息的最大尺寸.如果增大这个尺寸,也必须增大consumer的fetch 尺寸,这样consumer才能fetch到这些最大尺寸的消息
* min.cleanable.dirty.ratio = 0.5: 全局默认值为server.properties的min.cleanable.dirty.ratio,此项配置控制log压缩器试图进行清除日志的频率.默认情况下,将避免清除压缩率超过50%的日志,这个比率避免了最大的空间浪费
* min.insync.replicas = 1: 全局默认值为server.properties的min.insync.replicas,当producer设置request.required.acks为-1时,min.insync.replicas指定replicas的最小数目(必须确认每一个repica的写数据都是成功的),如果这个数目没有达到,producer会产生异常
* retention.bytes: 全局默认值为server.properties的log.retention.bytes,如果使用delete的retention策略,这项配置就是指在删除日志之前,日志所能达到的最大尺寸.默认情况下,没有尺寸限制而只有时间限制
* retention.ms = 7 days: 全局默认值为server.properties的log.retention.minutes,如果使用delete的retention策略,这项配置就是指删除日志前日志保存的时间
* segment.bytes = 1GB: 全局默认值为server.properties的log.segment.bytes,kafka中log日志是分成一块块存储的,此配置是指log日志划分成块的大小
* segment.index.bytes = 10MB: 全局默认值为server.properties的log.index.size.max.bytes,此配置是有关offsets和文件位置之间映射的索引文件的大小.一般不需要修改这个配置
* segment.ms = 7 days: 全局默认值为server.properties的log.roll.hours,即使log的分块文件没有达到需要删除,压缩的大小,一旦log 的时间达到这个上限,就会强制新建一个log分块文件



## Consumer



* group.id: 用来唯一标识consumer进程所在组的字符串,如果设置同样的group  id,表示这些processes都是属于同一个consumer group
* zookeeper.connect: 指定zookeeper的连接的地址,格式是hostname:port,为避免某个zookeeper 机器宕机之后失联,可以指定多个hostname:port,使用逗号作为分隔.可以在zookeeper连接字符串中加入zookeeper的chroot路径,此路径用于存放Kafka自己的数据,方式: hostname1:port1,hostname2:port2/chroot/path
* consumer.id:不需要设置,一般自动产生
* socket.timeout.ms = 3000: 网络请求的超时限制.真实的超时限制是 max.fetch.wait+socket.timeout.ms
* socket.receive.buffer.bytes = 64\*1024: socket用于接收网络请求的缓存大小
* fetch.message.max.bytes = 1024\*1024: 每次fetch请求中,针对每次fetch消息的最大字节数.这些字节将会督导用于每个partition的内存中,因此,此设置将会控制consumer所使用的memory大小.这个fetch请求尺寸必须至少和server允许的最大消息尺寸相等,否则,producer可能发送的消息尺寸大于consumer所能消耗的尺寸
* num.consumer.fetchers = 1: 用于fetch数据的fetcher线程数
* auto.commit.enable = true: 如果为真,consumer所fetch的消息的offset将会自动的同步到zookeeper.这项提交的offset将在进程挂掉时,由新的consumer使用
* auto.commit.interval.ms = 60*1000: consumer向zookeeper提交offset的频率,单位是秒
* queued.max.message.chunks = 2: 用于缓存消息的最大数目,以供consumption.每个chunk必须和fetch.message.max.bytes相同
* rebalance.max.retries = 4: 当新的consumer加入到consumer group时,consumers集合试图重新平衡分配到每个consumer的partitions数目.如果consumers集合改变了,当分配正在执行时,这个重新平衡会失败并重入
* fetch.min.bytes =1: 每次fetch请求时,server应该返回的最小字节数.如果没有足够的数据返回,请求会等待,直到足够的数据才会返回
* fetch.wait.max.ms = 100: 如果没有足够的数据能够满足fetch.min.bytes,则此项配置是指在应答fetch请求之前,server会阻塞的最大时间
* rebalance.backoff.ms = 2000: 在重试reblance之前backoff时间
* refresh.leader.backoff.ms = 200: 在试图确定某个partition的leader是否失去他的leader地位之前,需要等待的backoff时间
* auto.offset.reset = largest: zookeeper中没有初始化的offset时,如果offset是以下值的回应:
  * smallest: 自动复位offset为smallest的offset
  * largest: 自动复位offset为largest的offset
  * anything  else: 向consumer抛出异常
* consumer.timeout.ms = -1: 如果没有消息可用,即使等待特定的时间之后也没有,则抛出超时异常
* exclude.internal.topics = true: 是否将内部topics的消息暴露给consumer
* paritition.assignment.strategy = range: 选择向consumer 流分配partitions的策略,可选值: range,roundrobin
* client.id = group id value: 是用户特定的字符串,用来在每次请求中帮助跟踪调用,可以逻辑上确认产生这个请求的应用
* zookeeper.session.timeout.ms = 6000: zookeeper 会话的超时限制.如果consumer在这段时间内没有向zookeeper发送心跳信息,则它会被认为挂掉了,并且reblance将会产生
* zookeeper.connection.timeout.ms = 6000: 客户端在建立通zookeeper连接中的最大等待时间
* zookeeper.sync.time.ms = 2000: ZK follower可以落后ZK leader的最大时间
* offsets.storage = zookeeper: 用于存放offsets的地点: zookeeper或kafka
* offset.channel.backoff.ms = 1000: 重新连接offsets channel或者是重试失败的offset的fetch/commit请求的backoff时间
* offsets.channel.socket.timeout.ms = 10000: 当读取offset的fetch/commit请求回应的socket 超时限制.此超时限制是被consumerMetadata请求用来请求offset管理
* offsets.commit.max.retries = 5: 重试offset commit的次数.这个重试只应用于offset  commits在shut-down之间
* dual.commit.enabled = true: 如果使用kafka作为offsets.storage,可以二次提交offset到zookeeper(还有一次是提交到kafka).在zookeeper-based的offset storage到kafka-based的offset storage迁移时,这是必须的.对任意给定的consumer group来说,比较安全的建议是当完成迁移之后就关闭这个选项
* partition.assignment.strategy = range: 在range和roundrobin策略之间选择一种作为分配partitions给consumer 数据流的策略.循环的partition分配器分配所有可用的partitions以及所有可用consumer线程,它会将partition循环的分配到consumer线程上.如果所有consumer实例的订阅都是确定的,则partitions的划分是确定的分布.循环分配策略只有在以下条件满足时才可以:
  * 每个topic在每个consumer实力上都有同样数量的数据流
  * 订阅的topic的集合对于consumer  group中每个consumer实例来说都是确定的



## Producer



* boostrap.servers: 用于建立与kafka集群连接的host:port组,数据将会在所有servers上均衡加载,不管哪些server是指定用于bootstrapping.这个列表仅仅影响初始化的hosts(用于发现全部的servers),多个地址用逗号分割.因为这些server仅仅是用于初始化的连接,以发现集群所有成员关系(可能会动态的变化),这个列表不需要包含所有的servers.如果没有server在这个列表出现,则发送数据会一直失败,直到列表可用
* acks = 1: producer需要server接收到数据之后发出的确认接收的信号,此项配置就是指procuder需要多少个这样的确认信号.此配置实际上代表了数据备份的可用性.可选值为:
  * 0: 表示producer不需要等待任何确认收到的信息,副本将立即加到socket  buffer并认为已经发送,没有任何保障可以保证此种情况下server已经成功接收数据,同时重试配置不会发生作用(因为客户端不知道是否失败)回馈的offset会总是设置为-1
  * 1: 这意味着至少要等待leader已经成功将数据写入本地log,但是并没有等待所有follower是否成功写入.这种情况下,如果follower没有成功备份数据,而此时leader又挂掉,则消息会丢失
  * all: 这意味着leader需要等待所有备份都成功写入日志,这种策略会保证只要有一个备份存活就不会丢失数据,这是最强的保证
  * 其他的设置,例如acks=2也是可以的,这将需要给定的acks数量,但是这种策略一般很少用
* buffer.memory = 33554432: producer可以用来缓存数据的内存大小.如果数据产生速度大于向broker发送的速度,producer会阻塞或者抛出异常,以block.on.buffer.full来表明.这项设置将和producer能够使用的总内存相关,但并不是一个硬性的限制,因为不是producer使用的所有内存都是用于缓存.一些额外的内存会用于压缩(如果引入压缩机制),同样还有一些用于维护请求
* compression.type: producer用于压缩数据的压缩类型,默认无压缩.正确的选项值是none、gzip、snappy.压缩最好用于批量处理,批量处理消息越多,压缩性能越好
* retries = 0: 设置大于0的值将使客户端重新发送任何数据,一旦这些数据发送失败.这些重试与客户端接收到发送错误时的重试没有什么不同.允许重试将潜在的改变数据的顺序,如果这两个消息记录都是发送到同一个partition,则第一个消息失败第二个发送成功,则第二条消息会比第一条消息出现要早
* batch.size = 16384: producer将试图批处理消息记录,以减少请求次数.这将改善client与server之间的性能.这项配置控制默认的批量处理消息字节数,不会试图处理大于这个字节数的消息字节数.发送到brokers的请求将包含多个批量处理,其中会包含对每个partition的一个请求.较小的批量处理数值比较少用,并且可能降低吞吐量(0则会仅用批量处理);较大的批量处理数值将会浪费更多内存空间,这样就需要分配特定批量处理数值的内存大小
* client.id: 当向server发出请求时,这个字符串会发送给server,目的是能够追踪请求源头,以此来允许ip/port许可列表之外的一些应用可以发送信息.这项应用可以设置任意字符串,因为没有任何功能性的目的,除了记录和跟踪
* linger.ms = 0: producer组将会汇总任何在请求与发送之间到达的消息记录一个单独批量的请求,通常这只有在记录产生速度大于发送速度的时候才能发生.在某些条件下,客户端将希望降低请求的数量,甚至降低到中等负载一下,这项设置将通过增加小的延迟来完成,即不是立即发送一条记录,producer将会等待给定的延迟时间以允许其他消息记录发送,这些消息记录可以批量处理.这可以认为是TCP种Nagle的算法类似.这项设置设定了批量处理的更高的延迟边界: 一旦获得某个partition的batch.size,他将会立即发送而不顾这项设置,然而如果获得消息字节数比这项设置要小的多,需要linger特定的时间以获取更多的消息.这个设置默认为0,即没有延迟.设定linger.ms=5,将会减少请求数目,但是同时会增加5ms的延迟
* max.request.size = 1028576: 请求的最大字节数.这也是对最大记录尺寸的有效覆盖.server具有自己对消息记录尺寸的覆盖,这些尺寸和这个设置不同,此项设置将会限制producer每次批量发送请求的数目,以防发出巨量的请求
* receive.buffer.bytes = 32768: TCP receive缓存大小,当阅读数据时使用
* send.buffer.bytes = 131072: TCP send缓存大小,当发送数据时使用
* timeout.ms = 30000: 此配置选项控制server等待来自followers的确认的最大时间.如果确认的请求数目在此时间内没有实现,则会返回一个错误.这个超时限制是以server端度量的,没有包含请求的网络延迟
* block.on.buffer.full = true: 当内存缓存用尽时,必须停止接收新消息记录或者抛出错误.默认情况下,这个设置为真;设置为false时producer会抛出一个异常错误: BufferExhaustedException, 如果记录已经发送同时缓存已满
* metadata.fetch.timeout.ms = 60000: 是指所获取的一些元素据的第一个时间数据.元素据包含:topic,host,partitions.此项配置是指当等待元素据fetch成功完成所需要的时间,否则会跑出异常给客户端
* metadata.max.age.ms = 300000: 以微秒为单位,是在强制更新metadata的时间间隔,即使没有看到任何partition leadership改变
* metric.reporters: 类的列表,用于衡量指标.实现MetricReporter接口,将允许增加一些类,这些类在新的衡量指标产生时就会改变.JmxReporter总会包含用于注册JMX统计
* metrics.num.samples = 2: 用于维护metrics的样本数
* metrics.sample.window.ms = 30000: metrics系统维护可配置的样本数量,在一个可修正的window  size.配置窗口大小,例如,可能在30s的期间维护两个样本.当一个窗口推出后,会擦除并重写最老的窗口
* recoonect.backoff.ms = 10: 连接失败时,重新连接时的等待时间.这避免了客户端反复重连
* retry.backoff.ms = 100: 在试图重试失败的produce请求之前的等待时间.避免陷入发送-失败的死循环中



# 配置SSL



* 需要在kafka的server.properties中添加SSL地址,如下

  ```properties
  # 服务器监听地址,还需要额外加上SSL地址,端口可自定义
  listeners=PLAINTEXT://192.168.1.150:9092,SSL://192.168.1.150:8989
  advertised.listeners=PLAINTEXT://192.168.1.150:9092,SSL://192.168.1.150:8989
  # SSL证书的存放目录,密钥等.如何生成SSL证书,见Linux笔记
  ssl.keystore.location=/opt/ca-tmp/server.keystore.jks
  ssl.keystore.password=dream
  ssl.key.password=dream
  ssl.truststore.location=/opt/ca-tmp/server.truststore.jks
  ssl.truststore.password=dream
  ```

* 测试SSL是否成功: `openssl s_client -debug -connect 192.168.1.150:8989 -tls1`

* 在代码中可以同时访问9092和8989端口的程序,9092不需要配置SSL,而8989的需要配置SSL才可访问



# Shell命令



* 启动: bin/kafka-server-start.sh config/server.properties &

* 停止: bin/kafka-server-stop.sh

* 创建Topic: bin/kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 1 --partitions 1 --topic dream-topic

* 查看已经创建的Topic信息: bin/kafka-topics.sh --list --zookeeper localhost:2181

* 发送消息: bin/kafka-console-producer.sh --broker-list 192.168.1.150:9092 --topic dream-topic

* 接收消息: bin/kafka-console-consumer.sh --bootstrap-server 192.168.1.150:9092 --topic dream-topic --from-beginning

* 推送数据和计算结果

  ```shell
  bin/kafka-console-producer.sh --broker-list 192.168.1.150:9092 --topic test-stream-in
  bin/kafka-console-consumer.sh --bootstrap-server 192.168.1.150:9092 --topic test-stream-out --property print.key=true --property print.value=true  --property key.deserializer=org.apache.kafka.common.serialization.StringDeserializer --property value.deserializer=org.apache.kafka.common.serialization.LongDeserializer --from-beginning
  ```

  



# 消息重复消费



* 比如A服务消费了MQ中的消息,A刚要回复MQ时挂了,而MQ没有等到A的回复,那MQ就认为该消息还没被消费
* 当A服务重启的时候,发现上次消费了的消息还在,继续消费,此时就发生了重复消费
* 解决的办法是没有的,只能减少,比如每次消费前从Redis中查询该消息是否被消费,没有就继续消费,有就跳过.但该方法只是换汤不换药,若是在A服务向Redis中写消息的时候挂了,一样会出现重复消费



# 消息丢失





# 顺序消费



* 将需要进行顺序消费的数据都放在一个queue中,而不是放在多个queue中,即放在单个partition中
* 使用key+offset可以做到业务有序



# 数据积压



* 临时增加queue数量



# 节点故障处理



* Kafka基本不会因为节点故障而丢失数据,因为有集群做保证
* Kafka的语义担保也很大程度上避免数据丢失
* Kafka会对消息进行集群内平衡,减少消息在某些节点热度过高



# Kafka-manager



* kafka集群监控,要根据jdk版本下载
* 下载完成之后解压,修改application.conf中的zk的地址以及端口,之后即可启动



# 应用场景



* 流式处理,如日志收集,流式系统,大数据系统.吞吐量高,但是不保证数据有有序性
* 用户活动跟踪或运营指标监控
* 消息系统,可以消费历史数据
* 吞吐量大的原因
  * 日志顺序读写和快速检索
  * partition机制并行处理
  * 批量收发数据以及数据传输压缩
  * 通过sendfile实现数据零拷贝
* 日志检索底层原理
  * 日志以partition为单位进行存储,每个partition日志会分为N个大小相等的segment,每个segment消息数量不等
  * 当segment达到一定阈值就会flush到磁盘上,segment文件分为index和data
  * 每个partition只支持顺序读写,消息会被追加到最新的一个segment末尾