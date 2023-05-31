# GC



![](img/001.png)



# GC算法



## 引用计数法



* 比较古老而经典的垃圾收集算法,核心就是在对象被其他对象引用时计数器加1,而当引用失效时则减1



### 优点



* 实时性高,无需等到内存不足时才回收.只要计数为0就可以回收
* 在垃圾回收过程中无需STW.申请内存时不足,直接OOM
* 更新对象的计数器时,只影响该对象区域,不扫描全部对象



### 缺点



* 浪费CPU资源,即使内存够用,仍然在运行计数器的统计
* 最大的缺点是无法处理循环引用的情况,而且每次进行加减操作比较浪费系统性能



## 可达性算法



* 兼具引用计数法的优点,同时解决了循环引用的问题,JVM使用的是该算法
* 可达性分析算法是以根对象集合(GC Roots)为起始点,按照从上至下的方式搜索被根对象集合所连接的目标对象是否可达
* 使用可达性分析算法后,内存中的存活对象都会被根对象集合直接或间接连接着,搜索所走过的路径称为引用链(Reference chain)
* 如果目标对象没有任何引用链相连,则是不可达的,就意味着该对象己经死亡,可以标记为垃圾对象
* 在可达性分析算法中,只有能够被根对象集合直接或者间接连接的对象才是存活对象
* 如果要使用可达性分析算法来判断内存是否可回收,分析工作必须在一个能保障一致性的快照中进行,否则分析结果的准确性就无法保证,这也是导致GC时必须STW的一个重要原因.即使是号称(几乎)不会发生停顿的CMS 收集器中,枚举根节点时也是必须要停顿的



### GC Roots



* 虚拟机栈中引用的对象.比如:各个线程被调用的方法中使用到的参数,局部变量等
* 本地方法栈内JNI(通常说的本地方法)引用的对象
* 方法区中类静态属性引用的对象(JDK8在堆中).比如: Java类的引用类型静态变量
* 方法区中常量引用的对象.比如:字符串常量池 (string Table)里的引用
* 所有被同步锁synchronized持有的对象
* Java虚拟机内部的引用.基本数据类型对应的class对象,一些常驻的异常对象(如:NullPointerException,OutOfMemoryError),系统加载器
* 反映Java虚拟机内部情况的JMXBean、JVMTI中注册的回调,本地代码缓存等
* 除了这些固定的GC Roots集合以外,根据用户所选用的垃圾收集器以及当前回收的内存区域不同,还可以有其他对象临时性地加入,共同构成完整GC Roots集合.比如: 分代收集和局部回收 (Partial GC)



### 回收判定



* 判定一个对象obj是否可回收,至少要经历两次标记过程:
  * 如果obj到 GC Roots没有引用链,则进行第一次标记
  * 进行筛选,判断obj是否有必要执行finalize()
    * 如果obj没有finalize()或obj重写了finalize()且已经被虚拟机调用过,则obj被判定为不可触及的
    * 如果obj重写了finalize()且还未执行过,那么obj会被插入到F-Queue队列中,由一个虚拟机自动创建的,低优先级的Finalizer线程触发其finalize()并执行
    * finalize()是对象逃脱死亡的最后机会,稍后GC会对F-Queue队列中的对象进行第二次标记.如果obj在finalize()中与引用链上的任何一个对象建立了联系,那么在第二次标记时,obj会被移出即将回收集合.之后,对象再次出现没有引用存在的情况时,finalize()不会被再次调用,对象会直接变成不可触及的状态,也就是说,一个对象的finalize()只会被调用一次



## 标记清除法



* 标记和清除阶段:在标记阶段,首先通过根节点,标记所有可达对象,未被标记的对象就垃圾对象.在清除阶段,线性清除所有未被标记的对象
* 这种方式的缺点就是空间碎片问题,垃圾回收后的空间不是连续的,工作效率要低于连续的内存空间,同时还需要维护一个空闲地址列表
* 清除并不是真的置空,而是把需要清除的对象地址保存在空闲的地址列表里,下次有新对象需要加载时,判断垃圾的位置空间是否足够,够就存放



## 标记压缩法



* 标记压缩法在标记清除法基础上做了优化,把存活的对象压缩到内存一端,而后进行垃圾清理
* Jvm中老年代就是使用的标记压缩法,没有碎片,但是效率偏低



## 复制算法



* 将内存空间分为两块,每次只使用其中一块,在垃圾回收时,将正在使用的内存中的存留对象复制到未被使用的内存块中,之后去清除之前正在使用内存块中所有的对象,反复去交换两个内存的角色,完成垃圾收集
* 适用于新生代垃圾回收,高效,没有碎片,但是浪费空间



## 分代算法



* 根据对象的特点把内存分为N块,而后根据每个内存的特点使用不同的算法:一般分为新生代,老年代,永久代,新生代又分为eden+s0+s1
* 对于新生代和老年代来说,新生代回收的频率更高,每次回收耗时短;老年代回收频率较低,耗时长,所以应该尽量减少老年代的GC
* 一般新生代使用复制算法,老年代使用标记压缩算法



## 分区算法(G1)



* 将整个内存分为N个小的独立空间,每个小空间都可以独立使用,每次GC可以回收多个小空间,而不是对整个空间进行回收
* 分Region回收,优先回收花费时间少,垃圾比例高的Region



## ZGC



* ZGC(Z Garbage Collector)是一款由Oracle公司研发的,以低延迟为首要目标的一款垃圾收集器
* 它是基于动态Region内存布局,不设年龄分代,使用了读屏障,染色指针和内存多重映射等技术来实现可并发的标记-整理算法的收集器
* 在 JDK 11 新加入,回收TB级内存,STW时间不超过10ms
* 优点: 低停顿,高吞吐量, ZGC 收集过程中额外耗费的内存小
* 缺点: 浮动垃圾



