# SpringBoot



# 启动



## SpringApplication



```java
@SuppressWarnings({ "unchecked", "rawtypes" })
public SpringApplication(ResourceLoader resourceLoader, Class<?>... primarySources) {
    this.resourceLoader = resourceLoader;
    Assert.notNull(primarySources, "PrimarySources must not be null");
    this.primarySources = new LinkedHashSet<>(Arrays.asList(primarySources));
    // 设置应用是SERVLET应用还是REACTIVE应用
    this.webApplicationType = WebApplicationType.deduceFromClasspath();
    // 初始化BootstrapRegistryInitializer实现类
    this.bootstrapRegistryInitializers = new ArrayList<>(
        getSpringFactoriesInstances(BootstrapRegistryInitializer.class));
     // 初始化Initializer,最后会调用这些初始化器.这些初始化器都是ApplicationContextInitializer的实现类,在Spring上下文刷新之前进行初始化
    setInitializers((Collection) getSpringFactoriesInstances(ApplicationContextInitializer.class));
    // 设置监听器,都是ApplicationListener实现类
    setListeners((Collection) getSpringFactoriesInstances(ApplicationListener.class));
    // 设置mainApplicationClass,用于推断并设置main()方法所在类为启动类
    this.mainApplicationClass = deduceMainApplicationClass();
}
```



```java
public ConfigurableApplicationContext run(String... args) {
    // 创建计时对象
    StopWatch stopWatch = new StopWatch();
    // 开启计时
    stopWatch.start();
    // 创建上下文对象
    ConfigurableApplicationContext context = null;
    // 异常报告
    Collection<SpringBootExceptionReporter> exceptionReporters = new ArrayList<>();
    // 设置Java.awt.headless
    configureHeadlessProperty();
    // 调用getRunListeners()获取并启动监听器
    SpringApplicationRunListeners listeners = getRunListeners(args);
    listeners.starting();
    try {
        // 创建启动参数对象,并将将启动时的参数传入到构造器
        ApplicationArguments applicationArguments = new DefaultApplicationArguments(args);
        // 创建并配置当前项目的Environment,调用所有SpringApplicationRunListener的environmentPrepared()
        ConfigurableEnvironment environment = prepareEnvironment(listeners, applicationArguments);
        configureIgnoreBeanInfo(environment);
        // 打印Banner
        Banner printedBanner = printBanner(environment);
        // 创建Spring上下文容器
        context = createApplicationContext();
        // 获取exceptionReporters实例,主要是用做异常的处理
        exceptionReporters = getSpringFactoriesInstances(
            SpringBootExceptionReporter.class,
            new Class[] { ConfigurableApplicationContext.class }, context);
        // Spring上下文环境前置处理,将启动类注入容器,为后续开启自动化配置做基础
        prepareContext(context, environment, listeners, applicationArguments, printedBanner);
        // 刷新上下文环境
        refreshContext(context);
        // Spring上下文后置处理,扩展接口,可自定义处理
        afterRefresh(context, applicationArguments);
        // 停止计时
        stopWatch.stop();
        // 日志的输出
        if (this.logStartupInfo) {
            new StartupInfoLogger(this.mainApplicationClass).logStarted(getApplicationLog(), stopWatch);
        }
        // 发送上下文启动完成的通知
        listeners.started(context);
        // 执行所有runner容器,只在启动时执行一次
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
// 准备Environment环境,加载外部配置资源到environment,包括启动时参数,application.yml等配置文件,servletConfigInitParams,servletContextInitParams,random,systemProperties,systemEnvironment
private ConfigurableEnvironment prepareEnvironment(SpringApplicationRunListeners listeners,ApplicationArguments applicationArguments) {
    // 创建或获取环境对象实例
    ConfigurableEnvironment environment = getOrCreateEnvironment();
    // 配置环境信息,处理PropertySource和active profiles
    configureEnvironment(environment, applicationArguments.getSourceArgs());
    // 发送环境已经准备完成的通知,即监听ApplicationEnvironmentPreparedEvent事件
    listeners.environmentPrepared(environment);
    // 绑定环境中spring.main属性到SpringApplication对象中
    bindToSpringApplication(environment);
    // 在配置文件中使用spring.main.web-application-type属性手动设置了webApplicationType,当前为非Web环境
    if (this.webApplicationType == WebApplicationType.NONE) {
        // 将环境对象转换成用户设置的webApplicationType相关类型,他们是继承同一个父类,直接强转为StandardEnvironment
        environment = new EnvironmentConverter(getClassLoader()).convertToStandardEnvironmentIfNecessary(environment);
    }
    // 配置PropertySource的递归依赖
    ConfigurationPropertySources.attach(environment);
    return environment;
}
```



```java
// 准备上下文环境,注入自动配置类
private void prepareContext(ConfigurableApplicationContext context,
                            ConfigurableEnvironment environment, SpringApplicationRunListeners listeners,
                            ApplicationArguments applicationArguments, Banner printedBanner) {
    // 设置上下文环境,包括各种变量
    context.setEnvironment(environment);
    // 给IOC容器注册一些组件,设置上下文的bean生成器和资源加载器
    postProcessApplicationContext(context);
    // 执行所有初始化的方法,包括spring.factories和自定义的实例
    applyInitializers(context);
    // 发送上下文环境准备完成的通知,触发SpringApplicationRunListener的contextPrepared事件方法
    listeners.contextPrepared(context);
    // 日志记录
    if (this.logStartupInfo) {
        logStartupInfo(context.getParent() == null);
        logStartupProfileInfo(context);
    }

    // 注册启动参数bean,这里将容器指定的参数封装成bean,注入容器
    context.getBeanFactory().registerSingleton("springApplicationArguments", applicationArguments);
    if (printedBanner != null) {
        context.getBeanFactory().registerSingleton("springBootBanner", printedBanner);
    }

    // 加载所有资源
    Set<Object> sources = getAllSources();
    Assert.notEmpty(sources, "Sources must not be empty");
    // 加载bean到上下文,加载启动类,将启动类注入容器,为后续开启自动化配置打基础
    load(context, sources.toArray(new Object[0]));
    // 触发所有SpringApplicationRunListener的contextLoaded事件
    listeners.contextLoaded(context);
}
```



```java
private void refreshContext(ConfigurableApplicationContext context) {
    if (this.registerShutdownHook) {
        // 注册shutdownHook钩子,用来手动关机
        shutdownHook.registerApplicationContext(context);
    }
    // 刷新spring容器,对整个ioc容器的初始化,包括对bean资源的定位,解析,注册,实例化等
    refresh(context);
}
```

