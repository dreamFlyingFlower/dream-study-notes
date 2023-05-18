# Thread



# ThreadPoolExecutor



* ThreadPoolExecutor 使用int类型的ctl的高 3 位来表示线程池状态,低 29 位表示线程数量

| 状态名     | 高3位 | 接收新任务 | 处理阻塞任务队列 | 说明                                    |
| ---------- | ----- | ---------- | ---------------- | --------------------------------------- |
| RUNNING    | 111   | Y          | Y                |                                         |
| SHUTDOWN   | 000   | N          | Y                | 不会接收新任务,但会处理阻塞队列剩余任务 |
| STOP       | 001   | N          | N                | 会中断正在执行的任务,并抛弃阻塞队列任务 |
| TIDYING    | 010   | -          | -                | 任务全执行完毕,活动线程为 0 即将进入    |
| TERMINATED | 011   | -          | -                | 终结状态                                |

* 从数字上比较,TERMINATED > TIDYING > STOP > SHUTDOWN > RUNNING
* 这些信息存储在一个原子变量 ctl 中,目的是将线程池状态与线程个数合二为一,这样就可以用一次 cas 操作进行赋值

```java

private void advanceRunState(int targetState) {
    for (;;) {
        int c = ctl.get();
        if (runStateAtLeast(c, targetState) ||
            // c 为旧值,ctlOf 返回结果为新值
            ctl.compareAndSet(c, ctlOf(targetState, workerCountOf(c))))
            break;
    }
}

// rs 为高 3 位代表线程池状态, wc 为低 29 位代表线程个数,ctl 是合并它们
private static int ctlOf(int rs, int wc) { 
    return rs | wc;
}
```



## 线程池状态



![](img/025.png)



## 任务执行过程



```java
private final class Worker extends AbstractQueuedSynchronizer implements
    Runnable {
    final Thread thread;
    // 线程需要运行的第一个任务,可以是null,如果是null,则线程从队列获取任务
    Runnable firstTask;
    // 记录线程执行完成的任务数量,每个线程一个计数器
    volatile long completedTasks;

    Worker(Runnable firstTask) {
        setState(-1); // 线程处于阻塞状态,调用runWorker的时候中断
        // ...
    }
    // ...
}

final void runWorker(Worker w) {
    // ...
    // 中断Worker封装的线程
    w.unlock();
    boolean completedAbruptly = true;
    try {
        // 如果线程初始任务不是null,或者从队列获取的任务不是null,表示该线程应该执行任务
        while (task != null || (task = getTask()) != null) {
            w.lock();
            // 如果线程池停止了,确保线程被中断;如果线程池正在运行,确保线程不被中断
            if ((runStateAtLeast(ctl.get(), STOP) || (Thread.interrupted() && runStateAtLeast(ctl.get(), STOP))) && !wt.isInterrupted())
                // 获取到任务后,再次检查线程池状态,如果发现线程池已经停止,则给自己发中断信号
                wt.interrupt();
            try {
                try {
                    // 执行任务
                    task.run();
                } catch (Throwable ex) {
                    afterExecute(task, ex);
                    throw ex;
                }
            } finally {
                task = null;
                // 线程已完成的任务数加1
                w.completedTasks++;
            }
        }
        // 判断线程是否是正常退出
        completedAbruptly = false;
    } finally {
        // Worker退出
        processWorkerExit(w, completedAbruptly);
    }
}
```



### shutdown()调用情况



* 当调用shutdown()的时候,所有线程都处于空闲状态:这意味着任务队列一定是空的.此时,所有线程都会阻塞在 getTask().然后,所有线程都会收到interruptIdleWorkers()发来的中断信号,getTask()返回null,所有Worker都会退出while循环,之后执行processWorkerExit
* 当调用shutdown()时,所有线程都处于忙碌状态:此时,队列可能是空的,也可能是非空的.interruptIdleWorkers()内部的tryLock调用失败,什么都不会做,所有线程会继续执行自己当前的任务.之后所有线程会执行完队列中的任务,直到队列为空,getTask()才会返回null.之后,就和场景1一样了
* 当调用shutdown()时,部分线程忙碌,部分线程空闲:有部分线程空闲,说明队列一定是空的,这些线程肯定阻塞在 getTask().空闲的这些线程会和场景1一样处理,不空闲的线程会和场景2一样处理



### shutdownNow()调用情况



* 和 shutdown()类似,只是多了清空任务队列步骤.如果一个线程正在执行某个业务代码,即使向它发送中断信号,也没有用,只能等它把代码执行完成.因此,中断空闲线程和中断所有线程的区别并不是很大,除非线程当前刚好阻塞在某个地方
* 当一个Worker最终退出的时候,会执行清理工作



```java
private void processWorkerExit(Worker w, boolean completedAbruptly) {
    // 如果线程正常退出,不会执行if的语句,这里一般是非正常退出,需要将worker数量减一
    // ...
    try {
        completedTaskCount += w.completedTasks;
        // 将自己的worker从集合移除
        workers.remove(w);
    } finally {
        mainLock.unlock();
    }
    // 每个线程在结束的时候都会调用该方法,看是否可以停止线程池
    tryTerminate();
    int c = ctl.get();
    // 如果在线程退出前,发现线程池还没有关闭
    if (runStateLessThan(c, STOP)) {
        if (!completedAbruptly) {
            int min = allowCoreThreadTimeOut ? 0 : corePoolSize;
            // 如果线程池中没有其他线程了,并且任务队列非空
            if (min == 0 && ! workQueue.isEmpty())
                min = 1;
            // 如果工作线程数大于min,表示队列中的任务可以由其他线程执行,退出当前线程
            if (workerCountOf(c) >= min)
                return;
        }
        // 如果当前线程退出前发现线程池没有结束,任务队列不是空的,也没有其他线程来执行就再启动一个线程来处理
        addWorker(null, false);
    }
}
```



# ScheduledThreadPoolExecutor



* withFixedDelay和atFixedRate的区别就体现在setNextRunTime里面:
  * 如果是atFixedRate,period＞0,下一次开始执行时间等于上一次开始执行时间+period
  * 如果是withFixedDelay,period ＜ 0,下一次开始执行时间等于triggerTime(-p),为now+(-period),now即上一次执行的结束时间




# CompletableFuture



## 任务类型的适配



![](img/026.png)



# ForkJoinPool



* 相比于ThreadPoolExecutor,ForkJoinPool可以更好地实现计算的负载均衡,提高资源利用率
* ForkJoinPool可以把大的任务拆分成很多小任务,然后这些小任务被所有的线程执行,从而实现任务计算的负载均衡



## 核心数据结构



* 与ThreadPoolExector不同的是,除一个全局的任务队列之外,每个线程还有一个自己的局部队列



![](img/027.png)



## 工作窃取队列



* 在ForkJoinPool中的全局队列,并非使用BlockingQueue,而是基于一个普通的数组得以实现,这个队列又名工作窃取队列
* 所谓工作窃取算法,是指一个Worker线程在执行完毕自己队列中的任务之后,可以窃取其他线程队列中的任务来执行,从而实现负载均衡,以防有的线程很空闲,有的线程很忙



![](img/028.png)



