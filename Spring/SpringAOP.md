# SpringAOP



# AOP术语



## Joinpoint



* 连接点,指那些被拦截到的点.在spring中,指的是方法,因为spring只支持方法类型的连接点



## Pointcut



* 切入点,指要对哪些Joinpoint进行拦截的定义



## Advice



* 通知,指拦截到Joinpoint之后所要做的事情.通知的类型:前置通知,后置通知,异常通知,最终通知,环绕通知



## Introduction



* 引介,一种特殊的通知,在不修改类代码的前提下, 可以在运行期为类动态地添加一些方法或Field



## Target



* 代理的目标对象



## Weaving



* 织入,是指把增强应用到目标对象来创建新的代理对象的过程.spring采用动态代理织入,而AspectJ采用编译期织入和类装载期织入



## Proxy



* 一个类被AOP织入增强后,就产生一个结果代理类



## Aspect



* 切面,是切入点和通知（引介）的结合