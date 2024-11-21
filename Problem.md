# Problem



* 开发中遇到的各种问题汇总



# 缺少功能



* 随时可以开启和关闭接口的功能
* 字典国际化



# KKFile



## 问题



* 配置HTTPS无法访问,使用nginx反向代理,报各种安全问题



## 解决方案



* 修改kkfileview的配置文件,修改如下配置

  ```properties
  server.context-path=nginx反向代码地址
  base.url=域名加上nginx反向代理地址
  ```

* 如域名为`https://abc.com`,nginx反向代理为/preview

  ```nginx
  # nginx配置:将preview后缀的请求转发到kkfileview的服务地址
  location /preivew {
      # kkfileview服务地址
  	proxy_pass 192.168.1.111:8012;
  }
  ```

  ```properties
  # kkfileview配置
  # kkfileview服务后缀,nginx中的转发后缀要和该配置相同
  server.context-path=/preview
  # 域名进行预览时的地址
  base.url=https://abc.com/preview
  ```




# Feign



* 当A服务调用另外的B,C服务时,如果B服务使用了https,而C使用http,可能会找不到C服务,此时需要指定A服务中调用C服务的@FeignClient中的url为http