* Worker线程自己,在队列头部,通过对top指针执行加,减操作,实现入队或出队,这是单线程的
* 其他Worker线程,在队列尾部,通过对base进行累加,实现出队操作,也就是窃取,这是多线程的,需要通过CAS操作
* 这个队列同样被称为`dynamic-cyclic-array`: 
  * 整个队列是环形的,也就是一个数组实现的RingBuffer.并且base会一直累加,不会减小;top会累加,减小.最后,base、top的值都会大于整个数组的长度,只是计算数组下标的时候,会取`top&(queue.length-1)`,`base&(queue.length-1)`.
  * 当top-base==queue.length-1 时,队列为满,此时需要扩容;当top==base时,队列为空,Worker线程即将进入阻塞状态

* 在base一端,是多线程访问的,但它们只会使base变大,也就是使队列中的元素变少,所以队列为满,一定发生在top一端.对top进行累加的时候,这一端却是单线程的,队列的扩容恰好利用了这个单线程的特性,即在扩容过程中,不可能有其他线程对top 进行修改,只有线程对base进行修改,这样就保证了动态扩容的安全性
* 扩容之后,数组长度变成之前的2倍,但top、base的值是不变的,通过top,base对新的数组长度取模,仍然可以定位到元素在新数组中的位置




## 状态控制



### ctl



```java
public class ForkJoinPool extends AbstractExecutorService {
    // 线程池状态变量
    volatile long ctl;
    private static final long SP_MASK    = 0xffffffffL;
    private static final long UC_MASK    = ~SP_MASK;
    private static final int  AC_SHIFT   = 48;
    private static final long AC_UNIT    = 0x0001L << AC_SHIFT;
    private static final long AC_MASK    = 0xffffL << AC_SHIFT;
    private static final int  TC_SHIFT   = 32;
    private static final long TC_UNIT    = 0x0001L << TC_SHIFT;
    private static final long TC_MASK    = 0xffffL << TC_SHIFT;
    private static final long ADD_WORKER = 0x0001L << (TC_SHIFT + 15);

    private static final int  RSLOCK     = 1;
    private static final int  RSIGNAL    = 1 << 1;
    private static final int  STARTED    = 1 << 2;
    private static final int  STOP       = 1 << 29;
    private static final int  TERMINATED = 1 << 30;
    private static final int  SHUTDOWN   = 1 << 31;
    // ...
}
```



![](img/029.png)



* ctl变量的64个比特位被分成五部分: 
  * AC: 最高的16个比特位,表示Active线程数-parallelism,parallelism是上面的构造方法传进去的参数
  * TC: 次高的16个比特位,表示Total线程数-parallelism
  * ST: 1个比特位,如果是1,表示整个ForkJoinPool正在关闭
  * EC: 15个比特位,表示阻塞栈的栈顶线程的wait count
  * ID: 16个比特位,表示阻塞栈的栈顶线程对应的id



### TreiberStack



* 在ForkJoinPool中,没有使用阻塞队列,而是使用了阻塞栈把所有空闲的Worker线程放在一个栈里面,这个栈同样通过链表来实现,名为Treiber Stack
* 下图为所有阻塞的Worker线程组成的Treiber Stack



![](img/030.png)



* 首先,WorkQueue有一个id变量,记录了自己在`WorkQueue[]`的下标,id就相当于每个WorkQueue或ForkJoinWorkerThread对象的地址
* 其次,ForkJoinWorkerThread还有一个stackPred变量,记录了前一个阻塞线程的id,这个stackPred就相当于链表的next指针,把所有的阻塞线程串联在一起,组成一个Treiber Stack
* 最后,ctl变量的最低16位,记录了栈的栈顶线程的id;中间的15位,记录了栈顶线程被阻塞的次数,也称为wait count



### ForkJoinWorkerThread



* ForkJoinPool中的线程状态: 
  * 空闲状态(放在Treiber Stack里面)
  * 活跃状态(正在执行某个ForkJoinTask,未阻塞)
  * 阻塞状态(正在执行某个ForkJoinTask,但阻塞了,于是调用join,等待另外一个任务的结果返回)
* ctl变量很好地反映出了三种状态: 高32位: u=(int) (ctl \>\>\> 32),然后u又拆分成tc、ac 两个16位; 低32位: c=(int) ctl
  * c＞0,说明Treiber Stack不为空,有空闲线程；c=0,说明没有空闲线程
  * ac＞0,说明有活跃线程;ac＜=0,说明没有空闲线程,并且还未超出parallelism
  * tc＞0,说明总线程数 ＞parallelism
* 在通知工作线程的时候,需要判断ctl的状态,如果没有闲置的线程,则开启新线程



## Worker线程的阻塞唤醒



* ForkerJoinPool 没有使用 BlockingQueue,也就不利用其阻塞/唤醒机制,而是利用了park/unpark原语,并自行实现了Treiber Stack



### 阻塞入栈



* 当一个线程窃取不到任何任务,也就是处于空闲状态时就会阻塞入栈



```java
final void runWorker(WorkQueue w) {
    // ...
    for (;;) {
        int phase;
        // 扫描是否有需要执行的一个或多个顶级任务
        // 其中包含了窃取的任务执行,以及线程局部队列中任务的执行
        // 如果发现了就执行,返回true
        // 如果获取不到任务,就需要将该线程入队列,阻塞
        if (scan(w, r)) {
            r ^= r << 13; r ^= r >>> 17; r ^= r << 5;
        }
        // 如果是已经入队列阻塞的,因为phase大于0表示加锁
        else if ((phase = w.phase) >= 0) {
            // ...
        } else {
            // ...
            // 如果ForkJoinPool停止,则break,跳出循环
            if (md < 0){

            }
            // ....
            // phase为1,表示加锁,phase为负数表示入队列
            else if (w.phase < 0)
                // 如果phase小于0,表示阻塞,排队中
                LockSupport.park(this);
            w.source = 0;
        }
    }
}
```



```java
// 从一个队列中扫描一个或多个顶级任务,如果有,就执行;对于非空队列,执行任务,返回true
private boolean scan(WorkQueue w, int r) {
    WorkQueue[] ws; int n;
    // 如果workQueues不是null,并且workQueue的长度大于0,并且w非空,w是线程的workQueue
    if ((ws = workQueues) != null && (n = ws.length) > 0 && w != null) {
        // m是ws长度减一,获取ws顶部workQueue
        for (int m = n - 1, j = r & m;;) {
            WorkQueue q; int b;
            // 随机获取workQueue,如果该workQueue的顶指针和底指针不相等,表示有需要执行的任务
            if ((q = ws[j]) != null && q.top != (b = q.base)) {
                int qid = q.id;
                ForkJoinTask<?>[] a; int cap, k; ForkJoinTask<?> t;
                if ((a = q.array) != null && (cap = a.length) > 0) {
                    // 获取队列顶部任务
                    t = (ForkJoinTask<?>)QA.getAcquire(a, k = (cap - 1) & b);
                    // 如果q的base值没有被别的线程修改过,t不是null,并且将t从数组中移除成功,即可在当前工作线程执行该任务
                    if (q.base == b++ && t != null &&
                        QA.compareAndSet(a, k, t, null)) {
                        // base+1
                        q.base = b;
                        w.source = qid;
                        // 如果还有任务需要执行,通知其他闲置的线程执行
                        if (q.top - b > 0)
                            signalWork();
                        // 让workQueue中的工作线程来执行不管是窃取来的,还是本地的任务,还是从queue中获取的其他任务
                        // 公平起见,添加一个随机的边界;剩下的让别的线程来执行
                        w.topLevelExec(t, q, r & ((n << TOP_BOUND_SHIFT) - 1));
                    }
                }
                return true;
            }
            else if (--n > 0)
                j = (j + 1) & m;
            else
                break;
        }
    }
    return false;
}
```



