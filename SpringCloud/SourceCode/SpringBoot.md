# SpringBoot



# 启动

## SpringApplication

```java
public ConfigurableApplicationContext run(String... args) {
    // 创建计时对象
    StopWatch stopWatch = new StopWatch();
    // 开启计时
    stopWatch.start();
    // 创建上下文对象
    ConfigurableApplicationContext context = null;
    Collection<SpringBootExceptionReporter> exceptionReporters = new ArrayList<>();
    // 设置Java.awt.headless
    configureHeadlessProperty();
    // 调用getRunListeners()获取并启动监听器
    SpringApplicationRunListeners listeners = getRunListeners(args);
    listeners.starting();
    try {
        // 创建对象,并将将启动时的参数传入到构造器
        ApplicationArguments applicationArguments = new DefaultApplicationArguments(
            args);
        // 准备环境
        ConfigurableEnvironment environment = prepareEnvironment(listeners,
applicationArguments);
        configureIgnoreBeanInfo(environment);
        // 打印Banner
        Banner printedBanner = printBanner(environment);
        // 创建Spring上下文环境
        context = createApplicationContext();
        // 获取exceptionReporters实例,主要是用做异常的处理
        exceptionReporters = getSpringFactoriesInstances(
            SpringBootExceptionReporter.class,
            new Class[] { ConfigurableApplicationContext.class }, context);
        // 准备上下文环境 
        prepareContext(context, environment, listeners, applicationArguments,
                       printedBanner);
        // 刷新上下文环境
        refreshContext(context);
        afterRefresh(context, applicationArguments);
        // 停止计时
        stopWatch.stop();
        // 日志的输出
        if (this.logStartupInfo) {
            new StartupInfoLogger(this.mainApplicationClass)
                .logStarted(getApplicationLog(), stopWatch);
        }
        // 发送上下文启动完成的通知
        listeners.started(context);
        // 执行所有runner容器
        callRunners(context, applicationArguments);
    } catch (Throwable ex) {
        // 异常处理
        handleRunFailure(context, ex, exceptionReporters, listeners);
        throw new IllegalStateException(ex);
    }

    try {
        // 发送上下文正在运行的通知
        listeners.running(context);
    } catch (Throwable ex) {
        // 异常处理
        handleRunFailure(context, ex, exceptionReporters, null);
        throw new IllegalStateException(ex);
    }
    return context;
}
```



```java
// 设置Java.awt.headless
private void configureHeadlessProperty() {
    System.setProperty(SYSTEM_PROPERTY_JAVA_AWT_HEADLESS, System.getProperty(
        SYSTEM_PROPERTY_JAVA_AWT_HEADLESS, Boolean.toString(this.headless)));
}
```



```java
// 获取并启动监听器
private SpringApplicationRunListeners getRunListeners(String[] args) {
    Class<?>[] types = new Class<?>[] { SpringApplication.class, String[].class };
    return new SpringApplicationRunListeners(logger, getSpringFactoriesInstances(
        SpringApplicationRunListener.class, types, this, args));
}
```



```java
// 准备Environment环境
private ConfigurableEnvironment prepareEnvironment(
    SpringApplicationRunListeners listeners,
    ApplicationArguments applicationArguments) {
    // 创建或获取环境对象实例
    ConfigurableEnvironment environment = getOrCreateEnvironment();
    // 配置环境信息
    configureEnvironment(environment, applicationArguments.getSourceArgs());
    // 发送环境已经准备完成的通知
    listeners.environmentPrepared(environment);
    // 绑定环境中spring.main属性绑定到SpringApplication对象中
    bindToSpringApplication(environment);
    // 在配置文件中使用spring.main.web-application-type属性手动设置了webApplicationType
    if (this.webApplicationType == WebApplicationType.NONE) {
        // 将环境对象转换成用户设置的webApplicationType相关类型,他们是继承同一个父类,直接强转
        environment = new EnvironmentConverter(getClassLoader())
            .convertToStandardEnvironmentIfNecessary(environment);
    }
    ConfigurationPropertySources.attach(environment);
    return environment;
}
```



```java
// 准备上下文环境
private void prepareContext(ConfigurableApplicationContext context,
                            ConfigurableEnvironment environment, SpringApplicationRunListeners listeners,
                            ApplicationArguments applicationArguments, Banner printedBanner) {
    // 设置上下文环境
    context.setEnvironment(environment);
    // 给IOC容器注册一些组件
    postProcessApplicationContext(context);
    // 执行所有初始化的方法
    applyInitializers(context);
    // 发送上下文环境准备完成的通知
    listeners.contextPrepared(context);
    // 日志记录
    if (this.logStartupInfo) {
        logStartupInfo(context.getParent() == null);
        logStartupProfileInfo(context);
    }

    // 添加特殊的启动单例
    context.getBeanFactory().registerSingleton("springApplicationArguments",
                                               applicationArguments);
    if (printedBanner != null) {
        context.getBeanFactory().registerSingleton("springBootBanner", printedBanner);
    }

    // 加载所有资源
    Set<Object> sources = getAllSources();
    Assert.notEmpty(sources, "Sources must not be empty");
    // 加载bean到上下文
    load(context, sources.toArray(new Object[0]));
    // 发送上下文加载完成的通知
    listeners.contextLoaded(context);
}
```

