# ClassByteCode



# 概述



* 字节码指令:由一个字节长度的,代表某种特定操作含义的数字,称之为操作码,以及跟随其后的0至多个代表此操作所需参数的操作数而构成
* 在执行每条指令之前,JVM要求该指令的操作数已被压入操作数栈中.在执行指令时,JVM会将该指令所需的操作数弹出,并将指令的结果重新压入栈中
* 操作码的长度为1个字节,因此最大只有256条
* 基于栈的指令集架构
* 在虚拟机的指令集中,大多数的指令都包含了其操作所对应的数据类型信息
* 加载和存储指令用于将数据在栈帧中的局部变量表和操作数栈之间来回传输
* 将局部变量表加载到操作数栈:aload_0
* 将一个数值从操作数栈存储到局部变量表:istore,lfda
* 将一个常量加载到操作数栈:bipush,sipush,ldc,ldc_w,ldc2_w,aconst_null,iconst_m1,iconst
* 扩充局部变量表的访问索引指令:wide



# JVM编译



* 使用javap -vp编译class文件,即可得到JVM指令对应的格式

```java
<index> <opcode> [ <operand1> [ <operand2>... ]] [<comment>]
```

```java
public void spin() {
    int i; 
    for (i = 0; i < 100; i++) {
    }
} 
```

```java
0   iconst_0       // Push int constant 0
1   istore_1       // Store into local variable 1 (i=0)
2   goto 8         // First time through don't increment
5   iinc 1 1       // Increment local variable 1 by 1 (i++)
8   iload_1        // Push local variable 1 (i)
9   bipush 100     // Push int constant 100
11  if_icmplt 5    // Compare and loop if less than (i < 100)
14  return         // Return void when done
```



# 特殊指令



* <clinit>():
* <init>():
* nop:什么都不做
* dup:复制栈顶数值并将复制值压入栈顶
* new:创建一个对象,并将其引用值压入栈顶
* i:对int类型的操作
* l:对long类型的操作
* s:对short的操作
* b:对byte类型的操作
* c:对char类型的操作
* f:对float类型的操作
* d:对double类型的操作



# 加载与存储指令



## 常量入栈



* 将一个常量加载到操作数栈顶
* aconst_null:null对象入栈
* iconst_m1:int常量-1入栈,只能让-1入栈,如果是其他负数,需要根据情况使用bipush或sipush
* iconst_n(要入栈的数字):int常量n入栈,n取值范围只能是0-5,超过范围的,根据情况使用bipush或sipush
* lconst_n:long常量n入栈,n取值只能是0,1,超出的用ldc2_w
* fconst_n:float n.0入栈,n只能取值0-2,超出的同iconst
* dconst_n:double n.0 入栈,n取值0-1,超出的用ldc2_w
* bipush:8位带符号整数入栈,取值范围为-128-127,超过的根据情况使用sipush或ldc
* sipush:16位带符号整数入栈,取值范围为-32768-32767,超过的用ldc
* ldc:常量池万能入栈,接收一个8位的参数,该参数指向常量池中int,float或String的索引
* ldc_w:接收两个8位参数,能支持的范围大于ldc
* ldc2_w:压入long或double类型,该参数指向常量池中int,float或String的索引



## 局部变量压栈



* xload_n:将局部变量表中索引为n的局部变量推送至操作数栈的栈顶
  * x: 数据类型,可以是i l f d a,具体表示int,long,float,double,object ref
  * n: 0,1,2,3.表示局部变量表的索引.如果n超过3,则可以使用xload n
* xaload(x为i l f d a b c s)
  * 分别表示int,long,float,double,obj ref ,byte,char,short
  * 从局部变量表数组中取得给定索引的值,将该值压入栈顶
  * iaload
    * 执行前,栈:..., arrayref, index
    * 它取得arrayref所在数组的index的值,并将值压栈
    * 执行后,栈:..., value



