# Docker



# 概述

* 提供简单轻量的建模方式
* 职责的逻辑分离
* 快速高效的开发声明周期
* 鼓励使用面向服务的架构
* 使用Docker容器开发,测试和部署服务
* 创建隔离的运行环境
* 搭建测试环境
* 构建多用户的平台即服务(PaaS)基础设施
* 提供软件即服务应用程序(SaaS)
* 高性能,超大规模的宿主机部署
* 文件系统隔离能力:每个容器都有自己的root文件系统
* 进程隔离:每个容器都运行在自己的进程环境中
* 网络隔离:容器间的虚拟网络接口和IP地址都是分开的
* 资源隔离和分组:使用cgroups将CPU和内存之类的资源独立分配给每个Docker容器



# 组成

* Docker Client:客户端,C/S架构
* Docker Daemon:守护进程
* Docker Server:Docker Daemon的主要组成部分,接收用户通过Docker Client发送的请求
* Docker Image:镜像,容器的基石,层叠的只读文件系统
* Docker Container:容器,通过镜像启动,启动和执行阶段,写时复制
* Docker Registry:仓库



# 安装



* 修改docker远程仓库的原地址,修改/etc/docker/daemon.json,添加如下,若文件不存在,可新建:

  ```json
  {
      "registry-mirrors":["新的远程仓库地址"]
  }
  ```
  
* 查找Docker-CE的版本

  ```shell
  yum list docker-ce.x86_64 --showduplicates | sort -r
  ```

* 卸载旧版本的docker

  ```shell
  yum remove -y docker-ce
  ```

* 安装依赖

  ```shell
  yum install -y yum-utils device-mapper-persistent-data lvm2
  ```

* 添加阿里云的源

  ```shell
  yum-config-manager --add-repo https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
  ```

* 安装docker

  ```shell
  yum -y install docker-ce-[Version] # 若不指定版本,默认安装最新版本
  ```
  
* 查看日志: `tail -f /var/log/message`

* 主要文件默认在/var/lib/docker目录



# 配置文件



* 配置文件:/usr/lib/systemd/system/docker.service  



# Shell



* systemctl start/stop/status/restart docker:linux上启动/停止/状态/重启docker

* systemctl enable docker:linux开机自启动docker

* docker search [] iname:iname指镜像名称,从远程docker仓库中搜索镜像.一次最多显示25个镜像,只有选项中official为ok的是官方镜像

  * -s num:只显示指定星级以上的镜像
  
* docker pull [] name[:TAG]:从远程仓库中拉取镜像到本地,tag为镜像版本,默认拉取latest版本,一般拉取management版本即可,最新版本可能不够稳定

  * -a:拉取所有版本的镜像到本地

* docker images []:查看本地所有镜像,不显示中间层镜像

  * -a:查看所有镜像,显示中间层镜像,这些镜像没有名称和版本
  * -f iname:利用镜像的名称进行过滤,也可以使用linux中的grep等命令
  * --no-trunc:指定不使用截断的形式显示镜像的信息,如imageid就是被截断的
  * -q:只显示截断后镜像的imageid(iid)
  