## GC停顿(STW)



* Java中一种全局暂停的现象,又称STW(Stop The World),任何一种垃圾回收器都有STW
* 垃圾回收器的任务是标记和回收垃圾对象,为了更高效的执行,大部分情况下,会要求系统进入一个停顿的状态.停顿的目的是终止所有应用线程,只有这样系统才不会有新的垃圾产生,同时保证了系统状态在某一个瞬间的一致性,也有益于更好的标记垃圾对象
* 全局停顿,Java代码停止,native代码可以执行,但不能和JVM交互
* STW多半由于GC引起:Dump线程;死锁检查;堆Dump
* STW长时间服务停顿,没有响应,一旦遇到HA系统,可能引起主备切换



## OopMap和安全点



* 映射表,在HotSpot中的数据结构.一旦类加载动作完成,HotSpot就会把对象内存偏移量上是什么类型的数据计算出来,记录到OopMap
* 在即时编译过程中,也会在特定的位置生成 OopMap,记录栈上和寄存器里哪些位置是引用
* 这些特定的位置主要在以下地方,这些位置就叫作安全点(safepoint):
  * 循环的末尾(非 counted 循环)
  * 方法临返回前 / 调用方法的call指令后
  * 可能抛异常的位置
* 用户程序执行时并非在代码指令流的任意位置都能够在停顿下来开始垃圾收集,而是必须执行到安全点才能够暂停进行GC
* 如何在GC时检查所有线程都跑到附近的安全点停下来:设置一个中断标志,各个线程运行到安全点后主动轮询这个标志,为真就停下来



## 安全区域



* 安全区域是指在一段代码片段中对象的引用关系不会发生变化,在这个区域上的任何位置开始GC都是安全的
* 安全点机制保证了程序执行时,在不太长的时间内就会遇到可进入 GC的 Safepoint,但是,线程处于 sleep 或 Blocked 状态时,线程无法响应 JVM 的中断请求,运行到安全点去中断挂起.对于这种情况,就需要安全区城(Safe Region)来解决
* 当线程运行到Safe Region时,首先标识已经进入了Safe Region,如果这段时间内发生GC,JVM会忽略标识为Safe Region状态的线程
* 当线程即将离开Safe Region时,会检查JVM是否已经完成GC,如果完成了,则继续运行,否则线程必须等待直到收到可以安全离开Safe Region的信号为止



## Remembered Set



* 一个对象可能被其他不同区域引用判断存活,为了保证准确,则需要扫描整个Java堆
* 为解决该问题,无论G1还是其他分代收集器,JVM都是使用Remembered Set来避免全局扫描:
  * 每个Region都有一个对应的Remembered Set,每次Reference类型数据写操作时,都会产生一个write Barrier暂时中断操作
  * 然后检查将要写入的引用指向的对象是否和该Reference类型数据在不同的Region(其他收集器:检查老年代对象是否引用了新生代对象)
  * 如果不同,通过CardTable把相关引用信息记录到引用指向对象的所在Region对应的Remembered Set中.当进行垃圾收集时,在GC根节点的枚举范围加入Remembered Set,就可以保证不进行全局扫描,也不会有遗漏



# 回收器



## 串行回收器



* 使用单线程进行垃圾回收.每次回收时,只有一个工作线程,对于并行能力较弱的计算机来说,串行回收器往往有更好的性能表现
* Serial:新生代回收器;Serial Old(MSC):老年代回收器
* -XX:+UseSerialGC:设置新生代和老年代都使用串行回收器;新生代使用复制算法,老年代使用标记压缩算法



## 并行回收器



### ParNew



* 新生代垃圾回收器,只是简单的将串行回收器多线程化,回收策略,算法和串行回收器一样
* -XX:+UseParNewGC:新生代并行回收器,老年代串行回收器
* -XX:ParallelGCThreads:指定年轻代的回收器线程数,一般最好和CPU核心数相当



### Parallel Scavenge



* Parallel Scavenge,类似ParNew,新生代并行收集器,使用复制算法,老年代标记-压缩算法
* Scavenge和ParNew不同在于根据吞吐量优先原则,自适应调节内存的分配情况
* -XX:+UseParallelGC:新生代使用Parallel Scavenge收集器,老年代默认使用Parallel Old
* -XX:ParallelGCThreads:指定年轻代的回收器线程数,一般最好和CPU核心数相当
  * 当CPU核心数小于8时,该值设置和CPU核心数相同
  * 当CPU核心数大于8时,该值理论上为`3 + (5 * CPU数) / 8`




### ParallelOldGC



* 并行垃圾收集器,适用于老年代
* -XX:+UseParallelOldGC:效果同上,老年代使用Parallel Old,默认会激活年轻代的Parallel Scavenge
* JDK8默认是Parallel Scavenge+Parallel Old



## CMS



![](img/019.png)



