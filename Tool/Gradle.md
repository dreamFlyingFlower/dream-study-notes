# Gradle



# 安装



* [官网下载](https://gradle.org/)
* 解压,需要先配置JDK
* 配置Gradle环境变量: `GRADLE_HOME=xxxx`,
* 配置Gradle仓库:`GRAGLE_USER_HOME=xxxx`.若不配置,则Jar包会下载到`C\user\.m\repository`中,可以指定为maven仓库地址,需要先配置maven仓库
* `gradle -v`: 出现版本信息即完成



# 编译Springboot源码



* [源码地址](https://github.com/spring-projects/spring-boot)
* 下载tag标签的2.3.xx版本源码zip文件,解压
* 进入源码目录,打开 gradle.properties 文件,可以修改版本号,避免与官网的版本冲突

```
version=2.3.12.RELEASE-DREAM
```

* build.gradle配置项目依赖仓库与插件仓库,依赖仓库添加本地maven仓库与阿里镜像仓库

```gradle
allprojects {

    repositories {
        // 本地仓库,需配置GRADLE_USER_HOME,否则在user/.m2/repository
        mavenLocal()
        // aliyun镜像
        maven { url 'https://maven.aliyun.com/nexus/content/groups/public/'}
        maven { url 'https://maven.aliyun.com/repository/central'}
	maven { url 'https://maven.aliyun.com/repository/public' }
        
        mavenCentral()
        if (!version.endsWith('RELEASE')) {
            maven { url "https://repo.spring.io/milestone" }
        }
        if (version.endsWith('BUILD-SNAPSHOT')) {
            maven { url "https://repo.spring.io/snapshot" }
        }
    }
}
```

* settings.gradle插件仓库添加本地maven仓库与阿里镜像仓库,且将插件 io.spring.gradle-enterprise-conventions 注释

```
pluginManagement {
    repositories {
        // 本地仓库,需配置GRADLE_USER_HOME,否则在user/.m2/repository
        mavenLocal()
        // aliyun镜像
        maven { url 'https://maven.aliyun.com/nexus/content/groups/public/'}
        maven { url 'https://maven.aliyun.com/repository/central'}
	maven { url 'https://maven.aliyun.com/repository/public' }

        mavenCentral()
        
        gradlePluginPortal()
        maven {
            url 'https://repo.spring.io/plugins-release'
        }
        if (version.endsWith('BUILD-SNAPSHOT')) {
            maven { url "https://repo.spring.io/snapshot" }
        }
    }
}

plugins {
    id "com.gradle.enterprise" version "3.2"
//     id "io.spring.gradle-enterprise-conventions" version "0.0.2"
}
```

* `gradle build -x test`: 命令号进行编译构建,-x test 是跳过测试

* 如果构建报错如:`BomPluginIntegrationTests xxxxx`,可以在该文件中注释掉相关行
* 大概下载30分钟到1小时构建完成