## 出栈载入局部变量



* xstore_n:将栈顶数据存储到局部变量表索引n的位置
  * x: 为i l f d a,表示int,long,float,double,object ref
  * n: 0,1,2,3.局部变量表索引为n的位置.如果超过3,使用xstore n
* xastore_n(x为i l f d a b c s)
  * 将值存入数组中
  * iastore
    * 执行前,栈:...,arrayref, index, value
    * 执行后,栈:...
    * 将value存入arrayref[index]



# 运算指令



* 运算指令用于对两个操作数栈上的值进行某种特定的运算,并把结果存储到操作数栈顶
* 加法指令:iadd,ladd,fadd,dadd
* 减法指令:isub,lsub,fsub,dsub
* 乘法指令:imul,lmul,fmul,dmul
* 除法指令:idiv,ldiv,fdiv,ddiv
* 求余指令:irem,lrem,frem,drem
* 取反指令:ineg,lneg,fneg,dneg
* 位移指令:ishl,ishr,iushr,lshl,lshr,lushr
* 按位或指令:ior,lor
* 按位与指令:iand,land
* 按位异或指令:ixor,lxor
* 局部变量自增指令:iinc
* 比较指令:dcmpg,dcmpl,fcmpg,fcmpl,lcmp



# 类型转换指令



* 类型转换指令可以将两种不同的数值类型进行相互转换,这些转换操作一般用于实现用户代码中的显示类型转换操作以及用来处理字节码指令集中数据类型相关指令无法与数据类型一一对应的问题
* 宽化类型处理和窄化类型处理:类似子类转父类和父类转子类,int转long,long转int
* i2l,l2i,i2f,l2f,l2d,f2i,f2d,d2i,d2l,d2f,i2b,i2c,i2s
* i2l:将int转为long
  * 执行前,栈:..., value
  * 执行后,栈:...,result.word1,result.word2
  * 弹出int,扩展为long,并入栈



# 对象创建与访问指令



* new:创建普通类实例的指令
* newarray:基本类型数组创建
* anewarray:引用类型数组创建
* multianewarray:多维引用数组创建
* getfield:获取字段的值
* putfield:设置字段的值
* getstatic:获取静态字段的值
* putstatic:设置静态字段的值
* 把数组元素加载到操作数栈的指令:baload,caload,iaload,laload,saload,faload,faload,aaload(引用)
* 将操作数栈的值存储到数组元素:astore
* 取数组长度的指令:arraylength
* 检查实例类型的指令:instanceof,checkcast



# 操作数栈管理指令



* 操作数栈指令用于直接操作操作数栈
* 将操作数栈的一个或两个元素出栈:pop,pop2
* 复制栈顶一个或两个数值并将复制或双份渎职值重新压入栈顶:dup,dup2,dup_x1,dup_x2
* 将栈顶的两个数值替换:swap



# 控制转移指令



* 控制转移指令可以让Java虚拟机有条件或无条件的从指定位置指令执行而不是控制转移指令的下一条指令继续执行程序,即控制转移指令就是在修改PC寄存器的值
* 条件分支:
  * ifeq/ifne:如果为0/不为0,则跳转
    * 参数:byte1,byte2
    * value出栈,如果栈顶value为0则跳转到(byte1<<8)|byte2
    * 执行前,栈:...,value
    * 执行后,栈:...
  * iflt/ifle:如果小于0/小于等于0,则跳转
  * ifgt/ifge:如果大于0/大于de等于0,则跳转
  * ifnull/ifnonnull:如果为null/不为null,则跳转
  * if_icmpeq/if_icmpne:如果两个int相同/不同,则跳转
  * if_icmplt/if_icmple:如果int小于/小于等于,则跳转
  * if_icmpgt/if_icmpge:如果int大于/大于等于,则跳转
  * if_acmpeq/if_acmpne:如果2个引用类型相同/不同,则跳转