### 唤醒出栈



* 在新的任务到来之后,空闲的线程被唤醒,其核心逻辑在signalWork()里



### 外部提交任务

 

```java
final void externalPush(ForkJoinTask<?> task) {
    // ...
    for (;;) {
        WorkQueue q;
        int md = mode, n;
        WorkQueue[] ws = workQueues;
        // 如果ForkJoinPool关闭,或者任务队列是null,或者ws的长度小于等于0,拒收任务
        if ((md & SHUTDOWN) != 0 || ws == null || (n = ws.length) <= 0)
            throw new RejectedExecutionException();
        // 如果随机数计算的workQueues索引处的元素为null,则添加队列
        // 即提交任务的时候,是随机向workQueue中添加workQueue,负载均衡的考虑
        else if ((q = ws[(n - 1) & r & SQMASK]) == null) {
            // 计算新workQueue对象的id值
            int qid = (r | QUIET) & ~(FIFO | OWNED);
            Object lock = workerNamePrefix;
            ForkJoinTask<?>[] qa =
                new ForkJoinTask<?>[INITIAL_QUEUE_CAPACITY];
            q = new WorkQueue(this, null);
            // 将任务数组赋值给workQueue
            q.array = qa;
            q.id = qid;
            // 由于是通过客户端线程添加的workQueue,没有前置workQueue;内部提交任务有源workQueue,表示子任务
            q.source = QUIET;
            if (lock != null) {
                synchronized (lock) {
                    WorkQueue[] vs; int i, vn;
                    // 如果workQueues数组不是null,其中有元素,并且qid对应的workQueues中的元素为null,则赋值
                    // 因为有可能其他线程将qid对应的workQueues处的元素设置了,所以需要加锁,并判断元素是否为null
                    if ((vs = workQueues) != null && (vn = vs.length) > 0 &&
                        vs[i = qid & (vn - 1) & SQMASK] == null)
                        vs[i] = q;
                }
            }
        }
        else if (!q.tryLockPhase()) // move if busy
            r = ThreadLocalRandom.advanceProbe(r);
        else {
            // 如果任务添加成功,通知线程池调度,执行
            if (q.lockedPush(task))
                signalWork();
            return;
        }
    }
}
```



* 外部多个线程会调用该方法,所以要加锁,入队列和扩容的逻辑和线程内部的队列基本相同.最后,调用signalWork(),通知一个空闲线程来取



## fork/join



* 线程在执行当前ForkJoinTask的时候,产生了left、right 两个子Task:fork是指把这两个子Task放入队列里面;join则是要等待2个子Task完成.而子Task在执行过程中,会再次产生两个子Task.如此层层嵌套,类似于递归调用,直到最底层的Task计算完成,再一级级返回



### join的嵌套



#### 层层嵌套阻塞原理



![](img/031.png)



* 线程1在执行 ForkJoinTask1,在执行过程中调用了 forkJoinTask2.join(),所以要等ForkJoinTask2完成,线程1才能返回
* 线程2在执行ForkJoinTask2,但由于调用了forkJoinTask3.join(),只有等ForkJoinTask3完成后,线程2才能返回
* 线程3在执行ForkJoinTask3
* 结果是: 线程3首先执行完,然后线程2才能执行完,最后线程1再执行完。所有的任务其实组成一 个有向无环图DAG。如果线程3调用了forkJoinTask1.join(),那么会形成环,造成死锁
* 那么,这种层次依赖、层次通知的 DAG,在 ForkJoinTask 内部是如何实现的呢?站在ForkJoinTask的角度来看,每个ForkJoinTask,都可能有多个线程在等待它完成,有1个线程在执行它。 所以每个ForkJoinTask就是一个同步对象,线程在调用join()的时候,阻塞在这个同步对象上面,执行完 成之后,再通过这个同步对象通知所有等待的线程
* 利用synchronized关键字和Java原生的wait()/notify()机制,实现了线程的等待-唤醒机制。调用join()的这些线程,内部其实是调用ForkJoinTask这个对象的wait()；执行该任务的Worker线程,在任务 执行完毕之后,顺便调用notifyAll()



![](img/032.png)



#### ForkJoinTask状态解析



* 要实现fork()/join()的这种线程间的同步,对应的ForkJoinTask一定是有各种状态的,这个状态变量 是实现fork/join的基础
* 初始时,status=0。共有五种状态,可以分为两大类: 
  * 未完成: status＞=0。
  * 已完成: status＜0
* 所以,通过判断是status＞=0,还是status＜0,就可知道任务是否完成,进而决定调用join()的线 程是否需要被阻塞



#### join的详细实现



* 下面看一下代码的详细实现

![](D:/software/Typora/media/image318.jpeg)

* getRawResult()是ForkJoinTask中的一个模板方法,分别被RecursiveAction和RecursiveTask实 现,前者没有返回值,所以返回null,后者返回一个类型为V的result变量
* ![](D:/software/Typora/media/image319.png)![](D:/software/Typora/media/image320.png)
* 阻塞主要发生在上面的doJoin()方法里面。在dojoin()里调用t.join()的线程会阻塞,然后等待任务t执 行完成,再唤醒该阻塞线程,doJoin()返回
* 当doJoin()返回的时候,就是该任务执行完成的时候,doJoin()的返回值就是任务的完成状态,也就是上面的几种状态
* 上面的返回值可读性比较差,变形之后: 
* 先看一下externalAwaitDone(),即外部线程的阻塞过程,相对简单。
* 内部Worker线程的阻塞,即上面的wt.pool.awaitJoin(w, this, 0L),相比外部线程的阻塞要做更多工作。它现不在ForkJoinTask里面,而是在ForkJoinWorkerThread里面。

