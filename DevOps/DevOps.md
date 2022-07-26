# DevOps



# 概述



* DevOps 是软件开发人员(Dev)和IT运维技术人员(Ops)之间沟通合作的文化,运动或惯例,透过自动化软件交付和架构变更的流程,来使得构建,测试,发布软件能够更加地快捷,频繁和可靠



# 持续集成



* Continuous integration,简称 CI,指的是频繁地将代码集成到主干.持续集成的目的就是让产品可以快速迭代,同时还能保持高质量.它的核心措施是,代码集成到主干之前,必须通过自动化测试,只要有一个测试用例失败,就不能集成.通过持续集成, 团队可以快速的从一个功能到另一个功能,敏捷软件开发很大一部分都要归功于持续集成  



## 执行流程



![](img/001.png)



* 研发工程师将测试验收后的源码上传到GitLab,并创建新的版本分支
* 在GitLab创建新的版本分支后,研发工程师还需要创建 Dockerfile 来构建Docker镜像,之后将Dockerfile也上传到该分支
* 在GitLab中新版本源码与Dockerfile都已上传,开始Jenkins的自动化脚本完成镜像的自动化构建与仓库推送,这个自动化脚本包含3个步骤:
  * 拉取最新源码到Jenkins服务器,利用服务器上的Maven自动完成编译,测试,打包的过程
  * 拉取最新版本Dockerfile到Jenkins服务器,利用Docker完成镜像构建工作,在构建过程中需要将上一步生成的 Jar 文件包含在内,在容器创建时自动执行这个 Jar 文件
  * 镜像生成后,通过Jenkins服务器上的Docker将新版本镜像推送到Docket镜像私有仓库,此时软件工程师的任务已完成

* 在上线日运维接入 Kubernetes 管理端,发起 Deploy 部署,此时生产环境的 K8S 节点会从Docker私有仓库抽取最新版本的应用镜像,并在服务器上自动创建容器.在校验无误后,本次上线宣告成功
* 真实环境过程复杂得多,还要考虑多种异常因素,例如:
  * 源码编译,打包时产生异常的快速应对机制
  * 上线失败如何快速应用回滚
  * 镜像构建失败的异常跟踪与补救措施