* docker run [] IMAGE[:TAG] [COMMAND] [ARG]:启动新的容器,在新容器中执行命令

  ```shell
  # 以终端的形式运行容器并进入容器内部./bin/bash表示进入容器内部,每个IMAGE可能不一样
  docker run -it redis /bin/bash
  # 指定后台运行,不需要指定/bin/bash
  docker run -d --name=redis01 redis
  # 指定端口映射
  docker run -d -p 6181:6181 -p 6282:6282 --name=zk01 zookeeper
  ```

  * IMAGE:镜像文件的名称,该命令运行后会产生一个新的容器
  * -d:容器在创建时以后台启动的方式运行,没有交互界面.-d和-it同时使用无效
  * -i:docker为启动进程始终打开标准输入,即非后台启动
  * -t:为docker分配一个终端,或者CTRL+P/CTRL+Q退出终端,即可实现后台运行
  * -P:大写的p,随机端口映射
  * -p port1:port2:为运行的容器指定端口映射
    * port1是主机端口,port2是docker容器端口
    * 若不指定port1,则将随机映射到主机端口
    * 可以同时写多个端口映射,如-p port1:port2 -p port3:port4
  * --name=cname:自定义容器的名称(cname),不能重复,若不指定,由docker自行定义
  * -h:指定容器的hostname
  * -e:设置环境变量,容器中可以使用该环境变量
  * `--net="bridge"`:指定容器的网络连接类型,支持bridge/host/none/container
  * -v src:des[:rwo]:将容器中的文件映射到主机中,保证数据的持久化,可以给目录赋权
    * src:主机中的目录地址
    * des:容器中的目录地址
  * --volumes-from cid/cname:共享其他容器创建的数据卷
  * --volumes-from cid/cname -v path1:path2 --name cname1 iname tar cvf path2 .tar datavolumn:备份数据卷到主机中,实则是备份目录的映射
    * path1:主机中的目录地址
    * path2:容器中数据卷的备份地址
    * tar cvf...:容器中备份时执行的命令;若是还原,则将cvf改成xvf即可
    * datavolumn:容器中需要备份的数据卷目录,多个用空格隔开
  * --link=cname:alias:由于docker容器重启之后ip都会改变,若是有使用ip的操作,重启之后就会失效.该参数就是给需要通过ip操作的docker容器起一个别名,所有通过ip的操作可以通过别名来完成,类似于主机名.cname是另外一个容器的名称,alias是给该容器起的别名
  * -icc=true:docker默认是允许container互通,通过-icc=false关闭互通.一旦关闭互通,只能通过-link name:alias命令连接指定container
  * `--privileged=flase`:指定容器是否为特权容器,特权容器拥有所有的capabilities
  * `--restart=always`:指定容器荣之后的重启侧脸
    * no:容器退出时不重启
    * always:容器退出时总是重启
    * on-failure:容器故障退出时重启
  * `--rm=false`:指定容器停止后自动删除容器,不能以docker run -d启动容器

* docker ps []:查看所有正在运行的容器

  * -a:查看所有正在运行和已经停止的容器
  * -l:查看最后一次运行的容器
  * -f status=exited:查看停止的容器

* docker attach cid/cname:以终端的形式进入到某个容器中

* docker exec [-d/-i/-t] cid/cname [command] [arg]:在运行中的容器内启动新进程

  ```shell
  # 以终端的形式进入容器内部
  docker exec -it cid/cname /bin/bash
  # 不进入终端启动容器中的其他应用,appname为容器中的某个应用
  docker exec cid/cname appname
  ```

* docker top cid/cname:查看运行的容器中的进程情况

* docker inspect [] iid/iname/iname:tag/cid/cname:查看镜像,容器的详细信息

  * `-f "{{.NetworkSettings.IPAddress}}" iid/iname/iname:tag/cid/cname`:直接输出容器或镜像的ip地址,双大括号固定写法,里面的内容需要根据inspect信息指定,是一个Json对象

* docker logs [] cid/cname:查看容器日志

  * -f:一直跟踪日志变化返回结果
  * -t:在返回的结果上加上时间戳
  * --tail num:返回结尾多少行的数量,num是数量

* docker start/restart [-it] cid/cname:启动或重启已经停止的容器

* docker stop/kill cid/cname:停止某个容器,stop是优雅停止,kill是暴力停止

  * `docker stop $(docker ps -qa)`:停止所有运行容器

