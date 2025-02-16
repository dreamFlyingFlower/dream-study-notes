# Grafana



* 监控容器的内存数据,并配置警告



# 告警设置



* Grafana的告警系统允许根据收集的指标配置告警,可以自定义告警,当应用程序的内存使用率超过某个阈值时进行通知
  * 在仪表盘中,点击面板并选择Edit
  * 在Alert选项卡下,配置您的告警条件
  * 设置通知渠道,如电子邮件或 Slack,以便发送告警



# 整合SpringBoot



* 添加依赖

```xml
<!-- Micrometer是指标收集库,Prometheus注册表帮助收集和存储指标 -->
<dependency>
    <groupId>io.micrometer</groupId>
    <artifactId>micrometer-registry-prometheus</artifactId>
</dependency>
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-actuator</artifactId>
</dependency>
```

* 在application.yml中暴露指标

```yaml
management:
  endpoints:
    web:
      exposure:
        include: *
    metrics:
      enabled: true
  metrics:
    export:
      prometheus:
        enabled: true
```

* 配置prometheus.yml

```yaml
global:
  # prometheus抓取指标的频率
  scrape_interval: 15s 

scrape_configs:
  - job_name: 'spring-boot-app'
    # Spring Boot Actuator 暴露指标的端点
    metrics_path: '/actuator/prometheus'
    static_configs:
      # 定义prometheus可以找到Spring Boot应用程序的位置,即应用程序运行的ip:端口
      - targets: ['localhost:8080']
```

* 运行prometheus

```shell
./prometheus --config.file=prometheus.yml
```

* 浏览器打开`localhost:9090`访问prometheus
* 安装grafana
* 添加prometheus作为数据源
  * 访问`localhost:3000`进入grafana并登录
  * 再Configuration菜单下,选择Data Source,并添加Prometheus作为数据源,URL为`localhost:9000`
  * 创建一个新的仪表盘
  * 通过查询Prometheus指标来向仪表盘添加面板.如监控JVM内存使用情况,可使用查询`jvm_memory_used_bytes`
* grafana创建自定义可视化图表,常见指标的监控示例
  * 内存使用情况:`jvm_memory_used_bytes`
  * CPU 负载:`system_cpu_usage`
  * HTTP 请求:`http_server_requests_seconds_count`





