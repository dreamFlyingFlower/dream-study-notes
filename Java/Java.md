# Java



# 配置



* windows上若更新JDK版本不成功,可删除`C:\ProgramData\Oracle\Java`下的javapath目录,或者`C:\Program Files\Common Files\Oracle\Java\`下的javapath目录



# String



```java
// 以下语句创建了几个对象
String s = new String("xyz");
```



* 如果当前语句的前面没有创建过xyz对象,不管是new还是直接字符串常量,则会创建3个:s,new,常量池

```java
public static void main(String[] args) {
    String s = new String("xyz");
}
```



```java
Compiled from "TestApplication.java"

Constant pool:
#1 = Class              #2             // com/wy/TestApplication
#2 = Utf8               com/wy/TestApplication
#3 = Class              #4             // java/lang/Object
#4 = Utf8               java/lang/Object
#5 = Utf8               <init>
#6 = Utf8               ()V
#7 = Utf8               Code
#8 = Methodref          #3.#9          // java/lang/Object."<init>":()V
#9 = NameAndType        #5:#6          // "<init>":()V
#10 = Utf8               LineNumberTable
#11 = Utf8               LocalVariableTable
#12 = Utf8               this
#13 = Utf8               Lcom/wy/TestApplication;
#14 = Utf8               main
#15 = Utf8               ([Ljava/lang/String;)V
#16 = Class              #17            // java/lang/String
#17 = Utf8               java/lang/String
#18 = String             #19            // xyz
#19 = Utf8               xyz
#20 = Methodref          #16.#21        // java/lang/String."<init>":(Ljava/lang/String;)V
#21 = NameAndType        #5:#22         // "<init>":(Ljava/lang/String;)V
#22 = Utf8               (Ljava/lang/String;)V
#23 = Utf8               args
#24 = Utf8               [Ljava/lang/String;
#25 = Utf8               s
#26 = Utf8               Ljava/lang/String;
#27 = Utf8               MethodParameters
#28 = Utf8               SourceFile
#29 = Utf8               TestApplication.java    