* 复合条件分支:tableswitch,lookupswitch
* 无条件分支:goto,goto_w,jsr,jsr_w,ret
* 在Java虚拟机中有专门的指令集用来处理int和引用类型的条件分支比较操作,为了可以无需明显标识一个实体值是否null,也有专门的指令用来检测 null 值
* boolean,byte,char,short的条件分支比较操作都使用int比较指令来完成,而对于long,float,double类型的条件分支比较操作,则会先执行相应类型的比较运算指令,运算指令会返回一个整形值到操作数栈中,随后再执行int类型的条件分支比较操作来完成整个分支跳转
* 由于各种类型的比较最终都会转化为int类型的比较操作,基于int类型比较的这种重要性,Java虚拟机提供了非常丰富的int类型的条件分支指令
* 所有int类型的条件分支转移指令进行的都是有符号的比较操作



# 方法调用和返回指令



* invokevirtual:用于调用对象的实例方法,根据对象的实际类型进行分派(虚方法分派),这也是Java语言中最常见的方法分派方式
* invokeinterface:用于调用接口方法,它会在运行时搜索一个实现了这个接口方法的对象,找出适合的方法进行调用
* invokespecial:用于调用一些需要特殊处理的实例方法,包括实例初始化方法,私有方法和父类方法.通常根据引用的类型选择方法,而不是对象的类来选择,即它使用静态绑定而不是动态绑定
* invokestatic:用于调用类方法(static方法)
* 方法返回指令是根据返回值的类型区分的,包括有ireturn(当返回值是boolean,byte,char,short和int 类型时使用),lreturn,freturn,dreturn和areturn.return指令供声明为void的方法,实例初始化方法,类和接口的类初始化方法使用
* invokedynamic:调用动态链接方法



# 比较控制指令



# 抛出异常



* 在程序中显式抛出异常的操作会由athrow指令实现,除了这种情况,还有别的异常会在其他Java虚拟机指令检测到异常状况时由虚拟机自动抛出



# 同步控制指令



* Java虚拟机可以支持方法级的同步和方法内部一段指令序列的同步,这两种同步结构都是使用管程(Monitor)来支持的
* 方法级的同步是隐式,即无需通过字节码指令来控制的,它实现在方法调用和返回操作之中
* 虚拟机可以从方法常量池中的方法表结构(method_info)中的ACC_SYNCHRONIZED访问标志区分一个方法是否同步方法
  * 当方法调用时,调用指令将会检查方法的ACC_SYNCHRONIZED访问标志是否被设置,如果设置了,执行线程将先持有管程,然后再执行方法,最后再方法完成(无论是正常完成还是非正常完成)时释放管程
  * 在方法执行期间,执行线程持有了管程,其他任何线程都无法再获得同一个管程
  * 如果一个同步方法执行期间抛出了异常,并且在方法内部无法处理此异常,那这个同步方法所持有的管程将在异常抛到同步方法之外时自动释放
* 同步一段指令集序列是由Java中的synchronized块来表示的,Java虚拟机的指令集中有monitorenter和monitorexit两条指令来支持synchronized关键字的语义,正确实现synchronized关键字需要编译器与Java虚拟机两者协作支持
* 结构化锁定(Structured Locking)是指在方法调用期间每一个管程退出都与前面的管程进入相匹配的情形.因为无法保证所有提交给Java虚拟机执行的代码都满足结构化锁定,所以Java虚拟机允许(但不强制要求)通过以下两条规则来保证结构化锁定成立.假设T代表一条线程,M代表一个管程:
  * T在方法执行时持有管程M的次数必须与T在方法完成(正常和非正常完成)时释放管程M的次数相等
  * 在方法调用过程中,任何时刻都不会出现线程T释放管程M的次数比T持有管程M次数多的情况
  * 在同步方法调用时自动持有和释放管程的过程也被认为是在方法调用期间发生



# 字节码执行引擎