* docker rmi [] iid/iname/iname:tag:删除镜像.当镜像有多个版本时,可使用最后一种方式删除

  * -f:强制删除镜像,即使有容器依托在该镜像上运行
  * --no-prune:不删除镜像中没有打标签(tag)的父镜像
  * docker rmi \`docker images -q\`:删除没有在容器中运行的镜像

* docker image prune:删除临时的,没有被使用的镜像文件

  * `-a,--all`:删除所有没有用的镜像,而不仅仅是临时文件
  * `-f,--force`:强制删除镜像文件

* docker rm [] cid/cname:删除没有运行的容器

  * -f:强行删除容易,不管是否在运行中
  * `docker rm $(docker ps -aq)`:删除所有容器

* docker info:显示docker的运行信息

* docker -d []:docker启动时守护进程选项

  * -D:是否以debug模式运行
  * -e:
  * -g path:默认地址为/var/lib/docker
  * --icc=true:允许在同一台主机上的docker容器之间数据互联,默认是开启的
  * -l:运行时的日志级别,默认为info
  * --label key=value:定义标签
  * -p:进程id,默认地址为/var/run/docker.pid

* docker save mysql:版本 > /目录/mysql.tar.gz:将镜像从docker中导出到指定目录下,若是latest,版本可不写

  * -o:非数字0,效果等同于`>`,指定输出的文件目录和名称

* docker load < mysql.tar.gz:将镜像导入到docker中,或者docker load -i < mysql.tar.gz

* `docker build --build-arg argname=argvalue -t 镜像名:版本 .`:将指定目录下的Dockerfile打包成镜像

  * `--build-arg argname=argvalue`: 打包dockerfile的时候指定参数,该参数可以在dockerfile中以`${argname}`使用
  * `-t 镜像名:版本`: 指定镜像名的名字
  * .:表示dockerfile所在目录,.表示当前目录,也可以是其他目录

* `docker cp file1 containerid:file2`:将linux中的文件拷贝到docker容器中的指定目录中

* `docker cp containerid:file2 file1`:将docker容器中的文件拷贝到Linux指定目录中

* `docker tag iid/iname[:tag] newiname[:tag]`:类似git中的tag,从某个稳定版本中拉取分支开发新功能

* `docker commit [] iid newiname[:tag]`:将修改后的镜像提交本地仓库中,成为一个新的镜像

  * -m:提交的注释信息
  * -a:指定镜像作者

* `docker push iname[:tag]`:将本地镜像推送到远程仓库

* `docker update [OPTIONS] containerid`:动态更新容器配置,可以同时更新多个,空格隔开.如`docker update --restart always cid`

* `docker network ls`:查看docker中的网络类型

* `docker volume ls`:查看数据卷挂载情况

* `docker volume inspect VNAME`:查看数据卷挂载详情,VNAME从`docker volume ls`中查看

* `docker volume prune`:清理数据卷



# 镜像构建



## Docker Commit



* 通过容器构建,无法自动化
* docker commit [] CONTAINER [REPOSITORY[:TAG]]:构建镜像
  * -a author:作者名称
  * -m msg:镜像信息
  * -p:在构建镜像时是否暂停正在运行的容器,默认true暂停



## Docker Build



* 通过Dockerfile文件构建镜像

* 新建一个Dockerfile文件,无后缀,内容如下:

  * FROM:该参数表示依赖的已经存在的镜像名,格式为iname[:tag],必须是第一条非注释指令
  * MAINTAINER:维护者的信息,多个用空格隔开,已废弃
  * LABEL:标签,代替了MAINRAINER,可以写多个,以KEY=VALUE形式存在
    * LABEL Author=dreamFlyingFlower
    * LABEL Version=0.0.1
  * RUN:可以有多个,有2种模式
    * shell命令:/bin/sh -c command,其中command自定义,其他固定写法
    * exec模式:["executable","arg1","arg2"...].相当于每一个空格都是一个参数
  * EXPOSE:指定镜像运行时容器使用的端口,可以有多个
  * CMD:指定容器运行的默认命令,如果在docker run时指定了默认命令,则会覆盖CMD命令.CMD有3种模式,其中2种和RUN相同,还有一种模式是exec中没有executable的,只带参数,该模式需要配合ENTRYPOINT使用
  * ENTRYPOINT:模式和CMD相同,但是在默认情况下不会被docker run中的命令覆盖,但可以使用--entrypoint参数强行覆盖.entrypoint和cmd配置使用,entrypoint中只写主要命令,cmd中只写参数,这样可以在docker run时使用-g 'args'覆盖cmd中参数
  * ADD src des:将其他文件或目录复制到使用dockerfile构建的镜像中.若是文件路径中有空格,可以使用["src","des"].
  * COPY src des:功能同ADD,不同的是add有类似解压的功能,若单纯的复制文件,推荐copy
  * VOLUME ["/data1","/data2"]:向镜像中提供卷,用于持久化和数据共享.类似于docker run的-v参数,但是它不能映射到主机中
  * WORKDIR /path:在创建容器时指定默认的工作目录,即cmd的默认目录
  * ENV k v/k=v:设置环境变量
  * USER username:指定容器以那个用户运行,若不使用,默认以root用户运行
  * ONBUILD:触发器,当一个镜像被其他镜像作为基础镜像时执行时,会在构建过程中插入指令

  ```shell
  FROM JAVA1.8
  MAINTAINER username
  RUN ["java -jar","--spring.profile.actives=dev","xxx.jar"]
  EXPOSE 8080 8082
  CMD /bin/bash # 若在docker run时定义了启动命令,则CMD无效
  ENTRYPOINT /bin/bash
  ```

* docker build [] path/url:构建镜像

  * path/url:path和url是要构建镜像的Dockfile地址,一个是本地地址,一个是远程地址
  * -t iname[:tag]:指定镜像的名称和版本,若不指定版本,默认latest
  * --no-cache:不使用构建缓存,默认是使用



# 数据卷



* 数据卷是经过特殊设计的目录,可以绕过联合文件系统(UFS),为一个或多个容器提供访问
* 数据卷的设计目的在于数据持久化,完全独立于容器个生命周期,因此,docker不会在容器删除时删除其挂载的数据卷
* 数据卷在容器启动时初始化,若容器使用的镜像在挂载点包含了数据,这些数据会复制到新数据卷中
* 数据卷可以在容器之间共享和重用
* 可以对数据卷里的内容进行直接修改
* 数据卷的变化不会影响镜像的更新
* 卷会一直存在,即使挂载数据卷的容器已经被删除
* 在容器运行时的体现就是docker run中的-v参数



# 跨主机连接

* 使用网桥实现跨主机容器连接
* 使用Open vSwitch实现跨主机容器连接
* 使用weave实现跨主机容器连接



# DockerCompose



* 一种用于通过使用单个命令创建和启动Docker应用程序的工具,主要用来做开发,测试等
* 需要配置一个docker-compose.yml文件,详见[官网](https://docs.docker.com/compose/extends/)



## 概述



* Docker Compose运行目录下的所有文件(docker-compose.yml,extends文件或环境变量文件等)组成一个工程,若不指定工程名即为当前目录名
* 一个工程当中可包含多个服务,每个服务中定义了容器运行的镜像,参数,依赖
* 一个服务当中可包括多个容器实例
* 没有解决负载均衡的问题,因此需要借助其它工具实现服务发现及负载均衡
* 配置文件默认为docker-compose.yml,可通过环境变量COMPOSE_FILE或-f参数自定义配置文件,其定义了多个有依赖关系的服务及每个服务运行的容器
* 服务(service):一个应用的容器,实际上可以包括若干运行相同镜像的容器实例
* 项目(project):由一组关联的应用容器组成的一个完整业务单元,在docker-compose.yml 文件中定义
* 一个项目可以由多个服务(容器)关联而成,Compose 面向项目进行管理,通过子命令对项目中的一组容器进行便捷地生命周期管理
* Compose 项目由Python编写,实现上调用了 Docker 服务提供的 API 来对容器进行管理.因此,只要所操作的平台支持 Docker API,就可以在其上利用 Compose 来进行编排管理



## Shell



* docker-compose -h:查看帮助
* docker-compose up:创建并运行所有容器
* docker-compose up -d:创建并后台运行所有容器
* docker-compose -f docker-compose.yml up -d:指定模板
* docker-compose down:停止并删除容器,网络,卷,镜像
* docker-compose logs:查看容器输出日志
* docker-compose pull:拉取依赖镜像
* dokcer-compose config:检查配置
* dokcer-compose config -q:检查配置,有问题才有输出
* docker-compose restart:重启服务
* docker-compose start:启动服务
* docker-compose stop:停止服务
* docker-compose ps:列出项目中所有的容器



## 使用



* 创建一个docker-compose.yml
  * image:镜像名称
  * build:根据docker file 打包 成镜像
  * context:指定docker file文件位置
  * commond:使用command可以覆盖容器启动后默认执行的命令
  * container_name:容器名称
  * depends_on:指定依赖那个服务
  * ports:映射的端口号,主机端口映射:docker端口映射
  * extra_hosts:会在/etc/hosts文件中添加一些记录
  * volumes:持久化目录,主机文件映射:docker文件映射
  * volumes_from:从另外一个容器挂在数据卷
  * dns:设置dns
  * privileged: 权限
  * user: 用户账号
  * restart: 是否总是重启
  * environment: 启动环境变量
* 定制docker-compose内容
* 运行docker-compose up

```yaml
version: '3.0'
services:
	# 服务名称
	tomcat80: 
        	# container_name: tomcat8080 指定容器名称
        	image: tomcat:8
        	# 端口映射
        	ports:
            	- 8080:8080
        	volumes:
            	- /usr/tomcat/webapps:/usr/local/tomcat/webapps
        	# 定义网络的桥
        	networks:  
            	- test_web
        mysql:
        	image: mysql:5.7
                # 解决外部无法访问
                command: --default-authentication-plugin=mysql_native_password
                ports:
                    - 3306:3306
                environment:
                        # root密码
                        MYSQL_ROOT_PASSWORD: 'root'
                        # 连接密码不能为空
                        MYSQL_ALLOW_EMPTY_PASSWORD: 'no'
                        # 默认创建数据库test
                        MYSQL_DATABASE: 'test'
                        # 默认创建一个test的用户,并指定密码
                        MYSQL_USER: 'test'
                        MYSQL_PASSWORD: 'root'
        networks:
        	- test_web
        # 自己单独的springboot项目
	test-web:
		hostname: localhost
                # 需要构建的Dockerfile文件
                build: ./
                ports:
                    - "38000:8080"
                # web服务依赖mysql服务,要等mysql服务先启动
                depends_on:
                    - mysql
                networks:
                    - test_web