* ConcurrentMarkSweep,并发标记清除,使用的是标记清除算法,主要关注STW,针对老年代,默认会在一次FullGC后做整理算法,清理内存碎片
* CMS并不是独占回收器,回收过程中应用程序仍然在工作,会有新的垃圾不断产生,所以在使用CMS的过程中应确保应用程序的内存足够
* CMS不会等到应用程序饱和时才去回收垃圾,而是在某一个阀值的时候开始回收.如果内存使用率增长很快,在CMS执行过程中出现了内存不足的情况,此时回收就会失败,引起`Concurrent Mode Failure`异常,虚拟机将启动Serial Old GC进行垃圾回收,这会导致应用程序中断,直到GC完成后才会正常工作.这个过程GC停顿时间可能较长
* CMS垃圾回收分为4步:
  * 开始标记:仅标记GCRoots能直接关联到的对象,完成后会恢复所有暂停的线程.速度很快,会STW
  * 并发标记:遍历GCRoots,标记所有可达对象.此阶段用户线程仍然在运行,会产生新的垃圾.不会STW,速度慢
  * 重新标记:修正并发标记期间因用户程序继续运作而导致标记产生变动的那一部分对象,会STW,速度快
  * 垃圾回收:并发清理垃圾对象(标记清除算法),不会STW,速度慢

* CMS尽可能降低了STW,但会影响系统整体吞吐量和性能,而且清理不彻底,会产生内存碎片,适用于响应时间要求高的应用
* -XX:+UseConcMarkSweepGC:使用CMS GC,开启后将使用ParNew+CMS+Serial Old收集器组合,Serial Old是为了防止CMS回收失败
* -XX:ConcGCThreads:设置并发线程数
* -XX:ParallelCMSThreads:设定CMS的线程数量,默认为`(ParallelThreads + 3)/4`
* -XX:CMSInitiatingOccupancyFraction:指定回收阀值,JDK6以前默认是68,以后是92.即当老年代空间使用率达到92%时,会执行CMS回收
* -XX:+UseCMSCompactAtFullCollection:使用CMS回收器之后,是否进行碎片整理
* -XX:CMSFullGCsBeforeCompaction:设置进行多少次CMS回收之后对内存进行一次压缩



## G1



![](img/020.png)



* Garbage First(G1),目标是延迟可控的情况下尽量提高吞吐量.使用分区算法,将堆内存分成了很多不相关的区域(Region)
* Humongous:超大对象.当对象超过Region的一半(1.5倍Region),回收时将直接把该对象分配到老年代中,而不经过S区
* 每个Region只能是一种角色,但是可以相互转换
* 并行性:G1回收期间可多线程同时工作
* 并发性:G1回收时可与应用程序同时执行,在整个GC期间不会完全阻塞应用
* G1是一个分代收集器,区分新生代和老年代,有eden和from/to区,它不要求整个eden或新生代,老年代的空间都连续
* 空间整理:G1在回收过程中,不会像CMS那样在若干次GC后需要进行碎片整理,G1采用了有效复制对象的方式,减少空间碎片
* G1内存的回收是以Region为基本单位的.Region之间是复制算法,但整体上实际可看作是标记-压缩算法,两种算法都可以避免内存碎片.这种特性在分配大对象时不会因为无法找到连续内存空间而提前触发下一次 GC,尤其是当Java堆非常大的时候,G1的优势更加明显
* 可预见性:由于分区的原因,G1可以只选取部分区域进行回收,缩小了回收的范围,提升性能.优先回收花费时间少,垃圾比例高的区域
* G1 跟踪各个 Region里面的垃圾堆积的价值大小(回收所获得的空间大小以及回收所需时间的经验值),在后台维护一个优先列表,每次根据允许的收集时间,优先回收价值最大的Region,即垃圾优先策略-Garbage First
* G1的垃圾回收过程主要包括如下三个环节:
  * 年轻代GC (Young Gc):G1的年轻代收集阶段是一个并行的独占式收集器.在年轻代回收期,G1暂停所有应用程序线程,启动多线程执行年轻代回收.然后从年轻代区间移动存活对象到S区或O区,也有可能是两个区间都会涉及
  * 老年代并发标记过程 (Concurrent Marking):当堆内存使用达到一定值(默认45%)时,开始老年代并发标记过程
  * 混合回收 (Mixed Gc):标记完成后马上开始混合回收.G1从O区移动存活对象到空闲区,这些空闲区间也就成为了老年代的一部分.和年轻代不同,G1的老年代回收器一次只需要扫描/回收一小部分老年代的Region.同时,这个老年代Region是和年轻代一起被回收的
  * Full GC:它针对GC的评估失败提供了一种失败保护机制,即强力回收
* 新生代一般不用手动指定,初始化为整个堆的5%~60%,当达到60%时就会进行垃圾回收
* -XX:+UseG1GC:使用G1回收器,新生代和老年代都是G1.JDK9以后默认使用
* -XX:MaxGCPauseMillis:指定最大停顿时间,默认是200ms.JVM只能尽量保证该时间内完成
* -XX:ParallelGCThreads:设置并行回收的线程数量,最多为8
* -XX:InitiatingHeapOccupancyPercent:触发GC的堆占用率大小,默认45%时触发mixed gc
* -XX:G1HeapRegionSize:1,2,4,8,16,32,只有这几个值,单位是M,分成2048个区域,默认为堆的1/2000



## 垃圾回收器组合



![](img/029.png)



* 在JDK8中废弃了Serial GC+CMS,ParNew GC+Serial Old GC,不建议使用这些组合;在JDK9中彻底移除了这2种组合
* 在JDK14种废弃了Parallel Scavenge GC+Serial Old GC,不建议使用,彻底移除了CMS
* Parallel Scavenge GC和CMS之所以不能组合使用,是因为Parallel Scavenge GC底层框架和CMS不兼容,无法使用
* CMS能和MSC使用是一种备用方案,因为CMS可能回收失败,失败后利用MSC进行垃圾回收



## 查看垃圾回收器



* -XX:+PrintCommandLineFlags:显示当前JVM使用的垃圾回收器以及初始堆配置
* jinfo -flag 相关垃圾回收参数 进程ID:查看相关参数是否使用



