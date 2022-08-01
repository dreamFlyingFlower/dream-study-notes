# ELK



* ELK主要是用来做日志分析,由es,logstash,kibana组成,还加入了Beats,ELK Cloud等
* 使用redis或队列作为数据来源的理由
  * 防止Logstash和ES无法正常通信,从而丢失日志
  * 防止日志量过大导致ES无法承受大量写操作从而丢失日志
  * 防止logstash 直接与es操作,产生大量的链接,导致es瓶颈
  * 如果redis使用的消息队列出现扩展瓶颈,可以使用更加强大的kafka,flume来代替
* x-pack:权限管理和邮件服务



# Logstash



* 一个数据抽取转化工具,可以从本地磁盘,网络服务,消息队列中收集各种日志,然后进行过滤分析,并将日志输出到Elasticsearch中,类似于大数据中的Flume



# Kibana



* 基于nodejs,可视化日志Web展示工具,对ES中存储的日志进行展示,还可以生成相应的图标



# Beats



* 集合了多种单一用途数据采集器,从成千上万台机器和系统向 Logstash 或 Elasticsearch 发送数据.Beats由如下组成:
  * Packetbeat: 轻量型网络数据采集器,用于深挖网线上传输的数据,了解应用程序动态.Packetbeat 是一款轻量型网络数据包分析器,能够将数据发送至 Logstash 或 Elasticsearch,其支 持ICMP (v4 and v6)、DNS、HTTP、Mysql、PostgreSQL、Redis、MongoDB、Memcache等协议
  * Filebeat: 轻量型日志采集器.当要面对成千上万的服务器、虚拟机和容器生成的日志时,Filebeat 可以提供一种轻量型方法,用于转发和汇总日志与文件,让简单的事情不再繁杂
  * Metricbeat: 轻量型指标采集器.Metricbeat 能够以一种轻量型的方式,输送各种系统和服务统计数据,从 CPU 到内存,从 Redis 到 Nginx等.可定期获取外部系统的监控指标信息,其可以监控,收集 Apache http、HAProxy、MongoDB、MySQL、Nginx、PostgreSQL、Redis、System、Zookeeper等服务
  * Winlogbeat: 轻量型 Windows 事件日志采集器.用于密切监控基于 Windows 的基础设施上发生的事件.Winlogbeat 能够以一种轻量型的方式,将 Windows 事件日志实时地流式传输至 Elasticsearch 和 Logstash
  * Auditbeat: 轻量型审计日志采集器.收集 Linux 审计框架的数据,监控文件完整性,实时采集这些事件,然后发送到 Elastic Stack 其他部分做进一步分析
  * Heartbeat: 面向运行状态监测的轻量型采集器,通过主动探测来监测服务的可用性,通过给定 URL 列表,Heartbeat 仅仅询问网站运行是否正常.Heartbeat 会将此信息和响应时间发送至 Elastic 的其他部分,以进行进一步分析
  * Functionbeat: 面向云端数据的无服务器采集器.在作为一项功能部署在云服务提供商的功能即服务 (FaaS) 平台上后,Functionbeat 即能收集、传送并监测来自您的云服务的相关数据



# Elastic Cloud

* 基于 Elasticsearch 的软件即服务(SaaS)解决方案,通过 Elastic 的官方合作伙伴使用托管的 Elasticsearch 服务