public class com.wy.TestApplication {
public com.wy.TestApplication();
Code:
0: aload_0
1: invokespecial #8                  // Method java/lang/Object."<init>":()V
4: return

public static void main(java.lang.String[]);
Code:
0: new           #16                // class java/lang/String
3: dup
4: ldc            #18                 // String xyz 查看上面的Constant Pool#18,跳到19,创建了一个xyz常量
6: invokespecial #20          // Method java/lang/String."<init>":(Ljava/lang/String;)V
9: astore_1
10: return
```



* 如果当前语句之前创建过xyz,则只有2个:s,new

```java
Constant pool:
   #1 = Class              #2             // com/wy/TestApplication
   #2 = Utf8               com/wy/TestApplication
   #3 = Class              #4             // java/lang/Object
   #4 = Utf8               java/lang/Object
   #5 = Utf8               <init>
   #6 = Utf8               ()V
   #7 = Utf8               Code
   #8 = Methodref          #3.#9          // java/lang/Object."<init>":()V
   #9 = NameAndType        #5:#6          // "<init>":()V
  #10 = Utf8               LineNumberTable
  #11 = Utf8               LocalVariableTable
  #12 = Utf8               this
  #13 = Utf8               Lcom/wy/TestApplication;
  #14 = Utf8               main
  #15 = Utf8               ([Ljava/lang/String;)V
  #16 = String             #17            // xyz
  #17 = Utf8               xyz
  #18 = Class              #19            // java/lang/String
  #19 = Utf8               java/lang/String
  #20 = Methodref          #18.#21        // java/lang/String."<init>":(Ljava/lang/String;)V
  #21 = NameAndType        #5:#22         // "<init>":(Ljava/lang/String;)V
  #22 = Utf8               (Ljava/lang/String;)V
  #23 = Utf8               args
  #24 = Utf8               [Ljava/lang/String;
  #25 = Utf8               x
  #26 = Utf8               Ljava/lang/String;
  #27 = Utf8               s
  #28 = Utf8               MethodParameters
  #29 = Utf8               SourceFile
  #30 = Utf8               TestApplication.java
{
  public com.wy.TestApplication();
    descriptor: ()V
    flags: ACC_PUBLIC
    Code:
      stack=1, locals=1, args_size=1
         0: aload_0
         1: invokespecial #8                  // Method java/lang/Object."<init>":()V
         4: return
      LineNumberTable:
        line 10: 0
      LocalVariableTable:
        Start  Length  Slot  Name   Signature
            0       5     0  this   Lcom/wy/TestApplication;

  public static void main(java.lang.String[]);
    descriptor: ([Ljava/lang/String;)V
    flags: ACC_PUBLIC, ACC_STATIC
    Code:
      stack=3, locals=3, args_size=1
         0: ldc           #16                 // String xyz
         2: astore_1
         3: new           #18                 // class java/lang/String
         6: dup
         7: ldc           #16                 // String xyz
         9: invokespecial #20                 // Method java/lang/String."<init>":(Ljava/lang/String;)V
        12: astore_2
        13: return
      LineNumberTable:
        line 13: 0
        line 14: 3
        line 15: 13
      LocalVariableTable:
        Start  Length  Slot  Name   Signature
            0      14     0  args   [Ljava/lang/String;
            3      11     1     x   Ljava/lang/String;
           13       1     2     s   Ljava/lang/String;
    MethodParameters:
      Name                           Flags
      args
}
SourceFile: "TestApplication.java"
```



# ThreadPoolExecutor



## execute



```java
public void execute(Runnable command) {
    if (command == null)
        throw new NullPointerException();
    int c = ctl.get();
    // worker数量比核心线程数小,直接创建worker执行任务
    if (workerCountOf(c) < corePoolSize) {
        if (addWorker(command, true))
            return;
        c = ctl.get();
    }
    // worker数量超过核心线程数,任务直接进入队列
    if (isRunning(c) && workQueue.offer(command)) {
        // 再次检查线程池状态,防止状态发生变化
        int recheck = ctl.get();
        // 线程池状态不是RUNNING,说明执行过shutdown命令,需要对新加入的任务执行reject()
        if (! isRunning(recheck) && remove(command))
            reject(command);
        // 判断0是因为核心线程数可为0
        else if (workerCountOf(recheck) == 0)
            addWorker(null, false);
    }
    // 如果线程池不是RUNNING,或者任务进入队列失败,则尝试创建worker执行任务
    // 线程池不是RUNNING时,addWorker内部会判断线程池状态
    // addWorker第2个参数表示是否创建核心线程
    // addWorker返回false表示任务执行失败,需要执行reject
    else if (!addWorker(command, false))
        reject(command);
}
```



## addWorker



```java
private boolean addWorker(Runnable firstTask, boolean core) {
    retry:
    // 双重for循环给worker数量加1
    // 外层自旋
    for (;;) {
        int c = ctl.get();
        int rs = runStateOf(c);

        // 1.线程池状态大于SHUTDOWN时,直接返回false
        // 2.线程池状态等于SHUTDOWN,且firstTask不为null,直接返回false
        // 3.线程池状态等于SHUTDOWN,且队列为空,直接返回false
        if (rs >= SHUTDOWN &&
            ! (rs == SHUTDOWN &&
               firstTask == null &&
               ! workQueue.isEmpty()))
            return false;
	// 内存自旋
        for (;;) {
            int wc = workerCountOf(c);
            // worker数量超过容量,直接返回false
            if (wc >= CAPACITY ||
                wc >= (core ? corePoolSize : maximumPoolSize))
                return false;
            // 使用CAS增加worker数量,若成功,则直接跳出外层循环进入到第二部分
            if (compareAndIncrementWorkerCount(c))
                break retry;
            c = ctl.get();  // Re-read ctl
            // 如果线程池状态发生改变,对外层循环进行自旋
            if (runStateOf(c) != rs)
                continue retry;
            // 其他情况直接内层自旋即可
            // else CAS failed due to workerCount change; retry inner loop
        }
    }

    boolean workerStarted = false;
    boolean workerAdded = false;
    Worker w = null;
    // 执行线程
    try {
        w = new Worker(firstTask);
        final Thread t = w.thread;
        if (t != null) {
            final ReentrantLock mainLock = this.mainLock;
            mainLock.lock();
            try {
                // Recheck while holding lock.
                // Back out on ThreadFactory failure or if
                // shut down before lock acquired.
                int rs = runStateOf(ctl.get());

                if (rs < SHUTDOWN ||
                    (rs == SHUTDOWN && firstTask == null)) {
                    // worker已经调用过start(),则不再创建worker
                    if (t.isAlive()) // precheck that t is startable
                        throw new IllegalThreadStateException();
                    // worker创建并添加到workers成功
                    workers.add(w);
                    int s = workers.size();
                    if (s > largestPoolSize)
                        largestPoolSize = s;
                    workerAdded = true;
                }
            } finally {
                mainLock.unlock();
            }
            if (workerAdded) {
                t.start();
                workerStarted = true;
            }
        }
    } finally {
        // worker线程启动失败,说明线程池状态发生变化,需要进行shutdown相关操作
        if (! workerStarted)
            addWorkerFailed(w);
    }
    return workerStarted;
}
```



## runWorker



```java
final void runWorker(Worker w) {
    Thread wt = Thread.currentThread();
    Runnable task = w.firstTask;
    w.firstTask = null;
    // worker本身是一把锁,此处调用unlock()是为了让外部可以中断
    w.unlock(); // allow interrupts
    // 用于判断是否进入过自旋(while)
    boolean completedAbruptly = true;
    try {
        // 1.如果firstTask不为null,则执行firstTask;
        // 2.如果firstTask为null,则调用getTask()从队列获取任务
        // 3.阻塞队列的特性就是:当队列为空时,当前线程会被阻塞等待
        while (task != null || (task = getTask()) != null) {
            // 这儿对worker进行加锁,是为了达到下面的目的
            // 1. 降低锁范围,提升性能
            // 2. 保证每个worker执行的任务是串行的
            w.lock();
            // If pool is stopping, ensure thread is interrupted;
            // if not, ensure thread is not interrupted.  This
            // requires a recheck in second case to deal with
            // shutdownNow race while clearing interrupt
            // 如果线程池正在停止,则对当前线程进行中断操作
            if ((runStateAtLeast(ctl.get(), STOP) ||
                 (Thread.interrupted() &&
                  runStateAtLeast(ctl.get(), STOP))) &&
                !wt.isInterrupted())
                wt.interrupt();
            // 执行任务,且在执行前后通过beforeExecute()和afterExecute()进行扩展
            try {
                beforeExecute(wt, task);
                Throwable thrown = null;
                try {
                    task.run();
                } catch (RuntimeException x) {
                    thrown = x; throw x;
                } catch (Error x) {
                    thrown = x; throw x;
                } catch (Throwable x) {
                    thrown = x; throw new Error(x);
                } finally {
                    afterExecute(task, thrown);
                }
            } finally {
                task = null;
                w.completedTasks++;
                w.unlock();
            }
        }
        completedAbruptly = false;
    } finally {
        // 自旋操作被退出,说明线程池正在结束
        processWorkerExit(w, completedAbruptly);
    }
}
```