## 运行时栈帧结构



![](F:/repository/dream-study-notes/Jvm/img/011.png)



* 栈帧也叫过程活动记录,是编译器用来进行方法调用和方法执行的一种数据结构,他是虚拟机运行时数据区域红的虚拟机栈的栈元素
* 栈帧中包含了局部变量表,操作数栈,动态链接和方法返回地址以及额外的一些附加信息,在编译过程中,局部变量表的大小已经确定,操作数栈深度也已经确定,因此栈帧在运行的过程中需要分配多大的内存是固定的,不受运行时影响
* 对于没有逃逸的对象也会在栈上分配内存,对象的大小其实在云习性时也是确定的,因此即使出现了栈上内存分配,也不会导致栈帧改变大小
* 一个线程中,可能调用链会很长,很多方法都同时处于执行状态
* 对于执行引擎,活动线程中,只有栈顶的栈帧是最有效的,称为当前栈帧,这个栈帧所关联的方法称为当前方法,执行引擎所运行的字节码指令仅对当前栈帧进行操作



## 局部变量表



* 使用Slot(槽)装载基本数据类型,引用,通常为32位,double和long占用2个slot
* 当一个变量的PC寄存器的值大于slot的作用域的时候,slot可以复用



## 操作数栈



* 每一个栈帧内部都包含一个称为操作数栈(Operand Stack)的后进先出栈
* 栈帧中操作数栈的长度由编译期决定,并且存储于类和接口的二进制表示之中,既通过方法的 Code 属性保存及提供给栈帧使用
* 操作数栈不是通过索引来访问,而是通过标准的压栈和出栈访问
* 在上下文明确,不会产生误解的前提下,经常把当前栈帧的操作数栈直接简称为操作数栈
* 操作数栈所属的栈帧在刚刚被创建的时候,操作数栈是空的. Java虚拟机提供一些字节码指令来从局部变量表或者对象实例的字段中复制常量或变量值到操作数栈中,也提供了一些指令用于从操作数栈取走数据,操作数据和把操作结果重新入栈.在方法调用的时候,操作数栈也用来准备调用方法的参数以及接收方法返回结果
* 如iadd字节码指令的作用是将两个 int 类型的数值相加,它要求在执行的之前操作数栈的栈顶已经存在两个由前面其他指令放入的 int 型数值.在 iadd 指令执行时,2个 int 值从操作栈中出栈,相加求和,然后将求和结果重新入栈.在操作数栈中,一项运算常由多个子运算(Subcomputations)嵌套进行,一个子运算过程的结果可以被其他外围运算所使用
* 操作数栈会对压入其中的byte,short,char类型先转换为int,之后再进行操作
* 每一个操作数栈的成员(Entry)可以保存一个Java虚拟机中定义的任意数据类型的值,包括 long 和 double 类型
* 在操作数栈中的数据必须被正确地操作,这里正确操作是指对操作数栈的操作必须与操作数栈栈顶的数据类型相匹配,例如不可以入栈两个 int 类型的数据,然后当作 long 类型去操作他们,或者入栈两个 float 类型的数据,然后使用 iadd 指令去对它们进行求和.有一小部分 Java 虚拟机指令(如dup和swap)可以不关注操作数的具体数据类型,把所有在运行时数据区中的数据当作裸类型(Raw Type)数据来操作,这些指令不可以用来修改数据,也不可以拆散那些原本不可拆分的数据,这些操作的正确性将会通过 Class 文件的校验过程来强制保障
* 在任意时刻,操作数栈都会有一个确定的栈深度,一个 long 或者 double 类型的数据会占用两个单位的栈深度,其他数据类型则会占用一个单位深度



## 动态连接



## 方法返回地址



## 附加信息



* 虚拟机规范中允许具体的虚拟机实现增加一些规范里没有描述的信息到栈帧中,这部分信息完全取决于虚拟机的实现