## Minor GC



* 也叫Young GC(YGC),主要对年轻代进行垃圾回收
* 对于复制算法来说,当年轻代Eden区域满的时候会触发一次Minor GC,将Eden和From Survivor的对象复制到另外一块To Survivor上
* 如果某个对象存活的时间超过一定Minor gc次数会直接进入老年代,不再分配到To Survivor上
* -XX:+MaxTenuringThreshold:默认15,经过15即从新生代转到老年代



## Full GC



* 用于清理整个堆空间,它的触发条件主要有以下几种:
  * 显式调用System.gc()(建议JVM触发)
  * 方法区空间不足(JDK8及之后不会有这种情况了,详见下文)
* 老年代空间不足,引起Full GC.这种情况比较复杂,有以下几种:
  * 大对象直接进入老年代引起,由-XX:PretenureSizeThreshold参数定义
  * 经历多次Minor GC仍存在的对象进入老年代,由-XX:MaxTenuringThreashold定义
  * Minor GC时,动态对象年龄判定机制会将对象提前转移老年代.年龄从小到大进行累加,当加入某个年龄段后,累加和超过survivor区域-XX:TargetSurvivorRatio的时候,从这个年龄段往上的年龄的对象进入老年代
  * Minor GC时,Eden和From Space区向To Space区复制时,大于To Space区可用内存,会直接把对象转移到老年代
* JVM的空间分配担保机制可能会触发Full GC:
  * 在进行Minor GC之前,JVM的空间担保分配机制可能会触发上述老年代空间不足引发的Full GC
  * 空间担保分配是指在发生Minor GC之前,虚拟机会检查老年代最大可用的连续空间是否大于新生代所有对象的总空间
    * 如果大于,则此次Minor GC是安全的
    * 如果小于,则虚拟机会查看HandlePromotionFailure设置值是否允许担保失败
    * 如果HandlePromotionFailure=true,那么会继续检查老年代最大可用连续空间是否大于历次晋升到老年代的对象的平均大小,如果大于,则尝试进行一次Minor GC,但这次Minor GC依然是有风险的,失败后会重新发起一次Full GC;如果小于或者HandlePromotionFailure=false,则改为直接进行一次Full GC



# 内存分配策略



* 优先分配到eden
* 大对象直接分配到老年代
* 长期存活的对象分配到老年代
* 空间分配担保:即新生代内存不足时,可能会向老年代借用内存
* 动态对象年龄判断



# 分代回收流程



* 根据对象大小先分配到适当的分代中
* YGC回收之后,大多数对象会被回收,活着的会进入S0区
* 再次YGC,在Eden区和S0区的进入S1区
* 继续YGC,Eden区+S1区进入S0
* 经过多次YGC(默认15次),在S0或S1区的对象进入老年代
* S0或S1区没有足够大小,也会将对象方法老年代



# 性能指标



* 吞吐量: 运行用户代码的时间占总运行时间的比例(总运行时间:程序的运行时间+内存回收的时间)
* 暂停时间:执行垃圾收集时,程序的工作线程被暂停的时间
* 内存占用: Java 堆区所占的内存大小
* 垃圾收集开销:吞吐量的补数,垃圾收集所用时间与总运行时间的比例
* 收集频率:相对于应用程序的执行,收集操作发生的频率
* 快速:一个对象从诞生到被回收所经历的时间
* 通常前3个是垃圾收集器比较关注的



# 垃圾收集器选择



* 通常选择垃圾收集器标准为吞吐量优先还是响应时间优先
* 如果堆大小不是很大(比如 100M),选择串行收集器一般是效率最高的.参数: `-XX:+UseSerialGC` 
* 如果运行在单核的机器上,选择串行收集器依然是合适的,启用并行收集器没有任何收益.参数: `-XX:+UseSerialGC` 
* 如果应用是吞吐量优先的,并且对较长时间的停顿没有什么特别的要求,选择并行收集器是比较好的.参数: `-XX:+UseParallelGC` 
* 如果应用对响应时间要求较高,想要较少的停顿,甚至1秒的停顿都会引起大量的请求失败,那么选择G1, ZGC, CMS都可以.虽然这些收集器的GC停顿通常都比较短,但它需要一些额外的资源去处理这些工作,通常吞吐量会低一些.参数: `-XX:+UseConcMarkSweepGC` , `-XX:+UseG1GC` , `-XX:+UseZGC` 等
* 从上面这些出发点来看,平常的 Web 服务器,都是对响应性要求非常高的,选择性其实就集中在 CMS、G1、ZGC 上,而对于某些定时任务,使用并行收集器,是一个比较好的选择



# 内存模型



![](img/022.png)



* 每一个线程有一个工作内存和主存独立
* 工作内存存放主存中变量的值的拷贝
* 当数据从主内存复制到工作存储时,必须出现两个动作:
  * 由主内存执行的读(read)操作
  * 由工作内存执行的相应的load操作
* 当数据从工作内存拷贝到主内存时,也出现两个操作:
  * 由工作内存执行的存储(store)操作
  * 由主内存执行的相应的写(write)操作
* 每一个操作都是原子的,即执行期间不会被中断
* 对于普通变量,一个线程中更新的值,不能马上反应在其他变量中.如果需要在其他线程中立即可见,需要使用 volatile 关键字



## Volatile



![第19图片](img/023.png)



```java
public class VolatileStopThread extends Thread{
    private volatile boolean stop = false;
    public void stopMe(){
        stop=true;
    }

    public void run(){
        int i=0;
        while(!stop){
            i++;
        }
        System.out.println("Stop thread");
    }

    public static void main(String args[]) throws InterruptedException{
        VolatileStopThread t=new VolatileStopThread();
        t.start();
        Thread.sleep(1000);
        t.stopMe();
        Thread.sleep(1000);
    }
}
```