# 定义一个网络,让多个组件之间可以相互连通
networks:
	test_web:
```



# Docker私服



## 服务端配置

* mkdir registry:新建一个存放私服镜像的目录
* 在目录中新建一个docker-compose.yml文件,内容如下

```yaml
# docker版本
version: '3'
# 服务
services:
  registry: 
  	# docker仓库官方镜像
    image: registry
    # 总是随docker启动
    restart: always
    # 容器名称
    container_name: registry
    # 端口
    ports: 
      - 5000:5000
    volumns: 
      - /app/server/docker/registry:/var/lib/registry
```

* docker-compose up  -d:后台启动,访问成功即表示搭建成功



## 客户端配置

* 修改/lib/systemd/system/docker.services,添加docker私服服务端地址

```shell
--insecure-registry 192.168.1.150:5000
```

* systemctl daemon-reload
* systemctl restart docker
* git search,git pull可正常使用,其他打tag,commit,push等都要带上私服地址
* git tag iid/iname 192.168.1.150:5000/newiname[:tag]:在私服上打tag
* git push 192.168.1.150:5000/newiname[:tag]:上传新的镜像到私服上



# Maven中使用



```xml
<plugin>
    <groupId>com.spotify</groupId>
    <artifactId>docker-maven-plugin</artifactId>
    <version>1.0.0</version>
    <!-- docker镜像配置 -->
    <configuration>
        <!-- 镜像名 -->
        <imageName>${project.artifactId}:${project.version}</imageName>
        <!-- 如果是私服,镜像名前面应该加上私服ip地址 -->
        <imageName>192.168.1.150:5000/${project.artifactId}:${project.version}</imageName>
        <!-- 基础镜像 -->
        <baseImage>jdk1.8</baseImage>
        <!-- 启动参数 -->
        <entryPoint>["java","-jar","/${project.artifactId}.jar"]</entryPoint>
        <!-- dockerfile所在目录 -->
        <dockerDirectory>${project.basedir}/src/main/resources</dockerDirectory>
        <!-- 镜像版本 -->
        <imageTags>
        	<imageTag>${project.version}</imageTag>
        </imageTags>
        <!-- 构建镜像的配置信息 -->
        <resources>
            <resource>
                <targetPath>/</targetPath>
                <directory>${project.build.directory}</directory>
                <include>${project.artifactId}-${project.version}.jar</include>
            </resource>
        </resources>
    </configuration>