1.  final int awaitJoin(WorkQueue w, ForkJoinTask\<?\> task, long deadline) {

2.  int s = 0;

3.  int seed = ThreadLocalRandom.nextSecondarySeed();

4.  if (w != null && task != null &&

5.  (!(task instanceof CountedCompleter) \|\|

6.  (s = w.helpCC((CountedCompleter\<?\>)task, 0, false)) \>= 0)) {

7.  // 尝试执行该任务

8.  w.tryRemoveAndExec(task);

9.  int src = w.source, id = w.id;

> 10 int r = (seed \>\>\> 16) \| 1, step = (seed & ~1) \| 2;

11. s = task.status;

12. while (s \>= 0) {

13. WorkQueue\[\] ws;

14. int n = (ws = workQueues) == null ? 0 : ws.length, m = n - 1;

15. while (n \> 0) {

16. WorkQueue q; int b;

17. if ((q = ws\[r & m\]) != null && q.source == id &&

18. q.top != (b = q.base)) {

19. ForkJoinTask\<?\>\[\] a; int cap, k;

20. int qid = q.id;

21. if ((a = q.array) != null && (cap = a.length) \> 0) {

22. ForkJoinTask\<?\> t = (ForkJoinTask\<?\>)

23. QA.getAcquire(a, k = (cap - 1) & b);

24. if (q.source == id && q.base == b++ &&

25. t != null && QA.compareAndSet(a, k, t, null)) {

26. q.base = b;

27. w.source = qid;

28. // 执行该任务

29. t.doExec();

30. w.source = src;

> 31 }
>
> 32 }
>
> 33 break;
>
> 34 }

35. else {

36. r += step;

> 37 --n;
>
> 38 }
>
> 39 }

40. // 如果任务的status \< 0,任务执行完成,则退出循环,返回s的值

41. if ((s = task.status) \< 0)

42. break;

43. else if (n == 0) { // empty scan

44. long ms, ns; int block;

45. if (deadline == 0L)

46. ms = 0L; // untimed

47. else if ((ns = deadline - System.nanoTime()) \<= 0L)

48. break; // timeout

49. else if ((ms = TimeUnit.NANOSECONDS.toMillis(ns)) \<= 0L)

50. ms = 1L; // avoid 0 for timed wait

51. if ((block = tryCompensate(w)) != 0) {

52. task.internalWait(ms);

* 上面的方法有个关键点: for里面是死循环,并且只有一个返回点,即只有在task.status＜0,任务 完成之后才可能返回。否则会不断自旋；若自旋之后还不行,就会调用task.internalWait(ms);阻塞task.internalWait(ms);的代码如下
* ![](D:/software/Typora/media/image321.png)



#### join的唤醒



* ![](image322.jpeg)
* 调用t.join()之后,线程会被阻塞。接下来看另外一个线程在任务**t**执行完毕后如何唤醒阻塞的线程
* ![](D:/software/Typora/media/image323.jpeg)
* 任务的执行发生在doExec()方法里面,任务执行完成后,调用一个setDone()通知所有等待的线程。 这里也做了两件事: 
  * 把status置为完成状态
  * 如果s != 0,即 s = SIGNAL,说明有线程正在等待这个任务执行完成。调用Java原生的notifyAll()通知所有线程。如果s = 0,说明没有线程等待这个任务,不需要通知



## ForkJoinPool的优雅关闭



* 同ThreadPoolExecutor一样,ForkJoinPool的关闭也不可能是“瞬时的”,而是需要一个平滑的过渡过程



### 工作线程的退出



* 对于一个Worker线程来说,它会在一个for循环里面不断轮询队列中的任务,如果有任务,则执 行,处在活跃状态；如果没有任务,则进入空闲等待状态
* 这个线程如何退出呢?

> 1 /\*\*
>
> 2 \* 工作线程的顶级循环,通过ForkJoinWorkerThread.run调用
>
> 3 \*/

4.  final void runWorker(WorkQueue w) {

5.  int r = (w.id ^ ThreadLocalRandom.nextSecondarySeed()) \| FIFO; // rng

6.  w.array = new ForkJoinTask\<?\>\[INITIAL_QUEUE_CAPACITY\]; // 初始化任务数组。

> 7 for (;;) {

8.  int phase;

9.  if (scan(w, r)) { // scan until apparently empty 10 r ^= r \<\< 13; r ^= r \>\>\> 17; r ^= r \<\< 5; // move (xorshift)

> 11 }

12. else if ((phase = w.phase) \>= 0) { // enqueue, then rescan

13. long np = (w.phase = (phase + SS_SEQ) \| UNSIGNALLED) & SP_MASK;

14. long c, nc;

15. do {

16. w.stackPred = (int)(c = ctl);

17. nc = ((c - RC_UNIT) & UC_MASK) \| np;

18. } while (!CTL.weakCompareAndSet(this, c, nc)); 19 }

&nbsp;

20. else { // already queued

21. int pred = w.stackPred;

22. Thread.interrupted(); // clear before park

23. w.source = DORMANT; // enable signal

24. long c = ctl;

25. int md = mode, rc = (md & SMASK) + (int)(c \>\> RC_SHIFT);

> (int) (c = ctl) \< 0,即低32位的最高位为1,说明线程池已经进入了关闭状态。但线程池进入关闭状态,不代表所有的线程都会立马关闭。



### shutdown()与shutdownNow()



* 二者的代码基本相同,都是调用tryTerminate(boolean, boolean)方法,其中一个传入的是false, 另一个传入的是true。tryTerminate意为试图关闭ForkJoinPool,并不保证一定可以关闭成功: 

9

> 10 }
>
> 11
>
> MODE.compareAndSet(this, md, md \| SHUTDOWN);

12. while (((md = mode) & STOP) == 0) { // try to initiate termination

13. if (!now) { // check if quiescent & empty

14. for (long oldSum = 0L;;) { // repeat until stable

15. boolean running = false;

16. long checkSum = ctl;

17. WorkQueue\[\] ws = workQueues;

18. if ((md & SMASK) + (int)(checkSum \>\> RC_SHIFT) \> 0)

19. // 还有正在运行的线程

20. running = true;

21. else if (ws != null) {

22. WorkQueue w;

23. for (int i = 0; i \< ws.length; ++i) {

24. if ((w = ws\[i\]) != null) {

25. int s = w.source, p = w.phase;

26. int d = w.id, b = w.base;

27. if (b != w.top \|\|

> 28 ((d & 1) == 1 && (s \>= 0 \|\| p \>= 0))) {

29. running = true;

30. // 还正在运行

31. break;

> 32 }
>
> 33 checkSum += (((long)s \<\< 48) + ((long)p \<\< 32) + 34 ((long)b \<\< 16) + (long)d);
>
> 35 }
>
> 36 }
>
> 37 }

38. if (((md = mode) & STOP) != 0)

39. break; // already triggered

40. else if (running)

41. return false;

42. else if (workQueues == ws && oldSum == (oldSum = checkSum))

43. break;

> 44 }
>
> 45 }

46. if ((md & STOP) == 0)

47. // 如果需要立即停止,同时md没有设置为STOP,则设置为STOP

48. MODE.compareAndSet(this, md, md \| STOP); 49 }

> 50

51. // 如果mode还没有设置为TERMINATED,则进行循环

52. while (((md = mode) & TERMINATED) == 0) { // help terminate others

53. for (long oldSum = 0L;;) { // repeat until stable

54. WorkQueue\[\] ws; WorkQueue w;

55. long checkSum = ctl;

56. if ((ws = workQueues) != null) {

57. for (int i = 0; i \< ws.length; ++i) {

58. if ((w = ws\[i\]) != null) {

59. ForkJoinWorkerThread wt = w.owner;

60. // 清空任务队列

61. w.cancelAll();

62. if (wt != null) {

63. try {

64. // 中断join或park的线程

65. wt.interrupt();

66. } catch (Throwable ignore) {



* shutdown()只拒绝新提交的任务；shutdownNow()会取消现有的全局队列和局部队列中的 任务,同时唤醒所有空闲的线程,让这些线程自动退出



# 多线程设计模式



## SingleThreadedExecution



* 指的是以一个线程执行,该模式用于设置限制,以确保同一时间只能让一个线程执行处理
* Single Threaded Execution有时也称为临界区(critical section)或临界域(critical region)。Single Threaded Execution名称侧重于执行处理的线程,临界区或临界域侧重于执行范围



### 示例程序

> 运行效果: 

![](D:/software/Typora/media/image324.png)

> 上述代码之所以递增异常,是因为showNumber方法是一个临界区,其中对数字加一,但又不能保 证原子性,在多线程执行的时候,就会出现问题。
>
> 线程安全的NumberResource类: 



### 总结



* SharedResource(共享资源)
* Single Threaded Execution模式中出现了一个发挥SharedResource(共享资源)作用的类。在示例程序中,由NumberResource类扮演SharedResource角色
* SharedResource角色是可以被多个线程访问的类,包含很多方法,但这些方法主要分为如下两 类: 
* safeMethod:  多 个 线 程 同 时 调 用 也 不 会 发 生 问 题 的 方 法 。 unsafeMethod: 多个线程同时访问会发生问题,因此必须加以保护的方法
* safeMethod,无需考虑
* 对于unsafeMethod,在被多个线程同时执行时,实例状态有可能发生分歧。这时就需要保护该方 法,使其不被多个线程同时访问
* Single Threaded Execution模式会保护unsafeMethod,使其同时只能由一个线程访问。java则是通过unsafeMethod声明为synchronized方法来进行保护
* 我们将只允许单个线程执行的程序范围称为临界区



### 类图



* ![](D:/software/Typora/media/image325.jpeg)



### 使用场景



* 多线程时:在单线程程序中使用synchronized关键字并不会破坏程序的安全性,但是调用synchronized方法要 比调用一般方法花费时间,稍微降低程序性能
* 多个线程访问时:当SharedResource角色的实例有可能被多个线程同时访问时,就需要使用Single Threaded Execution模式.
  * 即便是多线程程序,如果所有线程都是完全独立操作的,也无需使用Single Threaded Execution模式。这种状态称为线程互不干涉
  * 在某些处理多个线程的框架中,有时线程的独立性是由框架控制的。此时,框架的使用者就无需考 虑是否使用Single Threaded Execution模式
* 状态有可能变化时
  * 之所以需要使用Single Threaded Execution模式,是因为SharedResource角色的状态会发生变化
  * 如果在创建实例后,实例的状态再也不发生变化,就无需使用Single Threaded Execution模式
* 需要确保安全性时
  * 只有在需要确保安全性时,才需要使用Single Threaded Execution模式。Java的集合类大多数都是非线程安全的。这是为了在不需要考虑安全性的时候提高程序运行速度。用户在使用类时,需要考虑自己要用的类是否时线程安全的



### 死锁



* 使用Single Threaded Execution模式时,存在发生死锁的危险
* 在Single Threaded Execution模式中,满足下列条件时,会发生死锁: 
* 存在多个SharedResource角色线程在持有某个SharedResource角色锁的同时,还想获取其他SharedResource角色的锁 获取SharedResource角色的锁的顺序不固定(SharedResource角色是对称的)



### 临界区的大小和性能



* 一般情况下,Single Threaded Execution模式会降低程序性能: 
* 获取锁花费时间
  * 进入synchronized方法时,线程需要获取对象的锁,该处理会花费时间
  * 如果SharedResource角色的数量减少了,那么要获取的锁的数量也会相应地减少,从而就能够抑 制性能的下降了
* 线程冲突引起的等待
  * 当线程执行临界区内的处理时,其他想要进入临界区的线程会阻塞。这种状况称为线程冲突。发生 冲突时,程序的整体性能会随着线程等待时间的增加而下降



## Immutable模式



* Immutable就是不变的、不发生改变。Immutable模式中存在着确保实例状态不发生改变的类。在 访问这些实例时不需要执行耗时的互斥处理。如果能用好该模式,就可以提高程序性能



### 类图

![](D:/software/Typora/media/image327.png)



* 在Single Threaded Execution模式,将修改或引用实例状态的地方设置为临界区,该区只能由一个线程执行。对于本案例的User类,实例的状态绝对不会发生改变,即使多个线程同时对该实例执行处 理,实例也不会出错,因为实例的状态不变。如此也无需使用synchronized关键字来保护实例



### Immutable模式中的角色



1.  Immutable

> Immutable角色是一个类,该角色中的字段值不可修改,也不存在修改字段内容的方法。无需对
>
> Immutable角色应用Single Threaded Execution模式。无需使用synchronized关键字。就是本案例的User类。
>
> ![](D:/software/Typora/media/image328.png)



### 使用场景



* 创建实例后,状态不再发生改变
  * 必须是实例创建后,状态不再发生变化的。实例的状态由字段的值决定。即使字段是final的且不存 在setter,也有可能不是不可变的。因为字段引用的实例有可能发生变化。
* 实例是共享的,且被频繁访问时
  * Immutable模式的优点是不需要使用synchronized关键字进行保护。意味着在不失去安全性和生存 性的前提下提高性能。当实例被多个线程共享,且有可能被频繁访问时,Immutable模式优点明显。
* StringBuffer类表示字符串的可变类,String类表示字符串的不可变类。String实例表示的字符串不 可以修改,执行操作的方法都不是synchronized修饰的,引用速度更快。
* 如果需要频繁修改字符串内容,则使用StringBuffer；如果不需要修改字符串内容,只是引用内 容,则使用String
* **JDK中的不可变模式**java.lang.String java.math.BigInteger java.math.Decimal java.util.regex.Pattern java.lang.Boolean,java.lang.Byte java.lang.Character java.lang.Double java.lang.Float java.lang.Integer java.lang.Long java.lang.Short java.lang.Void



## Guarded Suspension



* Guarded表示被守护、被保卫、被保护。Suspension表示暂停。如果执行现在的处理会造成问题, 就让执行处理的线程进行等待——这就是Guarded Suspension模式
* Guarded Suspension模式通过让线程等待来保证实例的安全型。Guarded Suspension也称为guarded wait、spin lock等名称



### 示例程序:



![](D:/software/Typora/media/image329.png)

* 应用保护条件进行保护: 
* ![](D:/software/Typora/media/image330.png)
* 上图中,getRequest方法执行的逻辑是从queue中取出一个Request实例,即 queue.remove() , 但是要获取Request实例,必须满足条件:  queue.peek() != null 。该条件就是GuardedSuspension模式的守护条件(guard condition)
* 当线程执行到while语句时: 
* 若守护条件成立,线程不进入while语句块,直接执行queue.remove()方法,线程不会等待。 若守护条件不成立,线程进入while语句块,执行wait,开始等待
* ![](D:/software/Typora/media/image331.png)
* 若守护条件不成立,则线程等待。等待什么?等待notifyAll()唤醒该线程
* 守护条件阻止了线程继续向前执行,除非实例状态发生改变,守护条件成立,被另一个线程唤醒。 该类中的synchronized关键字保护的是queue字段,getRequest方法的synchronized保护该方法只能由一个线程执行
* 线程执行this.wait之后,进入this的等待队列,并释放持有的this锁
* notify、notifyAll或interrupt会让线程退出等待队列,实际继续执行之前还必须再次获取this的锁线程才可以继续执行



### 时序图



* Guarded Suspension模式中的角色
* GuardedObject(被保护的对象) GuardedObject角色是一个持有被保护(guardedMethod)的方法的类。当线程执行guardedMethod方法时,若守护条件成立,立即执行；当守护条件不成立,等待。守护条件随着GuardedObject角色的状态不同而变
* 除了guardedMethod之外,GuardedObject角色也可以持有其他改变实例状态(stateChangingMethod)的方法
* java中,guardedMethod通过while语句和wait方法来实现,stateChangingMethod通过notify/notifyAll方法实现
* 在本案例中,RequestQueue为GuardedObject,getRequest方法为guardedMethod,putRequest为stateChangingMethod
* 可以将Guarded Suspension理解为多线程版本的if



### LinkedBlockingQueue



* 可以使用LinkedBlockingQueue替代RequestQueue



#### 类图

![](D:/software/Typora/media/image332.png)



## Balking模式



* 所谓Balk,就是停止并返回的意思
* Balking模式与Guarded Suspension模式一样,也存在守护条件。在Balking模式中,如果守护条件不成立,则立即中断处理。而Guarded Suspension模式一直等待直到可以运行



### 示例程序



* 两个线程,一个是修改线程,修改之后,等待随机时长,保存文件内容。另一个是保存线程,固定时长进行文件内容的保存。
* 如果文件需要保存,则执行保存动作
* 如果文件不需要保存,则不执行保存动作



### 执行效果

![](D:/software/Typora/media/image333.png)



### Balking模式中的角色



* GuardedObject(受保护对象)
* GuardedObject角色是一个拥有被保护的方法(guardedMethod)的类。当线程执行guardedMethod时,若保护条件成立,则执行实际的处理,若不成立,则不执行实际的处理,直接返回
* 护条件的成立与否随着GuardedObject角色状态的改变而变动
* 除了guardedMethod之外,GuardedObject角色还有可能有其他改变状态的方法(stateChangingMethod)
* 在此案例中,Data类对应于GuardedObject,save方法对应guardedMethod,change方法对应stateChangingMethod方法
* 保护条件是changed字段为true



### 类图



![](D:/software/Typora/media/image334.png)



### 使用场景



* 不需要执行时
* 在此示例程序中,content字段的内容如果没有修改,就将save方法balk。之所以要balk,是因为content已经写文件了,无需再写了。如果并不需要执行,就可以使用Balking模式。此时可以提高程序 性能
* 不需要等待守护条件成立时
* Balking模式的特点就是不等待。若条件成立,就执行,若不成立,就不执行,立即进入下一个操 作。
* 守护条件仅在第一次成立时
* 当“守护条件仅在第一次成立”时,可以使用Balking模式
* 比如各种类的初始化操作,检查一次是否初始化了,如果初始化了,就不用执行了。如果没有初始 化,则进行初始化



### balk结果的表示



* 忽略balk:最简单的方式就是不通知调用端“发生了balk”。示例程序采用的就是这种方式
* 通过返回值表示balk:通过boolean值表示balk。若返回true,表示未发生balk,需要执行并执行了处理。若false,则表 示发生了balk,处理已执行,不再需要执行
  * 有时也会使用null来表示“发生了balk”
* 通过异常表示balk
  * 有时也通过异常表示“发生了balk”。即,当balk时,程序并不从方法return,而是抛异常



### Balking和GuardedSuspension



* 介于“直接balk并返回”和“等待到守护条件成立为止“这两种极端之间的还有一种”在守护条件成立之 前等待一段时间“。在守护条件成立之前等待一段时间,如果到时条件还未成立,则直接balk
* 这种操作称为计时守护(guarded timed)或超时(timeout)



### java.util.concurrent中的超时



* 通过异常通知超时
  * 当发生超时抛出异常时,不适合使用返回值表示超时,需要使用java.util.concurrent.TimeoutException异常
  * 如: java.util.concurrent.Future的get方法；java.util.concurrent.Exchanger的exchange方法； java.util.concurrent.Cyclicarrier的await方法;java.util.concurrent.CountDownLatch的await方法
* 通过返回值通知超时
  * 当执行多次try时,则不使用异常,而使用返回值表示超时。如: java.util.concurrent.BlockingQueue接口,当offer方法的返回值为false,或poll方法的返回值为null,表示发生了超时
  * java.util.concurrent.Semaphore类,当tryAcquire方法的返回值为false时,表示发生了超时
  * java.util.concurrent.locks.Lock接口,当tryLock方法的返回值为false时,表示发生了超时



## Producer-Consumer



### 示例程序



* 执行效果:

![](D:/software/Typora/media/image335.png)

* 关于put()
  * put方法会抛出InterruptedException异常。如果抛出,可以理解为该操作已取消
  * put方法使用了Guarded Suspension模式。tail和count的更新采取buffer环的形式。notifyAll方法唤醒正在等待馒头的线程来吃
* 关于take()
  * take方法会抛出InterruptedException异常,表示该操作已取消
  * take方法采用了Guarded Suspension模式
  * head和count的更新采用了buffer环的形式。notifyAll唤醒等待的厨子线程开始蒸馒头



### 时序图



### 角色



* Data
  * Data角色由Producer角色生成,供Consumer角色使用。在本案例中,String类的馒头对应于Data角色
* Producer
  * Producer角色生成Data角色,并将其传递给Channel角色。本案例中,CookerThread对应于Producer角色
* Consumer
  * Consumer角色从Channel角色获取Data角色并使用。本案例中,EaterThread对应于Consumer角色
* Channel角色
  * Channel角色管理从Producer角色获取的Data角色,还负责响应Consumer角色的请求,传递Data角色。为了安全,Channel角色会对Producer角色和Consumer角色进行互斥处理
* 当producer角色将Data角色传递给Channel角色时,如果Channel角色状态不能接收Data角色,则Producer角色将一直等待,直到Channel可以接收Data角色为止
* 当Consumer角色从Channel角色获取Data角色时,如果Channel角色状态没有可以传递的Data角 色,则Consumer角色将一直等待,直到Channel角色状态转变为可以传递Data角色为止
* 当存在多个Producer角色和Consumer角色时,Channel角色需要对它们做互斥处理
* ![](/image336.png)
* 类图: 
* 守护安全性的Channel角色(可复用)
* 在生产者消费者模型中,承担安全守护责任的是Channel角色。Channel角色执行线程间的互斥处 理,确保Producer角色正确地将Data角色传递给Consumer角色



### 不要直接传递



* Consumer角色想要获取Data角色,通常是因为想使用这些Data角色来执行某些处理。如果Producer角色直接调用Consumer的方法,执行处理的就不是Consumer的线程,而是Producer角色的 线程了。这样一来,异步处理变同步处理,会发生不同Data间的延迟,降低程序的性能



### 传递Data角色的顺序



* 队列——先生产先消费
* 栈——先生产后消费
* 优先队列——”优先“的先消费



### Channel意义



* 线程的协调要考虑”放在中间的东西“ 线程的互斥要考虑”应该保护的东西“为了让线程协调运行,必须执行互斥处理,以防止共享的内容被破坏。线程的互斥处理时为了线程 的协调运行而执行的



### JUC包和Producer-Consumer



* JUC中提供了BlockingQueue接口及其实现类,相当于Producer-Consumer模式中的Channel角色

![](D:/software/Typora/media/image337.png)

* BlockingQueue接口——阻塞队列ArrayBlockingQueue——基于数组的BlockingQueue
* LinkedBlockingQueue——基于链表的BlockingQueue
* PriorityBlockingQueue——带有优先级的BlockingQueue
* DelayQueue——一定时间之后才可以take的BlockingQueue SynchronousQueue——直接传递的BlockingQueue
* ConcurrentLinkedQueue——元素个数没有最大限制的线程安全队列



## Read-Write Lock



* 当线程读取实例的状态时,实例的状态不会发生变化。实例的状态仅在线程执行写入操作时才会发 生变化。
* 从实例状态变化来看,读取和写入有本质的区别
* 在本模式中,读取操作和写入操作分开考虑。在执行读取操作之前,线程必须获取用于读取的锁。 在执行写入操作之前,线程必须获取用于写入的锁
* 可以多个线程同时读取,读取时不可写入
* 当线程正在写入时,其他线程不可以读取或写入
* 一般来说,执行互斥会降低程序性能。如果把写入的互斥和读取的互斥分开考虑,则可以提高性 能



### 示例程序



#### 入口程序



* **数据对象**
* **读写锁**
* **写线程**
* **读取线程**
* **守护条件**
* readLock方法和writeLock方法都是用了Guarded Suspension模式。Guarded Suspension模式的重点是守护条件。



### readLock()



* 读取线程首先调用readLock方法。当线程从该方法返回,就可以执行实际的读取操作。
* 当线程开始执行实际的读取操作时,只需要判断是否存在正在写入的线程,以及是否存在正在等待 的写入线程。
* 不考虑读取线程
* 如果存在正在写入的线程或者存在正在等待的写线程,则等待



### writeLock()



* 在线程开始写入之前,调用writeLock方法。当线程从该方法返回后,就可以执行实际的写入操作。 开始执行写入的条件: 如果有线程正在执行读取操作,出现读写冲突；或者如果有线程正在执行写入的操作,引起写冲突,当前线程等待



### 角色



#### Reader



* 该角色对共享资源角色执行读取操作



#### Writer



* 该角色对共享资源角色执行写操作



#### SharedResource



* 共享资源角色表示Reader角色和Writer角色共享的资源。共享资源角色提供不修改内部状态的操作(读取)和修改内部状态的操作(写)
* 当前案例中对应于Data类



#### ReadWriteLock



* 读写锁角色提供了共享资源角色实现读操作和写操作时需要的锁,即当前案例中的readLock和readUnlock,以及writeLock和writeUnlock。对应于当前案例中ReadWriteLock类
* ![](image338.png)![](D:/software/Typora/media/image341.png)



### 要点



* 利用读取操作的线程之间不会冲突的特性来提高程序性能
  * Read-Write Lock模式利用了读操作的线程之间不会冲突的特性。由于读取操作不会修改共享资源的状态,所以彼此之间无需加锁。因此,多个Reader角色同时执行读取操作,从而提高 程序性能
* 适合读取操作负载较大的情况
  * 如果单纯使用Single Threaded Execution模式,则read也只能运行一个线程。如果read负载很重,可以使用Read-Write Lock模式
* 适合少写多读
  * Read-Write Lock模式优点是Reader之间不会冲突。如果写入很频繁,Writer会频繁停止Reader的处理,也就无法体现出Read-Write Lock模式的优势了



### 锁的含义



* synchronized可以用于获取实例的锁。java中同一个对象锁不能由两个以上的线程同时获取。用于读取的锁和用于写入的锁与使用synchronized获取的锁是不一样的。开发人员可以通过修改ReadWriteLock类来改变锁的运行
* ReadWriteLock类提供了用于读取的锁和用于写入的锁两个逻辑锁,但是实现这两个逻辑锁的物理 锁只有一个,就是ReadWriteLock实例持有的锁



### JUC包和Read-Write Lock



* java.util.concurrent.locks包提供了已实现Read-Write Lock模式的ReadWriteLock接口和ReentrantReadWriteLock类
* java.util.concurrent.locks.ReadWriteLock接口的功能和当前案例中的ReadWriteLock类类似。不 同之处在于该接口用于读取的锁和用于写入的锁是通过其他对象来实现的
* java.util.concurrent.locks.ReentrantReadWriteLock类实现了ReadWriteLock接口。其特征如下:  
* 公平性:当创建ReentrantReadWriteLock类的实例时,可以选择锁的获取顺序是否要设置为fair的。如果创建的实例是公平的,那么等待时间久的线程将可以优先获取锁
* 可重入性:ReentrantReadWriteLock类的锁是可重入的。Reader角色的线程可以获取用于写入的锁,Writer角色的线程可以获取用于读取的锁
* 锁降级:ReentrantReadWriteLock类可以按如下顺序将用于写入的锁降级为用于读取的锁:
* 用于读取的锁不能升级为用于写入的锁。快捷方法ReentrantReadWriteLock类提供了获取等待中的线程个数的方法 getQueueLength ,以及检查是否获取了用于写入锁的方法 isWriteLocked 等方法



## Thread-Per-Message



* 该模式可以理解为“每个消息一个线程”。消息这里可以理解为命令或请求。每个命令或请求分配一 个线程,由这个线程来处理
* 这就是Thread-Per-Message模式
* 在Thread-Per-Message模式中,消息的委托方和执行方是不同的线程



### 示例程序



* 在此示例程序中,ConcurrentDemo类委托Host来显示字符。Host类会创建一个线程,来处理委 托。启动的线程使用Helper类来执行实际的显示



### 主入口类



* **处理器类**
* **工具类**
* ![](D:/software/Typora/media/image342.png)



### 角色



* Client(委托方):Client角色向Host角色发起请求,而不用关心Host角色如何实现该请求处理。 当前案例中对应于ConcurrentDemo类
* Host:Host角色收到Client角色请求后,创建并启用一个线程。新建的线程使用Helper角色来处理请求。 当前案例中对应于Host类
* Helper:Helper角色为Host角色提供请求处理的功能。Host角色创建的新线程调用Helper角色。 当前案例中对应于Helper类



### 类图**1**



![](D:/software/Typora/media/image343.png)



### 要点



* 提高响应性,缩短延迟时间
  * Thread-Per-Message模式能够提高与Client角色对应的Host角色的响应性,降低延迟时间。 尤其是当handle操作非常耗时或者handle操作需要等待输入/输出时,效果很明显
  * 为了缩短线程启动花费的时间,可以使用Worker Thread模式
* 适用于操作顺序没有要求时
  * 在Thread-Per-Message模式中,handle方法并不一定按照request方法的调用顺序来执行
* 适用于不需要返回值时
  * Thread-Per-Message模式中,request方法并不会等待handle方法的执行结束。request得不到handle的结果
  * 当需要获取操作结果时,可以使用Future模式
* 应用于服务器



### JUC和Thread-Per-Message



* java.lang.Thread:最基本的创建、启动线程的类
* java.lang.Runnable:线程锁执行的任务接口
* java.util.concurrent.ThreadFactory:将线程创建抽象化的接口
* java.util.concurrent.Executors:用于创建实例的工具类
* java.util.concurrent.Executor:将线程执行抽象化的接口
* java.util.concurrent.ExecutorService:将被复用的线程抽象化的接口
* java.util.concurrent.ScheduledExecutorService:将被调度线程的执行抽象化的接口



### 类图2



> ![](D:/software/Typora/media/image341.png)
>
> ![](D:/software/Typora/media/image351.png)



## Worker Thread



* 在Worker Thread模式中,工人线程(worker thread)会逐个取回工作并进行处理。当所有工作全部完成后,工人线程会等待新的工作到来。
* Worker Thread模式也被称为Background Thread模式。有时也称为Thread Pool模式



### 示例程序



* ClientThread类的线程会向Channel类发送工作请求(委托)。
* Channel类的实例有五个工人线程进行工作。所有工人线程都在等待工作请求的到来。
* 当收到工作请求后,工人线程会从Channel获取一项工作请求并开始工作。工作完成后,工人线程 回到Channel那里等待下一项工作请求



### 类图



![](D:/software/Typora/media/image353.jpeg)

> **时序图**
>
> threadPool = new WorkerThread\[threads\];
>
> for (int i = 0; i \< threadPool.length; i++) { threadPool\[i\] = new WorkerThread("Worker-" + i, this);
>
> }
>
> 
>
> 62 }
>
> public void startWorkers() {
>
> for (int i = 0; i \< threadPool.length; i++) { threadPool\[i\].start();
>
> }
>
> }
>
> public synchronized void putRequest(Request request) { while (count \>= requestQueue.length) {
>
> try {
>
> wait();
>
> } catch (InterruptedException e) {
>
> }
>
> }
>
> requestQueue\[tail\] = request;
>
> tail = (tail + 1) % requestQueue.length; count++;
>
> notifyAll();
>
> }
>
> public synchronized Request takeRequest() { while (count \<= 0) {
>
> try {
>
> wait();
>
> } catch (InterruptedException e) {
>
> }
>
> }
>
> Request request = requestQueue\[head\]; head = (head + 1) % requestQueue.length; count--;
>
> notifyAll(); return request;
>
> }



### 角色



* Client(委托者):Client角色创建Request角色并将其传递给Channel角色。在本例中,ClientThread对应Client角色。
* Channel:Channel角色接收来自Client角色的Request角色,并将其传递给Worker角色。在本例中,Channel类对应Channel角色
* Worker:Worker角色从Channel角色中获取Request角色,并执行其逻辑。当一项工作结束后,继续从Channel获取另外的Request角色。本例中,WorkerThread类对应Worker角色
* Request:Request角色表示工作。Request角色中保存了工作的逻辑。本例中,Request类对应Request角色



### 优点



* 提高吞吐量
  * 如果将工作交给其他线程,当前线程就可以处理下一项工作,称为Thread Per Message模式。
  * 由于启动新线程消耗时间,可以通过Worker Thread模式轮流和反复地使用线程来提高吞吐量。
* 容量控制
  * Worker角色的数量在本例中可以传递参数指定
  * Worker角色越多,可以并发处理的逻辑越多。同时增加Worker角色会增加消耗的资源。必须 根据程序实际运行环境调整Worker角色的数量
* 调用与执行的分离
  * Worker Thread模式和Thread Per Message模式一样,方法的调用和执行是分开的。方法的调用是invocation,方法的执行是execution
  * 这样,可以: 
  * 提高响应速度；
  * 控制执行顺序,因为执行不受调用顺序的制约； 可以取消和反复执行
  * 进行分布式部署,通过网络将Request角色发送到其他Woker计算节点进行处理
* Runnable接口的意义
  * java.lang.Runnable 接口有时用作Worker Thread模式的Request角色。即可以创建Runnable接口的实现类对象表示业务逻辑,然后传递给Channel角色
  * Runnable对象可以作为方法参数,可以放到队列中,可以跨网络传输,也可以保存到文件 中。如此则Runnable对象不论传输到哪个计算节点,都可以执行
* 多态的Request角色
  * 本案例中,ClientThread传递给Channel的只是Request实例。但是WorkerThread并不知道Request类的详细信息
  * 即使我们传递的是Request的子类给Channel,WorkerThread也可以正常执行execute方法。 通过Request的多态,可以增加任务的种类,而无需修改Channel角色和Worker角色



### JUC和Worker Thread



* ThreadPoolExecutor:java.util.concurrent.ThreadPoolExecutor 类是管理Worker线程的类。可以轻松实现Worker Thread模式
* 通过 java.util.concurrent 包创建线程池java.util.concurrent.Executors类就是创建线程池的工具类



## Future



* 假设由一个方法需要长时间执行才能获取结果,则一般不会让调用的程序等 待,而是先返回给它一张“提货卡”。获取提货卡并不消耗很多时间。该“提货卡”就是Future角色
* 获取Future角色的线程稍后使用Future角色来获取运行结果



### 示例程序



#### Host类

**Data接口: **

**FutureData类: **

**RealData类: **

**Main类: **



### 流程图

![](D:/software/Typora/media/image354.png)



### 角色



* Client(请求者):Client角色向Host角色发出请求,并立即接收到请求的处理结果——VirtualData角色,也就是Future角色
  * Client角色不必知道返回值是RealData还是Future角色。稍后通过VirtualData角色来操作。 本案例中,对应Main类
* Host:Host角色创建新的线程,由新线程创建RealData角色。同时,Host角色将Future角色(当做VirtualData角色)返回给Client角色。本案例中对应Host类
* VirtualData(虚拟数据):VirtualData角色是让Future角色与RealData角色具有一致性的角色。本案例中对应Data接 口
* RealData(真实数据):RealData角色是表示真实数据的角色。创建该对象需要花费很多时间。本案例中对应RealData类
* Future:Future角色是RealData角色的“提货单”,由Host角色传递给Client角色。对Client而言,Future角色就是VirtualData角色。当Client角色操作Future角色时线程会wait,直到RealData角色创建完成
  * Future角色将Client角色的操作委托给RealData角色。本案例中,对应于FutureData类



### 要点



* 使用Thread Per Message模式,可以提高程序响应性,但是不能获取结果。Future模式也可以提高程序响应性,还可以获取处理结果
* 利用Future模式异步处理特性,可以提高程序吞吐量。虽然并没有减少业务处理的时长,但是 如果考虑到I/O,当程序进行磁盘操作时,CPU只是处于等待状态。CPU有空闲时间处理其他 的任务
* 准备返回值和使用返回值的分离
* 如果想等待处理完成后获取返回值,还可以考虑采用回调处理方式。即,当处理完成后,由Host角色启动的线程调用Client角色的方法,进行结果的处理。此时Client角色中的方法需要 线程安全地传递返回值



### JUC与Future



* java.util.concurrent包提供了用于支持Future模式的类和接口
* java.util.concurrent.Callable接口将“返回值的某种处理调用”抽象化了。Callable接口声明了call方法。call方法类似于Runnable的run方法,但是call方法有返回值。Callable\<String\>表示Callable接口的call方法返回值类型为String类型
* java.util.concurrent.Future接口相当于本案例中的Future角色。Future接口声明了get方法来获取结果,但是没有声明设置值的方法。设置值的方法需要在Future接口的实现类中声明。Future\<String\> 表示“Future接口的get方法返回值类型是String类型”。除了get方法,Future接口还声明了用于中断运行 的cancel方法
* java.util.concurrent.FutureTask类是实现了Future接口的标准类。FutureTask类声明了用于获取值的get方法、用于中断运行的cancel方法、用于设置值的set方法,以及用于设置异常的setException 方法。由于FutureTask类实现了Runnable接口,还声明了run方法



### Callable、Future、FutureTask类图

![](media/image355.png)