* 没有volatile,服务运行后无法停止
* 使用volatile之后,一个线程修改了变量,其他线程可以立即知道
* volatile 不能代替锁.一般认为volatile 比锁性能好,但不绝对
* 选择使用volatile的条件是:语义是否满足应用
* 保证可见性的方法
  * volatile
  * synchronized:unlock之前,写变量值回主存
  * final:一旦初始化完成,其他线程就可见



## 有序性



* –在本线程内,操作都是有序的
* 在线程外观察,操作都是无序的。（指令重排 或 主内存同步延时）



## 指令重排



* 指令重排的基本原则:
  * 程序顺序原则: 一个线程内保证语义的串行性
  * volatile规则: volatile变量的写,先发生于读
  * 锁规则: 解锁(unlock)必然发生在随后的加锁(lock)前
  * 传递性: A先于B,B先于C 那么A必然先于C
  * 线程的start方法先于它的每一个动作
  * 线程的所有操作先于线程的终结(Thread.join())
  * 线程的中断(interrupt())于被中断线程的代码
  * 对象的构造函数执行结束先于finalize()方法

```java
class OrderExample {
    int a = 0;
    boolean flag = false;

    public void writer() {
        a = 1;
        flag = true;
    }

    public void reader() {
        if (flag) {
            int i =  a +1;
        }
    }
}
```

* 线程内串行语义
  * 写后读 a = 1;b = a; 写一个变量之后,再读这个位置
  * 写后写 a = 1;a = 2; 写一个变量之后,再写这个变量
  * 读后写 a = b;b = 1; 读一个变量之后,再写这个变量
  * 以上语句不可重排
  * 编译器不考虑多线程间的语义
  * 可重排:a=1;b=2;
* 会破坏线程间的有序性
  * 线程A首先执行writer(),线程B线程接着执行reader()
  * 线程B在int i=a+1 是不一定能看到a已经被赋值为1.因为在writer中,两句话顺序可能打乱
  * 线程A:flag=true;a=1
  * 线程B:flag=true(此时a=0)
* 保证有序性的方法

```java
class OrderExample {
    int a = 0;
    boolean flag = false;
    public synchronized void writer() {
        a = 1;
        flag = true;
    }
    public synchronized void reader() {
        if (flag) {
            int i =  a +1;
        }
    }
}
```

* 同步后,即使做了writer重排,因为互斥的缘故,reader 线程看writer线程也是顺序执行的
* 线程A:flag=true;a=1
* 线程B:flag=true(此时a=1)



## 解释运行



* 解释执行以解释方式运行字节码
* 解释执行的意思是:读一句执行一句



## 编译运行(JIT)



* 将字节码编译成机器码
* 直接执行机器码
* 运行时编译
* 编译后性能有数量级的提升
* 字节码执行性能较差,所以可以对于热点代码编译成机器码再执行,在运行时的编译,叫做JIT Just-In-Time
* JIT的基本思路是将热点代码,就是执行比较频繁的代码,编译成机器码



# Tools



在JDK安装目录bin下面有很多工具类,他们依赖lib下面的tools.jar



## Jps



* 显示当前服务器上的Java进程PID和运行的程序名称
* -l:显示程序主函数的完成路径
* -m:显示Java程序启动时的入参,类似main方法运行时输入的args
* -v:显示程序启动时设置的JVM参数
* -q:指定jps只输出进程ID,不输出类的短名称



## Jstat