</plugin>
```

* maven clean package docker:build -DpushImage:将项目打包上传到仓库中



# Rancher



* 对Docker进一步集成的工具,可以更简单的使用Docker



# Harbor



* 一个用于存储和分发Docker镜像的企业级Registry服务器
* 除了Harbor这个私有镜像仓库之外,还有Docker官方提供的Registry.相对Registry,Harbor具有很多优势:
  * 提供分层传输机制,优化网络传输.Docker镜像是是分层的,而如果每次传输都使用全量文件(所以用FTP的方式并不适合),显然不经济.必须提供识别分层传输的机制,以层的UUID为标识,确定传输的对象
  * 提供WEB界面,优化用户体验.只用镜像的名字来进行上传下载显然很不方便,需要有一个用户界面可以支持登陆、搜索功能,包括区分公有、私有镜像
  * 支持水平扩展集群.当有用户对镜像的上传下载操作集中在某服务器,需要对相应的访问压力作分解
  * 良好的安全机制.企业中的开发团队有很多不同的职位,对于不同的职位人员,分配不同的权限,具有更好的安全性



## 安装



* 先安装docker-compose

  ```shell
  sudo curl -L https://github.com/docker/compose/releases/download/1.21.2/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
  sudo chmod +x /usr/local/bin/docker-compose
  # 给docker-compose添加执行权限
  sudo chmod +x /usr/local/bin/docker-compose
  # 查看docker-compose是否安装成功
  docker-compose -version
  ```

* 下载Harbor的压缩包:https://github.com/goharbor/harbor/releases

* 上传压缩包到linux,并解压

  ```shell
  tar -xzf harbor-oﬄine-installer-v1.9.2.tgz mkdir /opt/harbor
  mv harbor/* /opt/harbor
  cd /opt/harbor
  ```

* 修改Harbor的配置:`vi harbor.yml`,修改hostname和port为当前服务器
* 安装Harbor:`./	prepare`,`./	install.sh`
* 启动Harbor: 
  * docker-compose up -d:启动
  * docker-compose stop:停止
  * docker-compose restart:重新启动
* 访问Harbor:http://192.168.66.102:85,默认账户密码: admin/Harbor12345  



## 创建项目



* Harbor的项目分为公开和私有的:
  * 公开项目: 所有用户都可以访问,通常存放公共的镜像,默认有一个library公开项目
  * 私有项目: 只有授权用户才可以访问,通常存放项目本身的镜像.创建完私有项目后可以给项目添加成员



## 新建用户



* 用户有4种角色:
  * 访客: 对指定项目拥有只读权限
  * 开发人员: 对指定项目拥有读写权限
  * 维护人员: 对指定项目拥有读写权限,创建Webhooks
  * 项目管理员: 除了读写权限,同时拥有用户管理/镜像扫描等管理权限



## 镜像上传



* 给镜像打上标签:` docker tag eureka:v1 192.168.66.102:85/dream/eureka:v1`

* 推送镜像: `docker push 192.168.66.102:85/dream/eureka:v1`

  ```shell
  The push refers to repository [192.168.66.102:85/dream/eureka]
  Get https://192.168.66.102:85/v2/: http: server gave HTTP response to HTTPS client
  ```

* 这时会出现以上报错是因为Docker没有把Harbor加入信任列表中,把Harbor地址加入到Docker信任列表: `vi /etc/docker/daemon.json`

  ```js
  {
      "registry-mirrors": ["https://mirrors.tuna.tsinghua.edu.cn"],
      "insecure-registries": ["192.168.66.102:85"]
  }
  ```

* 重启Docker

* 再次执行推送命令,会提示权限不足

  ```
  denied: requested access to the resource is denied
  ```

* 需要先登录Harbor,再推送镜像: `docker login -u 用户名 -p 密码 192.168.66.102:85`



## 下载镜像



* 在192.168.66.103服务器完成从Harbor下载镜像

* 安装Docker,并启动Docker,修改Docker配置

  ```js
  {
      "registry-mirrors": ["https://mirrors.tuna.tsinghua.edu.cn"],
      "insecure-registries": ["192.168.66.102:85"]
  }
  ```

* 重启docker

* 先登录,再从Harbor下载镜像

  ```shell
  docker login -u 用户名 -p 密码 192.168.66.102:85
  docker pull 192.168.66.102:85/dream/eureka:v1
  ```



# 应用



## MySQL



```shell
docker run 
# 后台运行且带有shell控制台
-itd 
# 自定义容器名称
--name self-mysql 
# 总是重启
--restart always
# 端口映射
-p 3306:3306
# 进入mysql时的root用户密码
-e MYSQL_ROOT_PASSWORD=123456
# 数据卷映射:本地目录:docker容器目录
-v /app/mysql/data:/var/lib/mysql
# mysql镜像,不带版本就是最新版
mysql:8.0.24
# mysql默认字符集
--character-set-server=utf8mb4 --collation-server=utf8mb4_0900_ai_ci
```

