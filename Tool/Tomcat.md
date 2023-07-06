# Tomcat



# 优化



## 禁用AJP



* Tomcat在 server.xml 中配置了两种连接器:
  * 第一个连接器监听8080端口,负责建立HTTP连接.在通过浏览器访问Tomcat服务器的Web应用时,使用的就是这个连接器
  * 第二个连接器监听8009端口,负责和其他的HTTP服务器建立连接.在把Tomcat与其他HTTP服务器集成时,就需要用到这个连接器.AJP连接器可以通过AJP协议和一个Web容器进行交互,如Nginx+tomcat的架构,所以用不着AJP协议,所以把AJP连接器禁用
* 修改conf下的server.xml文件,将AJP服务注释掉即可,重启tomcat

> <Connector port="8009" protocol="AJP/1.3" redirectPort="8443" />



## 设置执行器(线程池)



* Tomcat中每一个用户请求都是一个线程,所以可以使用线程池提高性能,修改server.xml文件

```xml
<!-- 将注释打开 -->
<Executor name="tomcatThreadPool" namePrefix="catalina‐exec‐" maxThreads="500"  
          minSpareThreads="50" prestartminSpareThreads="true" maxQueueSize="100"/>
<!--
参数说明:
maxThreads:最大并发数,默认设置 200,一般建议在 500 ~ 1000,根据硬件设施和业务来判断
minSpareThreads:Tomcat初始化时创建的线程数,默认设置25
prestartminSpareThreads:在Tomcat初始化的时候就初始化minSpareThreads 的参数值,如果不等于 true,minSpareThreads 的值就没啥效果了
maxQueueSize:最大的等待队列数,超过则拒绝请求,需要根据测试设置,并非越大越好
-->
<!-- A "Connector" represents an endpoint by which requests are received
and responses are returned. Documentation at :
Java HTTP Connector: /docs/config/http.html
Java AJP Connector: /docs/config/ajp.html
APR (HTTP/AJP) Connector: /docs/apr.html
Define a non-SSL/TLS HTTP/1.1 Connector on port 8080
-->
<Connector port="8080" executor="tomcatThreadPool" protocol="HTTP/1.1" connectionTimeout="20000" redirectPort="8443" />
```



## 设置运行模式



* Tomcat的运行模式有3种:

  * bio:默认的模式,性能非常低下,没有经过任何优化处理和支持
  * nio:nio(new I/O或non-blocking I/O).它拥有比传统I/O操作(bio)更好的并发运行性能.推荐使用

  ```xml
  <Connector executor="tomcatThreadPool" port="8080"
             protocol="org.apache.coyote.http11.Http11NioProtocol"
             connectionTimeout="20000" redirectPort="8443" />
  ```

  * nio2:在 tomcat8中有最新的nio2,速度更快,推荐使用

  ```xml
  <Connector executor="tomcatThreadPool" port="8080"
             protocol="org.apache.coyote.http11.Http11Nio2Protocol"
             connectionTimeout="20000" redirectPort="8443" />
  ```

  * apr:安装起来最困难,但是从操作系统级别来解决异步的IO问题,大幅度的提高性能.