* 运行状态信息,如类装载,内存,垃圾收集,jit编译的信息,详见Oracle官网[jstat]([jstat (oracle.com)](https://docs.oracle.com/javase/8/docs/technotes/tools/unix/jstat.html))

```
S0     S1     E      O      M     CCS    YGC   YGCT    FGC    FGCT     GCT
0.00  98.21   8.39  54.85  93.10  82.54  13    0.261     1    0.145    0.406
```

* jstat -gcutil pid:显示指定程序的gc信息,pid从jps获取
  * S0:新生代的S0使用率
  * S1:新生代S1使用率
  * E:新生代eden使用率
  * O:老年代使用率
  * M:元空间使用率,类似于JDK8以前的永久代
  * CCS:压缩类的空间
  * YGC:新生代垃圾收集的次数
  * YGCT:新生代垃圾收集总共耗费的时间
  * FGC:Full GC次数
  * FGCT:Full GC总共消耗的时间
  * GCT:垃圾回收使用的总时间
* jstat -gcutil pid interval count:监控间隔时间指定次数的gc.count为监控次数,interval为间隔时间,单位毫秒



## Jinfo



* 实时查看和调整虚拟机的各项参数,详见官网[jinfo]([jinfo (oracle.com)](https://docs.oracle.com/javase/8/docs/technotes/tools/unix/jinfo.html))
* jinfo -flag  虚拟机参数 pid:查看某个进程的虚拟机设置参数
* jinfo -flag [+|-] 虚拟机参数 pid:给指定进程加上(+)或禁用(-)某个虚拟机参数
* jinfo -flag 虚拟机参数key=虚拟机参数value pid:给指定进程的虚拟机参数设置值



## Jmap



* 生成Java应用程序的堆快照和对象的统计信息
* jmap -heap pid:查看堆信息
* jmap -histo pid >c:\s.txt:查看内存中对象数量及大小,并将统计信息输出到指定目录指定文件
* jmap -dump:format=b,file=c:\heap.hprof pid:将内存使用情况输出,使用jhat查看



## Jhat



* 查看jmap输出的dump文件,需要单独占用一个端口,可以在页面访问
* jhat -port 12345 dump文件:分析dump文件,网页可通过ip:12345访问



## Jstack



* 打印线程dump
* -l:打印锁信息
* -m:打印java和native的帧信息
* -F:强制dump,当jstack没有响应时使用



## Jconsole



* 可视化查看当前虚拟机中基本的信息,例如CPI,堆,栈,类,线程信息
* 在windows上直接输入该命令会打开一个可视化界面,选择需要监控的程序即可
* 在可视化界面中列出了内存,线程(可以检测死锁),类,JVM的相关信息

![](img/024.png)



## Visualvm



 *          Java虚拟机性能分析工具,jconsole的更强版本,可视化工具,能看到JVM当前几乎所有运行程序的详细信息
 *          需要VisualVM[官网]([VisualVM: Plugins Centers](https://visualvm.github.io/index.html))上下载合适版本
 *          下载完成解压,进入bin,点击visualvm.exe打开,可实时检测Java程序的运行
 *          可以选择安装其他插件,从官网的[插件]([VisualVM: Plugins Centers](https://visualvm.github.io/pluginscenters.html))地址.从VisualVM的工具->插件中安装



## Javap



* 查看class文件的字节码信息
* javap -c test.class:编译test.class文件
* javap -verbose test.class:编译test.class,输出更详细的指令集文件



## MAT



* Memory Analyzer Tool:基于Eclipse的[软件](http://www.eclipse.org/mat/),可以直接安装在Eclipse,也可以单独使用
* 需要先使用Visualvm导出内存相关的dump文件,之后导入MAT中进行分析



## JProfiler



* GC Roots溯源



# JVM参数



* 所有参数示例可参见dream-study-java-common项目的com.wy.jvm包

* -Dname=value:设置启动参数,main方法中可读取

* `java -XX:+PrintFlagsFinal -version|grep gc`: 查看所有与GC相关的参数

* -verbose:gc:可以打印GC的简要信息

  ```java
  [GC 4790K->374K(15872K), 0.0001606 secs]
  [GC 4790K->374K(15872K), 0.0001474 secs]
  [GC 4790K->374K(15872K), 0.0001563 secs]
  [GC 4790K->374K(15872K), 0.0001682 secs]
  ```

* -XX:+PrintGC:当虚拟机启动后,只要遇到GC就会打印日志

* -XX:+PrintGCDetails:可以查看详细信息,包括各个区的情况

  ```java
  // DefNew:新生代默认使用的垃圾收集器
  // Tenured:老年代
  // ParNew:新生代使用的并行垃圾回收器,Parallel New Generation
  // PSYoungGen:新生代使用的并行垃圾回收器,Parallel Scavenge
  // ParOldGen:老年代使用的并行垃圾回收器,Parallel Old Generation
  // eden为新生代伊甸区,from是s0,to是s1,tenured是老年代,compacting是JDK1.8之前的永久代,JDK1.8称为元空间Metaspace
  Heap
   def new generation  total 13824K, used 11223K [0x27e80000,0x28d80000,0x28d80000)
    eden space 12288K, 91% used [0x27e80000, 0x28975f20, 0x28a80000)
    from space 1536K,  0% used [0x28a80000, 0x28a80000, 0x28c00000)
    to   space 1536K,  0% used [0x28c00000, 0x28c00000, 0x28d80000)
   tenured generation  total 5120K, used 0K [0x28d80000, 0x29280000, 0x34680000)
     the space 5120K,  0% used [0x28d80000, 0x28d80000, 0x28d80200, 0x29280000)
   compacting perm gen total 12288K, used 142K [0x34680000, 0x35280000, 0x38680000)
     the space 12288K, 1% used [0x34680000, 0x346a3a90, 0x346a3c00, 0x35280000)
      ro space 10240K, 44% used [0x38680000, 0x38af73f0, 0x38af7400, 0x39080000)
      rw space 12288K, 52% used [0x39080000, 0x396cdd28, 0x396cde00, 0x39c80000)
  ```

* -XX:+PrintGCTimeStamps:打印CG发生的时间戳

* -XX:+PrintHeapAtGC:每次一次GC后,都打印堆信息

* -XX:+TraceClassLoading:监控类的加载

  ```java
  [Loaded java.lang.Object from shared objects file]
  [Loaded java.io.Serializable from shared objects file]
  [Loaded java.lang.Comparable from shared objects file]
  [Loaded java.lang.CharSequence from shared objects file]
  [Loaded java.lang.String from shared objects file]
  [Loaded java.lang.reflect.GenericDeclaration from shared objects file]
  [Loaded java.lang.reflect.Type from shared objects file]
  ```

* -XX:+PrintClassHistogram:按下Ctrl+Break后,打印类的信息

  ```java
   // 分别显示:序号,实例数量,总大小,类型
   num     #instances         #bytes  class name
  ----------------------------------------------
     1:        890617      470266000  [B
     2:        890643       21375432  java.util.HashMap$Node
     3:        890608       14249728  java.lang.Long
     4:            13        8389712  [Ljava.util.HashMap$Node;
     5:          2062         371680  [C
     6:           463          41904  java.lang.Class
  ```

* -Xloggc:filePath:指定GC日志的位置,以文件形式输出

* -XX:+PrintFlagsFinal:运行java命令时打印参数.=表示默认值,:=表示被修改的值

* -XX:+PrintCommandLineFlags:显示当前JVM使用的垃圾回收器以及初始堆配置

  ```shell
  java -XX:+PrintCommandLineFlags -version
  
  -XX:InitialHeapSize=397443008 -XX:MaxHeapSize=6359088128 -XX:+PrintCommandLineFlags -XX:+UseCompressedClassPointers -XX:+UseCompressedOops -XX:-UseLargePagesIndividualAllocation -XX:+UseParallelGC
  java version "1.8.0_144"
  Java(TM) SE Runtime Environment (build 1.8.0_144-b01)
  Java HotSpot(TM) 64-Bit Server VM (build 25.144-b01, mixed mode)
  ```

* -Xms:设置JVM堆的最小值,包括新生和老年代,等价于-XX:InitialHeapSize

* -Xmx:设置JVM堆的最大值,等价于-XX:MaxHeapSize.如-Xmx2048M

* -Xmn:设置新生代大小,相当于同时设置NewSize==MaxNewSize,一般会设置为整个堆空间的1/3或1/4

* -XX:NewRatio=n:设置新生代和老年代的比值,如为3,表示年轻代:老年代为1:3.默认为2

* -XX:SurvivorRatio=n:设置新生代中eden和from/to空间比例,默认8,即eden:form:to=8:1:1.但是实际上如果不设置,比例是6:2:2,只有显示的设置该参数时才会是准确的

* -Xss:指定线程的最大栈空间大小,通常只有几百k

* -XX:MetaspaceSize:初始元空间大小

* -XX:MaxMetaspaceSize:最大元空间大小

* -XX:NewSize=n:设置新生代初始大小

* -XX:MaxNewSize=n:设置新生代最大大小,JDK8不能小于1536K

* -XX:PermSize:设置老年代的初始大小,默认是64M

* -XX:MaxPermSize:设置老年代最大值

* -XX:PretenureSizeThreshold:指定占用内存多少的对象直接进入老年代.由系统计算得出,无默认值

* -XX:MaxTenuringThreshold:默认15,只能设置0-15.指经多少次垃圾回收,对象实例从新生代进入老年代.在JDK8中并不会严格的按照该次数进行回收,又是即使没有达到指定次数仍然会进入老年代

* -XX:+HandlePromotionFailure:空间分配担保.+表示开启,-表示禁用

* -XX:+UseSerialGC:配置年轻代为串行回收器

* -XX:+UseParNewGC:在新生代使用并行收集器

* -XX:+UseParallelGC:设置年轻代为并行收集器(Parallel Scavenge)

* -XX:+UseParalledlOldGC:设置老年代并行收集器(Parallel Old)

* -XX:+UseConcMarkSweepGC:新生代使用并行收集器(ParNew),老年代使用CMS+串行收集器(Serial Old)

* -XX:+UseG1GC: 使用G1收集器

* -XX:ParallelGCThreads:设置用于垃圾回收的线程数

* -XX:ParallelCMSThreads:设定CMS的线程数量

* -XX:CMSInitiatingOccupancyFraction:CMS收集器在老年代空间被使用多少后触发

* -XX:+UseCMSCompactAtFullCollection:CMS收集器在完成垃圾收集后是否要进行一次内存碎片整理

* -XX:CMSFullGCsBeforeCompaction:设定进行多少次CMS垃圾回收后,进行一次内存压缩

* -XX:+CMSClassUnloadingEnabled:允许对类元数据进行回收

* -XX:CMSInitiatingPermOccupancyFraction:当永久区占用率达到这一百分比时,启动CMS回收

* -XX:UseCMSInitiatingOccupancyOnly:表示只在到达阀值的时候,才进行CMS回收

* -XX:+HeapDumpOnOutOfMemoryError:使用该参数可以在OOM时导出整个堆信息,文件将导出在程序目录下

* -XX:HeapDumpPath=filePath:设置OOM时导出的信息存放地址,最好是一个目录,不是一个文件

* -XX:OnOutOfMemoryError=filePath:在OOM时,执行一个脚本,如发送邮件

* -XX:MaxGCPauseMillis:设置最大垃圾收集停顿时间,可以把虚拟机在GC停顿的时间控制在指定范围内.如果希望减少GC停顿时间,可以将MaxGCPauseMillis设置的很小,但是会导致GC频繁,从而增加了GC的总时间降低了吞吐量,所以需要根据实际情况设置

* -XX:GCTimeRatio:设置吞吐量大小,它是一个0到100之间的整数,默认情况下是99,系统将花费不超过1/(1+n)的时间用于垃圾回收,也就是1/(1+99)=1%的时间.该参数和-XX:MaxGCPauseMillis是矛盾的,因为停顿时间和吞吐量不可能同时调优

* -XX:UseAdaptiveSizePolicy:自适应模式,在这种情况下,新生代的大小,eden,from/to的比例,以及晋升老年代的对象年龄参数会被自动调整,已达到在堆大小,吞吐量和停顿时间之间的平衡.该参数只适用于Parallel Scavenge GC

* -Xint:在解释模式下会强制JVM执行所有字节码,会降低运行速度10倍以上

* -Xcomp:和Xint相反,JVM在第一次使用时会把所有字节码编译成本地代码,带来最大程度的优化

* -Xmixed:混合模式,由JVM决定使用解释模式或编译模式,JVM的默认模式



## 日志输出



* `-Xloggc:/tmp/logs/project/gc-%t.log -XX:+UseGCLogFileRotation -XX:NumberOfGCLogFiles=5 -XX:GCLogFileSize=20M -XX:+PrintGCDetails -XX:+PrintGCDateStamps -XX:+PrintGCCause`: 将GC日志输出到指定目录,只输出5个文件,每个文件最大20M,若超出5个,循环覆盖前面的日志



# GC输出



```java
public static void main(String[] args) {
    byte[] b = null;
    for (int i = 0; i < 20; i++) {
        b = new byte[1 * 1024 * 1024];
    }
}
```



## Parallel Scavenge



```java
// 设置JVM启动参数:-verbose:gc -XX:+PrintGCDetails -XX:+UseSerialGC -Xmx10m -Xms10m -XX:NewSize=512k
[GC (Allocation Failure) [PSYoungGen: 1976K->496K(2560K)] 8120K->6844K(9728K), 0.0005997 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) --[PSYoungGen: 1520K->1520K(2560K)] 7868K->7916K(9728K), 0.0011288 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[Full GC (Ergonomics) [PSYoungGen: 1520K->0K(2560K)] [ParOldGen: 6396K->1644K(7168K)] 7916K->1644K(9728K), [Metaspace: 2657K->2657K(1056768K)], 0.0038580 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [PSYoungGen: 1024K->0K(2560K)] 7788K->6764K(9728K), 0.0002767 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) --[PSYoungGen: 1024K->1024K(2560K)] 7788K->7788K(9728K), 0.0002484 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[Full GC (Ergonomics) [PSYoungGen: 1024K->0K(2560K)] [ParOldGen: 6764K->1643K(7168K)] 7788K->1643K(9728K), [Metaspace: 2658K->2658K(1056768K)], 0.0048177 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
Heap
 PSYoungGen      total 2560K, used 1044K [0x00000000ffd00000, 0x0000000100000000, 0x0000000100000000)
  eden space 2048K, 51% used [0x00000000ffd00000,0x00000000ffe05370,0x00000000fff00000)
  from space 512K, 0% used [0x00000000fff80000,0x00000000fff80000,0x0000000100000000)
  to   space 512K, 0% used [0x00000000fff00000,0x00000000fff00000,0x00000000fff80000)
 ParOldGen       total 7168K, used 5739K [0x00000000ff600000, 0x00000000ffd00000, 0x00000000ffd00000)
  object space 7168K, 80% used [0x00000000ff600000,0x00000000ffb9aef8,0x00000000ffd00000)
 Metaspace       used 2664K, capacity 4486K, committed 4864K, reserved 1056768K
  class space    used 286K, capacity 386K, committed 512K, reserved 1048576K
```



* JDK8和之前的策略不一样,GC信息也不同
* `GC (Allocation Failure)`:表明进行了一次新生代垃圾回收,且不需要STW
  * 前面没有Full修饰,表明这是一次Minor GC(YGC),有Full表示全收集
  * `Allocation Failure`表明本次引起GC的原因是年轻代中没有足够的空间能够存储新的数据
* `[PSYoungGen: 1976K->496K(2560K)] 8120K->6844K(9728K), 0.0005997 secs]`:
  * `PSYoungGen`:发生垃圾回收的回收器名称简写
    * DefNew:Def New Generation,Serial GC
    * Tenured:Serial Old GC
    * ParNew:ParNew
    * PSYoungGen:Parallel Scavenge
    * ParOldGen:Parallel Old
    * garbage-first heap:G1在新生代的名称
  * `1976K->496K(2560K)`:GC前该区域已使用容量->GC后该区域已使用容量(该内存区域总容量)
  * `8120K->6844K(9728K)`:GC前Java堆已使用容量->GC后Java堆已使用容量(Java堆总容量)
  * `0.0005997 secs`:该内存区域GC所占用的时间
* `[ParOldGen:  6396K->1644K(7168K)] 7916K->1644K(9728K)`:
  * `ParOldGen`:老年代发生垃圾回收
* `[Metaspace: 2657K->2657K(1056768K)], 0.0038580 secs]`:
  * `Metaspace`:元空间发生垃圾回收.JDK1.8之前为compacting perm gen
* `Heap`: 表示堆信息,所有used后面的0x开头一次是内存的起始地址,使用空间结束地址,整体空间结束地址
* `class space`: 元空间中专门给class用来存储的空间
* `[Times: user=0.00 sys=0.00, real=0.00 secs]`:分别表示用户态耗时,内核态耗时和总耗时



## Serial GC



```java
// 设置JVM启动参数:-verbose:gc -XX:+PrintGCDetails -XX:+UseSerialGC -Xmx20m -Xms20m -Xmn1m
[GC (Allocation Failure) [DefNew: 896K->63K(960K), 0.0009520 secs] 896K->628K(20416K), 0.0009838 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[GC (Allocation Failure) [DefNew: 262K->63K(960K), 0.0012891 secs][Tenured: 19079K->1734K(19456K), 0.0012453 secs] 19259K->1734K(20416K), [Metaspace: 2661K->2661K(1056768K)], 0.0025666 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
Heap
 def new generation   total 960K, used 18K [0x00000000fec00000, 0x00000000fed00000, 0x00000000fed00000)
  eden space 896K,   2% used [0x00000000fec00000, 0x00000000fec04920, 0x00000000fece0000)
  from space 64K,   0% used [0x00000000fece0000, 0x00000000fece0000, 0x00000000fecf0000)
  to   space 64K,   0% used [0x00000000fecf0000, 0x00000000fecf0000, 0x00000000fed00000)
 tenured generation   total 19456K, used 3782K [0x00000000fed00000, 0x0000000100000000, 0x0000000100000000)
   the space 19456K,  19% used [0x00000000fed00000, 0x00000000ff0b1b90, 0x00000000ff0b1c00, 0x0000000100000000)
 Metaspace       used 2668K, capacity 4486K, committed 4864K, reserved 1056768K
  class space    used 286K, capacity 386K, committed 512K, reserved 1048576K
```
