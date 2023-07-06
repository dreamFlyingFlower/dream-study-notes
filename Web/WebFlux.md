# WebFlux



# 概述

* 响应式编程,完全异步和非阻塞,并通过Reactive Streams规范(RxJava)
* 响应式编程在简单业务上和普通对象差别不大,复杂请求业务下,可以提升性能
 *          需要Spring5.0以上,SpringBoot2.0以上,不需要ServletAPI,故而不能作为war部署
 *          SpringWebFlux有两种分隔:基于功能和基于注解的:
             *          基于注解的和SpringMVC类似,只不过返回的是Mono和Flux对象
             *          基于功能的则是路由配置与请求的实际处理分开,比较复杂
*          在WebFlux中,请求和响应不再是ServletRequest和ServletResponse,而是ServerRequest和ServerResponse
*          当spring-boot-starter-web和spring-boot-starter-webflux同时存在时,优先使用web
*          WebFlux启动方式默认是Netty,端口8080



# Reactor



* 是响应式编程的实现,满足 Reactive 规范框架
* Reactor 有两个核心类:Mono 和 Flux,这两个类实现接口 Publisher,提供丰富操作符,两者之间可以相互转换
* Flux:多结果包装,包含多个元素的异步序列,返回N个元素
* Mono:单个结果包装,包含0或1个元素的异步序列,返回0或1个元素
* Flux 和 Mono 都是数据流的发布者,使用 Flux 和 Mono 都可以发出三种数据信号:元素值,错误信号,完成信号
* 错误信号和完成信号都代表终止信号,终止信号用于告诉订阅者数据流结束了,错误信号终止数据流同时把错误信息传递给订阅者
  * 错误信号和完成信号都是终止信号,不能共存
  * 如果没有发送任何元素值,而是直接发送错误或者完成信号,表示是空数据流代
  * 如果没有错误信号,没有完成信号,表示是无限数据流



# WebClient



* 可以直接通过该类链式调用WebFlux接口,主要用在后台调用