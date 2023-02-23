# Gradle



# 安装



* [官网下载](https://gradle.org/)

* 解压,需要先配置JDK

* 配置Gradle环境变量: `GRADLE_HOME=F:\software\gradle-7.6`,配置Path

* 配置Gradle临时文件路径:`GRAGLE_USER_HOME=F:\software\gradle-7.6\.gradle`.若不配置,则临时文件会下载到C盘中

* `gradle -v`: 出现版本信息即完成

* 在gradle安装目录下的init.d目录中,新建一个init.gradle文件,指定maven仓库,输入内容如下

  ```groovy
  allprojects {
      repositories {
          // 本地Maven路径
          maven { url 'file:///D:/software/maven/LocalRespority'}
          // mavenLocal()是获取Maven本地仓库的路径,和第一条一样,但是不冲突
          mavenLocal()
          // 阿里的bsdn的镜像路径
          maven { name "Alibaba" ; url "https://maven.aliyun.com/repository/public" }
          maven { url "https://maven.aliyun.com/repository/jcenter" }
          maven { url "https://maven.aliyun.com/repository/spring" }
          maven { url "https://maven.aliyun.com/repository/spring-plugin" }
          maven { url "https://maven.aliyun.com/repository/gradle-plugin" }
          maven { url "https://maven.aliyun.com/repository/google" }
          maven { url "https://maven.aliyun.com/repository/grails-core" }
          maven { url "https://maven.aliyun.com/repository/apache-snapshots" }
          maven { name "Bstek" ; url "https://nexus.bsdn.org/content/groups/public/" }
          // mavenCentral() 是从Apache提供的中央仓库获取jar包
          mavenCentral()
      }
      buildscript { 
          repositories { 
              maven { name "Alibaba" ; url 'https://maven.aliyun.com/repository/public' }
              maven { name "Bstek" ; url 'https://nexus.bsdn.org/content/groups/public/' }
              maven { name "M2" ; url 'https://plugins.gradle.org/m2/' }
          }
      }
  }
  ```

* 编译:`gradle build -x test`



# 依赖



* `implementation`:默认的scope,编译和运行时可见,但不会传递给下一级依赖,即其他人使用我们的类库时,编译时不会出现类库的依赖
* `api`:和implementation类似,编译和运行时可见,但是api允许我们将自己类库的依赖暴露给我们类库的使用者
* `compileOnly`,`runtimeOnly`:一种只在编译时可见,一种只在运行时可见,runtimeOnly和Maven的provided比较接近
* `testImplementation`:测试编译时和运行时可见,类似于Maven的test
* `testCompileOnly`,`testRuntimeOnly`:类似于compileOnly和runtimeOnly,但是作用于测试编译时和运行时
