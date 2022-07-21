# K8S



# 概述



* K8S里的所有资源对象都可以使用yaml或json格式的文件定义或描述



# 核心组件



## POD



* 副本.包含多个镜像的容器,类似于一个微型服务器
* 包含一个Pause镜像,该镜像将其他镜像容器关联起来集中管理,类似于Docker Compose



## ReplicaSet



* 副本集,管理一个或多个POD



## Deployment



* 管理RS,自动部署
* 当POD中某个镜像需要升级时,会重新创建一个RS,新的RS中运行新的镜像
* 当新的RS中的镜像都运行成功后,将旧的RS删除



## ApiServer



## Scheduler



## ControllerManager(CM)



## Replication Controller(RC)



## Kubelet



## Kubectl



* kubectl get namespaces:查看所有的命令空间

* kubectl create -f namespace-dev.yaml:根据namespace-dev.yaml创建一个命名空间

  ```yaml
  apiVersion: v1
  # 命令类型
  kind: NameSpace
  metadata: 
  	# 命名空间的名称为dev
  	name: dev
  ```

  



## Namespace



* 命名空间



## Resource



* CPU
* GPU
* 内存
* 持久化存储



## Label



# 核心流程



* 通过Kubectl提交一个创建RC的请求,该请求通过APIServer被写入etcd中
* 此时CM通过APIServer的监听资源变化的接口监听到此RC事件
* 分析之后,发现当前集群中还没有对应的Pod实例,于是根据RC里的Pod模板定义生成一个Pod对象,通过APIServer写入etcd
* 该事件被Scheduler发现,它立即执行一个复杂的调度流程,为这个新Pod选定一个落户的Node,然后通过APIServer将这个结果写入到etcd中
* 目标Node上运行的Kubelet进程通过APISever监测到这个新的Pod,并按照它的定义,启动该Pod并负责监听它,直到该Pod结束
* 新建完成之后通过Kubectl提交一个新的映射到该Pod的Service的创建请求
* CM通过Label标签查询到关联的Pod实例,然后生成Service的Endpoints信息,并通过APIServer写入到etcd中
* 所有Node上运行的Proxy进程通过APIServer查询并监听Service对象与其对应的Endpoinsts信息,建立一个软件方式的负载均衡器来实现Service访问到后端Pod的流量转发功能

![](K8S-01.png)



# KubeSphere



## 概述



* 有相当多的可插拔组件,如KubeSphere DevOps,Metrcis-server等



## 安装



* 最新安装的要求可在kubersphere[官网](https://kubesphere.com.cn/docs/installing-on-kubernetes/on-prem-kubernetes/install-ks-on-linux-airgapped/)查看



# KubeSphere DevOps



## 概述



* [官网](https://kubesphere.com.cn/docs/pluggable-components/devops/)
* 基于[Jenkins](https://jenkins.io/)的KubeSphere DevOps系统是专为Kubernetes中的 CI/CD 工作流设计的,它提供了一站式的解决方案,帮助开发和运维团队用非常简单的方式构建,测试和发布应用到Kubernetes
* 它具有插件管理,[Binary-to-Image (B2I)](https://kubesphere.com.cn/docs/project-user-guide/image-builder/binary-to-image/),[Source-to-Image (S2I)](https://kubesphere.com.cn/docs/project-user-guide/image-builder/source-to-image/),代码依赖缓存,代码质量分析,流水线日志等功能
* DevOps系统为用户提供了一个自动化的环境,应用可以自动发布到同一个平台
* 它还兼容第三方私有镜像仓库(如Harbor)和代码库(如GitLab/GitHub/SVN/BitBucket)
* 它为用户提供了全面的,可视化的CI/CD流水线,打造了极佳的用户体验,而且这种兼容性强的流水线能力在离线环境中非常有用



# Istio



## 概述



* ServiceMesh代表作



## 整合Kubernetes



* 集群中的Pod和服务必须满足必要的要求
* 需要给端口正确命名:服务端口必须进行命名.端口名称只允许是<协议>[-<后缀>-]模式,其中协议部分可选范围包括grpc,http,http2,https,mongo,redis,tcp,tls以及udp
* POD端口:POD必须包含每个容器将监听的明确端口列表.在每个端口的容器规范中使用containerPort,任何未列出的端口都将绕过Istio proxy
* 关联服务:Pod不论是否公开端口,都必须关联到至少一个Kubernetes服务上,如果一个Pod属于多个服务,这些服务不能在同一端口上使用不同协议,例如HTTP和TCP
* Deployment应带有app以及version标签
* Applicatin UID:不要使用ID(UID)值为1337的用户来运行应用
* NET_ADMIN:如果集群中实施了POD安全策略,除非使用Istio CNI插件,POD必须有NET_ADMIN功能