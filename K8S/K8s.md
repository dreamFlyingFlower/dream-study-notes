# K8S

https://www.yuque.com/leifengyang/oncloud

# 概述



* Kubernetes 提供了一个可弹性运行分布式系统的框架,满足用户的扩展要求、故障转移、部署模式等
* 服务发现和负载均衡:Kubernetes 可以负载均衡并分配网络流量,从而使部署稳定
* 存储编排:Kubernetes 允许自动挂载自定义存储系统,例如本地存储、公共云提供商等
* 自动部署和回滚:可以使用 Kubernetes 描述已部署容器的所需状态,它可以以受控的速率将实际状态更改为期望状态.例如,可以自动化 Kubernetes 来为你的部署创建新容器, 删除现有容器并将它们的所有资源用于新容器
* 自动完成装箱计算:Kubernetes 允许指定每个容器所需 CPU 和内存,当容器指定了资源请求时,Kubernetes 可以做出更好的决策来管理容器的资源
* 自我修复:Kubernetes 重新启动失败的容器,替换容器,杀死不响应用户定义的运行状况检查的容器,并且在准备好服务之前不将其通告给客户端
* 密钥与配置管理:Kubernetes 允许存储和管理敏感信息,例如密码,OAuth 令牌和 ssh 密钥.用户可以在不重建容器镜像的情况下部署和更新密钥和应用程序配置,也无需在堆栈配置中暴露密钥
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

## Kubeadm

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



# 安装



* 所有节点需要先安装docker,参照Docker文档



## 设置基础环境



* 集群中的所有机器的网络彼此均能相互连接(公网和内网都可以)
* 节点之中不可以有重复的主机名、MAC 地址或 product_uuid,[文档](https://kubernetes.io/zh/docs/setup/production-environment/tools/kubeadm/install-kubeadm/#verify-mac-address),要设置不同的hostname
* 开启机器上的某些端口,[文档](https://kubernetes.io/zh/docs/setup/production-environment/tools/kubeadm/install-kubeadm/#check-required-ports)
* 禁用交换分区,为了保证 kubelet 正常工作,必须禁用交换分区

```shell
# 各个机器设置自己的域名
hostnamectl set-hostname xxxx

# 将 SELinux 设置为 permissive 模式,相当于将其禁用
setenforce 0
sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

# 关闭swap
swapoff -a 
sed -ri 's/.*swap.*/#&/' /etc/fstab

# 允许 防火墙 检查桥接流量
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
br_netfilter
EOF

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sudo sysctl --system
```



## 安装kubelet、kubeadm、kubectl



```shell
cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
# k8s镜像地址,可自定义
baseurl=http://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=0
repo_gpgcheck=0
gpgkey=http://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg
   http://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
exclude=kubelet kubeadm kubectl
EOF

# 安装kubelet、kubeadm、kubectl,根据情况安装指定版本
sudo yum install -y kubelet-1.20.9 kubeadm-1.20.9 kubectl-1.20.9 --disableexcludes=kubernetes

sudo systemctl enable --now kubelet

# 安装完成后,kubelet每隔几秒就会重启,因为它陷入了一个等待 kubeadm 指令的死循环
```



## 下载服务器镜像



```shell
# 在每一台机器上都执行如下脚本
sudo tee ./images.sh <<-'EOF'
#!/bin/bash
images=(
kube-apiserver:v1.20.9
kube-proxy:v1.20.9
kube-controller-manager:v1.20.9
kube-scheduler:v1.20.9
coredns:1.7.0
etcd:3.4.13-0
pause:3.2
)
for imageName in ${images[@]} ; do
# docket镜像仓库地址,可自定义
docker pull registry.cn-hangzhou.aliyuncs.com/lfy_k8s_images/$imageName
done
EOF

# 执行上述脚本
chmod +x ./images.sh && ./images.sh
```



## 初始化主节点



```shell
# 所有机器(包括master本身)添加master域名映射,以下需要修改为自己的master节点ip以及hostname
echo "192.168.0.150  cluster-endpoint" >> /etc/hosts

# master主节点初始化,只在主节点操作
kubeadm init \
# master节点IP地址
--apiserver-advertise-address=192.168.0.150 \
# master节点hostname
--control-plane-endpoint=cluster-endpoint \
# docket镜像仓库地址,可自定义
--image-repository registry.cn-hangzhou.aliyuncs.com/lfy_k8s_images \
# k8s
--kubernetes-version v1.20.9 \
# k8s内部通讯网络范围,需根据实际情况修改
--service-cidr=10.96.0.0/16 \
--pod-network-cidr=192.168.1.0/16

# 所有网络范围不重叠,包括节点,--service-cidr,--pod-network-cidr
```



```shell
# 安装成功
Your Kubernetes control-plane has initialized successfully!

To start using your cluster, you need to run the following as a regular user:
# 开始使用集群,直接复制运行即可
  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

Alternatively, if you are the root user, you can run:

# root用户操作
  export KUBECONFIG=/etc/kubernetes/admin.conf

You should now deploy a pod network to the cluster.
# 一个网络插件
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  https://kubernetes.io/docs/concepts/cluster-administration/addons/

You can now join any number of control-plane nodes by copying certificate authorities
and service account keys on each node and then running the following as root:
# 添加主节点(master)节点命令
  kubeadm join cluster-endpoint:6443 --token hums8f.vyx71prsg74ofce7 \
    --discovery-token-ca-cert-hash sha256:a394d059dd51d68bb007a532a037d0a477131480ae95f75840c461e85e2c6ae3 \
    --control-plane 

Then you can join any number of worker nodes by running the following on each as root:
# 添加工作节点命令
kubeadm join cluster-endpoint:6443 --token hums8f.vyx71prsg74ofce7 \
    --discovery-token-ca-cert-hash sha256:a394d059dd51d68bb007a532a037d0a477131480ae95f75840c461e85e2c6ae3
```



## 设置config目录



* 根据上文中的提示,设置config目录,只需要在master节点设置

```shell
  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config
```



## 安装网络插件



```shell
# 根据上述安装成功提示,选择任意一个网络插件进行安装,只需要在master节点运行
curl https://docs.projectcalico.org/manifests/calico.yaml -O
# 应用配置文件,该配置文件设置了安装k8s时的--pod-network-cidr地址
kubectl apply -f calico.yaml
```



## 添加work节点



```shell
# 在每个work节点运行k8s安装成功时的命令
kubeadm join cluster-endpoint:6443 --token hums8f.vyx71prsg74ofce7  --discovery-token-ca-cert-hash sha256:a394d059dd51d68bb007a532a037d0a477131480ae95f75840c461e85e2c6ae3
# 如果令牌过期,则可以使用如下命令重新生成令牌
kubeadm token create --print-join-command
```



## 安装Dashboard



* [kubernetes官方提供的可视化界面](https://github.com/kubernetes/dashboard)

```shell
# 主节点下载运行dashboard配置文件
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.3.1/aio/deploy/recommended.yaml
# 设置访问端口
kubectl edit svc kubernetes-dashboard -n kubernetes-dashboard
```





# Shell



* `kubectl get nodes`: 查看集群所有节点,只能在主节点运行
* `kubectl apply -f xxxx.yaml`: 根据配置文件,给集群创建资源
* `kubectl get pods -A`: 查看集群部署了哪些应用
* `kubectl get pods -A`: 运行中的应用在docker里面叫容器,在k8s里面叫Pod
* `kubeadm token create --print-join-command`: 主节点运行,创建新令牌





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