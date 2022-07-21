# CloudConfig



# Server配置

* 可使用zk为配置中心,需要zk的包,可能会有冲突,需要将部分包排除.若不使用zk,需要注释掉zk包

* 在启动类上添加注解EnableConfigServer,表明可以使用配置服务

* 默认的配置是从git上获取,需要git帐号和密码,同时要在git上新建一个项目(原来的也可),该项目的第一层就放置配置文件,文件后缀无所谓.而配置git的uri的地址可以是如下形式

  ```
  # 直接写到项目名,则在config客户端只需要配置profile即可
  https://github.com/username/projectname
  # 项目名用通配符代替,在config客户端需要配置name和profile,更灵活
  https://github.com/username/{name}
  ```

* 启动项目后,可在浏览器使用ip:port访问,见Server访问



# Server访问

* 服务端启动之后可通过ip:port或服务名加上指定后缀访问配置文件信息,有多种匹配模式

* uri通常分为3个部分,形式必须相同,否则会报错

  * application:当服务端的spring.cloud.config.server.git.uri属性已经指定了仓库名时,该值可以匹配http访问的任意值;若该属性的值中仓库名未指定,而是一个通配符,则http访问时需要完全匹配,但是profile则要看是否有默认配置

  ```properties
  # 请求server端地址:http://localhost:55556/abc/dev仍然能拿到配置信息
  spring.cloud.config.server.git.uri=https://github.com/mygodness100/test1
  # http://localhost:55556/abc/dev拿不到属性
  # http://localhost:55556/test1/dev可以拿到属性
  spring.cloud.config.server.git.uri=https://github.com/mygodness100/{aaa}
  ```

  * profile:环境,同SpringBoot中application-dev.yml中的dev,不带后缀的配置就是默认配置
  * label:git分支名,如master

* {appliction}/{profile}[/{label}]:该形式会返回额外信息,配置信息放在propertySources数组中.假设以下例子中config服务端的uri配置了固定仓库,非固定仓库需要http完全匹配

   * applicaiton可是任意字符串,profile需要相同,若profile也没有,则需要看是否有默认配置
   * 当git中存在application.yml时,若profile找不到,则默认返回application.yml
   * eg:当git中有application.yml,application-test.yml时
      * abc,application:此种形式会报错,形式必须相同
      * abc/test1:找不到application-test1,返回默认的application.yml
      * abc/test:application和appcalition-test的信息都将被返回到propertySources中
      * abc/test.yml:找不到,propertySources为空数组.不可添加后缀任何后缀
      * abc/test/test1:若git中有分支test1,则返回test1的信息,没有则报错
      * abc/test1/master:找不到application-test1,返回默认的applicaiton
  * eg:当git中没有application.yml,只有application-test.yml时
    * abc,application:此种形式会报错,形式必须相同
     * abc/test1:找不到application-test1,propertySources返回[]
     * abc/test:只返回appcalition-test的信息
     * abc/test.yml:找不到,propertySources为[].不可添加后缀任何后缀
     * abc/test/test1:若git中有分支test1,则返回test1的信息,没有则报错
     * abc/test1/master:找不到application-test1,propertySources返回[]

 * {appliction}-{profile}.yml:只会返回匹配的配置信息,没有则返回空对象
    *          eg:当git中有application.yml,application-test.yml时:
                *          abc,abc.yml,abc-dev:报错,必须带后缀且形式相同
                *          abc-aaa.yml:找不到,返回默认的application中的信息
                *          abd-test.yml:application和application-test的信息都返回,同名属性以test中为准
    *          eg:当git中有application-dev.yml,application-test.yml时:
                *          abc,abc.yml,abc-dev:报错,必须带后缀且形式相同
                *          abc-aaa.yml:找不到,返回一个空对象
                *          abd-dev.yml:只返回匹配的配置文件中的信息,无其他额外信息

 * {appliction}-{profile}.properties:同{application}-{profile}.yml,只是格式不一样,当没有符合的配置文件时,也不会返回空对象,就是null

 * {label}/{appliction}-{profile}.yml:同{application}-{profile}.yml

 * {label}/{appliction}-{profile}.properties:同{application}-{profile}.properties



# 手动刷新Config

* 该方式需要每个项目都使用一次,不推荐使用
* 需要在使用了config属性的类上加上注解@RefreshScope
* 需要引用spring-boot-starter-actuator,并放开全部的监控端口,特别是refresh,否则无法刷新
* 在控制台或其他地方调用接口http://客户端ip:port/actuator/refresh,post方式



# 自动刷新Config

* 使用spring-cloud-bus的自动刷新,需要使用github的设置页面的webhooks,并且需要使用amqp

