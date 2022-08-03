# Wireshark



# 过滤



## 数据包过滤



* IP过滤,在Filter中过滤需要的IP地址: `ip.addr==ip`
* 在数据包过滤的基础上过滤协议: `ip.addr==xxx.xxx.xxx.xxx and tcp`
* 过滤端口: `ip.addr==xxx.xxx.xxx.xxx and http and tcp.port==80`
* 指定源地址,目的地址: `ip.src==xxx.xxx.xxx.xxx and ip.dst==xxx.xxx.xxx.xxx`



## 解码



* IPS发送攻击日至和防病毒日志信息端口号都是30514,SecCenter上只显示攻击日志,不显示防病毒日志.查看IPS本地有病毒日志,可以通过在SecCenter抓包分析确定数据包是否发送过来
* 发过来的数据量比较大,而且无法直接看出是IPS日志还是AV日志,可以先把数据包解码
* 选中捕获的数据,邮件选择Decode AS,在弹出框中选择



## TCP追踪



* 查看TCP的交互过程,把数据包整个交互过程提取出来,便于快速整理分析
* 选中数据流,邮件->追踪流->TCP流



# 设置



* View->time display format: 修改数据包时间显示方式
* Edit->preference->protocols->tcp->relative sequence numbers: 不勾选.默认是相对序列号0,1,不勾选可以是顺序报文的序列号,再次查看sequence number不再是0,1
* Statistics->conversations: 网络里有泛洪攻击的时候,可以通过抓包进行数据包个数的统计,查看哪些数据包较多进行分析



