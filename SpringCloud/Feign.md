# Feign

* springcloud内部各个服务器之间远程调用
* 

-------
# Actuator

* 直接在浏览器使用ip:port/actuator/health或actuator/info等



# Hystrix

* springcloud内部负载均衡feign以及断路器
* 直接在浏览中使用ip:port/hystrix;会显示一个页面,需要填写ip:port和后缀,再就是密码,然后浏览器填写输入的ip:port以及后缀
* 当某个方法配置了断路器之后,若是该方法发生异常,无法访问.那么hystrix仍然会先进入异常的方法中,再调用断路器方法.直到达到一定的条件时,调用将不再进入发生异常的方法,直接进入断路器方法中



# Turbine

* 类似actuator,但是turbine是做整个集群的监控,需要在application上添加EnableTurbine注解



# Ribbon

## 负载均衡

* RoundRobinRule:,轮询,按顺序访问服务器
* 随机:随机访问一台服务器
* 