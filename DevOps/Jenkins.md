# Jenkins



# 概述



* 自动化集成,部署工具



# 安装



* [官网](https://www.jenkins.io/zh/download/)
* 使用yum安装

```shell
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat/jenkins.io.key
sudo yum upgrade
# 若不想使用openjdk,可以自行安装JDK
sudo yum install java-11-openjdk
sudo yum install jenkins
sudo systemctl daemon-reload
# 安装完成
```

* 若安装时报以下错误,可以在wget后添加参数:`--no-check-certificate`

```shell
ERROR: cannot verify pkg.jenkins.io's certificate, issued by ‘/C=US/O=Let's Encrypt/CN=R3’:
  Issued certificate has expired.
To connect to pkg.jenkins.io insecurely, use `--no-check-certificate'.
```

* 使用安装包安装

* 下载压缩包,解压到/software/jenkins: `rpm -ivh jenkins-2.190.3-1.1.noarch.rpm`
* 修改Jenkins配置: `vi /etc/syscofig/jenkins`

```shell
# 登录jenkins的账户,默认是jenkins,改成系统账户,也可以不改,自行添加jenkins账户
JENKINS_USER="root"
# jenknis运行端口
JENKINS_PORT="8888"
```

* 若修改上述配置文件无效,则需要修改`vi /usr/lib/systemd/system/jenkins.service`,新版本的配置文件地址

```shell
User=root
Environment="JENKINS_PORT=8888"
```

* 修改完之后执行`systemctl daemon-reload`

* 启动jenkins: `systemctl start jenkins`,如果启动出现:`usr/bin/java: No such file or directory`,做一个软连接到/usr/bin/java
  * `ln -s /usr/local/java/jdk8/bin/java /usr/bin/java`
* 网页访问: `ip:port/8888`,若一直停留在初始化页面,则需要更换Jenkins的源地址,`/root/.jenkins/hudson.model.UpdateCenter.xml`

```xml
# 修改URL里的标签为国内的源,以下为清华的源地址
<?xml version='1.1' encoding='UTF-8'?>
<sites>
  <site>
    <id>default</id>
    <url>https://mirrors.tuna.tsinghua.edu.cn/jenkins/updates/update-center.json</url>
  </site>
</sites>
```

* 初始化需要输入admin账号的密码: `cat /var/lib/jenkins/secrets/initialAdminPassword  `
* 不要选择推荐的插件安装,非常慢,直接选择插件来安装,选择无直接进入,新建一个管理员账号

![](img/jenkins001.jpg)





# Configure



## JDK



* 进入Jenkins->Global Tool Configuration->JDK->新增JDK
* 名称可自定义,目录填写JDK目录.若是安装openjdk,则安装目录在/usr/lib/jvm中



## Maven



* Jenkins->Global Tool Configuration->Maven->新增Maven
* 名称可自定义,目录填写Maven目录,注意修改本地仓库地址和远程仓库地址



## 添加全局变量



* Manage Jenkins->Configure System->Global Properties,添加三个全局变量JAVA_HOME、M2_HOME、PATH+EXTRA
* 他们的值分别是各自的安装目录,而PATH+EXTRA的值是`$M2_HOME/bin`





# 插件管理



* 在Web页面上依次点击:Jenkins->Manage Jenkins->Manage Plugins,点击Availablera,让Jenkins将官方的插件列表下载到本地,接着修改地址文件,替换为国内插件地址

```shell
#  修改源地址,不同版本可能源地址不一样,需要修改2个地方cd /root/.jenkins/updates
cd /var/lib/jenkins/updates
sed -i 's/https:\/\/updates.jenkins.io\/download/https:\/\/mirrors.tuna.tsinghua.edu.cn\/jenkins/g' default.json && sed -i 's/https:\/\/updates.jenkins-ci.org\/download/https:\/\/mirrors.tuna.tsinghua.edu.cn\/jenkins/g' default.json && sed -i  's/https:\/\/www.google.com/https:\/\/www.baidu.com/g' default.json
cd /root/.jenkins/updates
```

* 修改完之后,切换到Manage Plugins的Advanced,把Update Site改为国内插件下载地址

```shell
https://mirrors.tuna.tsinghua.edu.cn/jenkins/updates/update-center.json
```

* Sumbit后,在浏览器输入http://ip:port/restart ,重启Jenkins
* 安装publish over ssh和ssh plugin,主要用来将服务部署到远程服务器上



## Chinese



* [Localization: Chinese (Simplified)](https://plugins.jenkins.io/localization-zh-cn)
* 汉化插件,只能部分汉化



## Role-based



* [ Role-based Authorization Strategy](https://plugins.jenkins.io/role-strategy)
* 权限管理插件,更细致的管理Jenkins权限
* 安装完之后进入Manage Jenkins->Security->Configure Global Security->Authentication,找到授权策略,修改为Role-Based Strategy



### 创建角色



* 从系统管理界面进入Manage and Assign Roles->Manage Roles,可以看到3种角色:
  * Global roles: 全局角色,管理员等高级用户可以创建基于全局的角色,在安装role-based之前创建的用户默认都是该角色
  * Project roles: 项目角色,针对某个或者某些项目的角色
  * Slave roles: 从节点角色,主从节点相关的权限
* 创建一个Global roles,角色至少要绑定Overall下的Read权限,这是为了给所有用户绑定最基本的Jenkins访问权限.如果不给后续用户绑定这个角色,会报错误: `用户名 is missing the Overall/Read permission`
* 除了read权限之外,可以根据实际情况赋予角色不同的权限
* 创建一个Project roles,该角色可指定访问的项目,使用正则表达式绑定`dream.*`,意思是只能操作dream开头的项目



### 创建用户



* 在系统管理页面进入 Manage Users->新建用户,用户名唯一
* 创建完成之后再回到创建角色的页面,给用户分配角色(用户名需要手输),全局权限至少要分配读,其他权限可自定义



## Git



* 名称就叫Git,直接安装
* 在Jenkins中拉取项目时,项目默认目录/var/lib/jenkins/workspace/



## GitHub Branch Source



* 新建多分支的Git项目时可以使用,不用一个分支就新建一个Jenkins项目



## Credentials Binding



* 凭证功能,用来保存用户名密码,SSH秘钥等凭证
* 插件安装完成之后会在首页左侧边栏看到凭据管理,进入凭据,可添加5种凭据,一般是用户密码或SSH
  * Username with password: 用户名和密码
  * SSH Username with private key: 使用SSH用户和密钥
  * Secret file: 需要保密的文本文件,使用时Jenkins会将文件复制到一个临时目录中,再将文件路径设置到一个变量中,等构建结束后,所复制的Secret file就会被删除
  * Secret text: 需要保存的一个加密的文本串,如钉钉机器人或Github的api token
  * Certificate: 通过上传证书文件的方式
* 添加凭据时,ID和描述可选填
* 从Git拉取代码时就需要用到凭据,可以是用户名密码登录,也可以SSH登录
* 使用SSH登录需要先生成公私钥: `ssh-keygen -t rsa`,按照提示来即可,生成的文件在`~/.ssh`目录中
* 将xxx.pub公钥设置到Git中,私钥要在新建SSH凭据时使用,由Jenkins管理



## Pipeline



* 流水线项目,安装后可新建流水线项目,默认情况下只能新建FreeStyle项目



## Email Extension



* 邮件扩展插件,显而易见



## Mailer



* 配置邮件



## JDK



* JDK已经安装过了,不需要再次自动安装,但是需要手动指定别名和Java_home



## Maven



* 取消自动安装,将本机上的maven地址填入即可





# 使用



* 自由风格软件项目: FreeStyle Project,可以编写任意项目
* Maven项目: Maven Project,专门针对Java Maven项目
* 流水线项目: Pipeline Project,灵活度很高,可以自由编写很多脚本,代码



## FreeStyle



* 可以编写任意项目,主要不同是在构建的时候可以添加脚本
* 填写Git地址,填写分支,一般是`*/master,*/dev,*/test,*/prod`
* 编译打包: 构建->添加构建步骤->Executor Shell,此处可以填写Maven构建命令,如`mvn clean package`
* 部署: 把项目部署到远程的服务器里,Jenkins本身无法实现远程部署的功能,需要安装Deploy to container插件实现
* 构建后操作: 选择Deploy war/jar to a container,填写相关信息即可



## Maven



* 需要先安装Maven Integration插件才能支持该风格构建
* Maven风格和FreeStyle风格的主要不同是在构建模块,Maven风格会找到pom.xml文件,而不是直接使用Shell脚本

* 构建一个maven项目
* 点击源码管理,将git仓库的地址填入其中,根据实际情况添加密钥验证
* build的Root Pom需要根据实际情况选择pom.xml文件,一般直接写pom.xml即可.Goals and Options填写需要执行的maven命令,如maven clean package或直接填写clean package
* post steps:可选择execute shell,添加一些脚本,如重新构建之后重启的脚本等
* 如需通过git进行自动构建,则需要通过git的webhook功能,填入Jenkins项目地址即可



## Pipeline



* 和其他模式的区别在于多了流水线模块,该模块集中了其他模块的代码拉取,构建等等模块



## 构建触发器



### 触发远程构建



![](img/jenkins002.jpg)



* 通过指定的token调用指定的远程地址触发构建,其中身份验证令牌需自定义,在调用时传入到token中即可



### 其他工程构建后触发



![](img/jenkins003.jpg)



* 顾名思义,需要在其他工程构建完成之后触发,关注的项目可以写多个,逗号隔开



### 定时构建



![](img/jenkins004.jpg)



* 定时任务进行构建,只需要在日程表中填写正确的定时任务表达式即可,顺序为分时日月周



### 轮询SCM



![](img/jenkins005.jpg)



* 类似于定时构建,通用需要输入一个定时任务表达式,但不同的是,如果Git的代码没有变更,即时时间到了也不会构建
* 定时和轮训都不建议使用,会增大系统开销





# GitLab自动构建



* 需要先安装GitLab Hook和GitLab插件

* 需要先在GitLab设置好webhook,参考官网,webhook地址设置为Jenkins执行项目地址
* 进入新建好的项目,进入配置,选择构建触发器
* 选择`Build when a change is pushed to GitLab.GitLab webhook URL xxxx`: xxxx为webhook地址
* 进入Jenkins设置允许匿名访问Jenkins