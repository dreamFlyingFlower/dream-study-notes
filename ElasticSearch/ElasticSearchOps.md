# ElasticSearchOps



# Windows安装ES7



## 安装



* 安装JDK,至少1.8.0_73以上版本
* [下载地址](https://www.elastic.co/cn/downloads/elasticsearch)
* 下载和解压缩Elasticsearch安装包,查看目录结构
  * bin：脚本目录,包括：启动、停止等可执行脚本
  * config：配置文件目录
  * data：索引目录,存放索引文件的地方
  * logs：日志目录
  * modules：模块目录,包括了es的功能模块
  * plugins :插件目录,es支持插件机制



## 配置文件



* 配置文件elasticsearch.yml,ES的配置文件的地址根据安装形式的不同而不同
  * 使用zip、tar安装,配置文件的地址在安装目录的config下
  * 使用RPM安装,配置文件在/etc/elasticsearch下
  * 使用MSI安装,配置文件的地址在安装目录的config下,并且会自动将config目录地址写入环境变量ES_PATH_CONF
* cluster.name: 配置elasticsearch的集群名称,默认是elasticsearch,建议修改成一个有意义的名称
* node.name: 节点名,通常一台物理服务器就是一个节点,es会默认随机指定一个名字,建议指定一个有意义的名称,方便管理.一个或多个节点组成一个cluster集群,集群是一个逻辑的概念,节点是物理概念
* path.conf: 设置配置文件的存储路径,tar或zip包安装默认在es根目录下的config文件夹,rpm安装默认在/etc/ elasticsearch
* path.data: 设置索引数据的存储路径,默认是es根目录下的data文件夹,可以设置多个存储路径,用逗号隔开
* path.logs: 设置日志文件的存储路径,默认是es根目录下的logs文件夹
* path.plugins: 设置插件的存放路径,默认是es根目录下的plugins文件夹
* bootstrap.memory_lock: true.设置为true可以锁住ES使用的内存,避免内存与swap分区交换数据
* network.host: 设置绑定主机的ip地址,设置为0.0.0.0表示绑定任何ip,允许外网访问,生产环境建议设置为具体的ip
* http.port: 9200.设置对外服务的http端口,默认为9200
* transport.tcp.port: 9300.集群结点之间通信端口
* node.master: 指定该节点是否有资格被选举成为master结点,默认是true,如果原来的master宕机会重新选举新的master
* node.data: 指定该节点是否存储索引数据,默认为true
* discovery.zen.ping.unicast.hosts: ["host1:port", "host2:port", "..."].设置集群中master节点的初始列表
* discovery.zen.ping.timeout: 3s.设置ES自动发现节点连接超时的时间,默认为3秒,如果网络延迟高可设置大些
* discovery.zen.minimum_master_nodes:主结点数量的最少值 ,此值的公式为: `(master_eligible_nodes / 2) + 1`,比如有3个符合要求的主节点,那么这里要设置为2
* node.max_local_storage_nodes: 单机允许的最大存储节点数,通常单机启动一个节点设置为1,开发环境如果单机启动多个节点可设置大于1



## 启动



* `bin\elasticsearch.bat`
* es7 windows版本不支持机器学习,所以elasticsearch.yml中添加如下几个参数:

```yaml
node.name: node-1  
cluster.initial_master_nodes: ["node-1"]  
xpack.ml.enabled: false 
http.cors.enabled: true
http.cors.allow-origin: /.*/
```

* 检查ES是否启动成功,浏览器访问http://localhost:9200/?Pretty

```json
{
    // node名称,取自机器的hostname
    "name": "node-1",
    "cluster_name": "elasticsearch",
    "cluster_uuid": "HqAKQ_0tQOOm8b6qU-2Qug",
    "version": {
        // es版本号
        "number": "7.3.0",
        "build_flavor": "default",
        "build_type": "zip",
        "build_hash": "de777fa",
        "build_date": "2022-07-24T18:30:11.767338Z",
        "build_snapshot": false,
        // 封装的lucene版本号
        "lucene_version": "8.1.0",
        "minimum_wire_compatibility_version": "6.8.0",
        "minimum_index_compatibility_version": "6.0.0-beta1"
    },
    "tagline": "You Know, for Search"
}
```

* 浏览器访问 http://localhost:9200/_cluster/health 查询集群状态

```json
{
    "cluster_name": "elasticsearch",
    // 集群状态,Green标识所有分片可用;Yellow所有主分片可用;Red主分片不可用,集群不可用
    "status": "green",
    "timed_out": false,
    "number_of_nodes": 1,
    "number_of_data_nodes": 1,
    "active_primary_shards": 0,
    "active_shards": 0,
    "relocating_shards": 0,
    "initializing_shards": 0,
    "unassigned_shards": 0,
    "delayed_unassigned_shards": 0,
    "number_of_pending_tasks": 0,
    "number_of_in_flight_fetch": 0,
    "task_max_waiting_in_queue_millis": 0,
    "active_shards_percent_as_number": 100
}
```



# Linux安装ES7



## 安装



* 下载对应JDK版本的Elasticsearch安装包,或直接用yum或web-get下载安装包,解压到/app/es下

* 在es目录下创建data和logs目录

* 配置文件elasticsearch.yml在es/conf下

  ```yaml
  # 数据目录
  path.data:  /app/es/data
  # 日志目录
  path.logs:  /app/es/logs
  ```

* 配置linux进程访问数量,vi /etc/security/limits.conf,添加如下内容:

  ```shell
  * soft nofile 65536
  * hard nofile 131072
  * soft nproc 2048
  * hard nproc 4096
  ```

* 其他相关系统配置

  * vi /etc/security/limits.d/90-nproc.conf,修改如下内容:

  ```shell
  # * soft nproc 1024 修改为
  * soft nproc 2048
  ```

  * vi /etc/sysctl.conf ,添加下面配置:

  ```shell
  vm.max_map_count=655360
  sysctl -p
  ```

* 启动.es/bin/,根据系统的不同,进入不同的文件夹,进入后./elasticserach.sh start

* 启动测试:curl http://localhost:9200或在网页直接打开改地址

* 可使用elasticsearch-head对es进行可视化查看,主要需要开启es的跨域

* IK分词器,ES默认的分词器对中文支持不太好,使用IK分词器可以更好的查询中文,他分为2种模式:

  * ik_max_word:会对中文做最细粒度的拆分
  * ik_smart:最粗粒度的拆分

* 当直接在ElasticSearch建立文档对象时,如果索引不存在的,默认会自动创建,映射采用默认方式

* ElasticSearch服务默认端口9300,Web管理平台端口9200



## 常见问题



* 内存不足

  ```shell
  # 报错:
  # max virtual memory areas vm.max_map_count [65530] is too low, increase to at least [262144]
  # 在/etc/sysctl.conf中添加如下
  vm.max_map_count=655360
  sysctl -p
  # 若是docker,可添加命令参数: -e ES_JAVA_OPTS="-Xms1g -Xmx1g"
  ```

* 内存锁定

  ```shell
  # unable to install syscall filter: 
  # java.lang.UnsupportedOperationException: seccomp unavailable: CONFIG_SECCOMP not compiled into kernel, CONFIG_SECCOMP and CONFIG_SECCOMP_FILTER are needed
  # 在配置文件中添加如下配置
  bootstrap.memory_lock: false
  bootstrap.system_call_filter: false
  ```

* bootstrap checks failed

  ```shell
  # max file descriptors [4096] for elasticsearch process likely too low, increase to at least [65536]
  # max number of threads [1024] for user [lishang] likely too low, increase to at least [2048]
  # 修改/etc/security/limits.conf,添加如下
  * soft nofile 65536
  * hard nofile 131072
  * soft nproc 2048
  * hard nproc 4096
  ```



# ES7配置



## elasticserch.yml



* 配置文件为es/conf/elasticsearch.yml
* cluster.name:集群名称,如果要配置集群,需要两个以上的elasticsearch节点配置的cluster.name相同,都启动可以自动组成集群,cluster.name默认是elasticsearch
* node.name:当前es节点的名称,集群内部可重复
* network.host:绑定地址,若是0.0.0.0,任何ip都可以访问es
* http.port:http访问端口
* http.cors.enabled:true,是否允许跨域访问
* http.cors.allow-origin:/.*/,允许跨域访问的请求头
* transport.tcp.port:es内部交互接口,用于集群内部通讯,选举等
* node.master:true/false,集群中该节点是否能被选举为master节点,默认为true
* node.data:true/false,指定节点是否存储索引数据,默认为true
* discovery.zen.ping.unicast.hosts:["ip1:port1","ip2:port2"],设置集群中master节点的初始列表
* discovery.zen.ping.timeout:3s,es自动发现节点连接超时时间,默认为3s
* discovery.zen.minimum_master_nodes:2,最小主节点个数,此值的公式为:(master_eligible_nodes/2)+1
* discovery.seed_hosts:设置集群中的master节点的出事列表ip端口地址,逗号分隔
* cluster.initial_master_nodes:新集群初始时的候选主节点
* node.max_local_storage_nodes:2,单机允许的最大存储节点数
* node.ingest:true/false,是否允许成为协调节点
* bootstrap.memeory_lock:true/false,设置true可以锁住es使用的内存,避免内存与swap分区交换数据
* path.data:数据存储目录.默认是es根目录下的data文件夹,可以设置多个存储路径,用逗号隔开
* path.logs:日志存储目录.默认是es根目录下的logs文件夹
* path.conf:设置配置文件的存储路径,tar或zip默认在es根目录下的config,rpm默认在/etc/elasticsearch
* path.plugins:设置插件的存放路径,默认是es根目录下的plugins文件夹
* xpack.ml.enabled:boolean,是否启用机器学习,在windows上不支持,要设置为false



## jvm.options



* 设置最小及最大的JVM堆内存大小,在jvm.options中设置 -Xms和-Xmx
* 两个值设置为相等,将Xmx 设置为不超过物理内存的一半



# Windows安装Kibana



* kibana是es数据的前端展现,数据分析时,可以方便地看到数据
* 下载,解压kibana
* 启动Kibana：bin\kibana.bat
* 浏览器访问 http://localhost:5601 进入Dev Tools界面,像plsql一样支持代码提示
* 发送get请求,查看集群状态GET _cluster/health,相当于浏览器访问
* DevTool界面

![](img/201.png)

* 监控集群界面

![](img/202.png)



# Windows安装head



* [下载地址](https://github.com/mobz/elasticsearch-head)
* head插件是ES的一个可视化管理插件,用来监视ES的状态,并通过head客户端和ES服务进行交互,比如创建映射、创建索引等
* 安装node.js
* 下载head并运行

```
git clone git://github.com/mobz/elasticsearch-head.git 
cd elasticsearch-head 
npm install 
npm run start 
```

* 浏览器打开 http://localhost:9100/
* 打开浏览器调试工具发现报请求跨域错误,需要设置elasticsearch允许跨域访问,在config/elasticsearch.yml 后面增加以下参数:

```
# 开启cors跨域访问支持,默认为false   
http.cors.enabled: true   
# 跨域访问允许的域名地址,(允许所有域名)以上使用正则   
http.cors.allow-origin: /.*/
```

* kibana\postman\head插件选择自己喜欢的一种使用即可