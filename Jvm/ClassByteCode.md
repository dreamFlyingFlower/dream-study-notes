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
* 

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



* <clinit>():如果对象中有静态成员变量,静态代码块时才会调用该构造方法
* <init>():调用对象的初始化方法(构造函数)
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
* 位移指令:ishl(左移),ishr(右移),iushr(无符号右移),lshl,lshr,lushr
* 按位或指令:ior,lor
* 按位与指令:iand,land
* 按位异或指令:ixor,lxor
* 自增指令:iinc,`i++和++i`在字节码指令上是一样的
* 比较指令:dcmpg,dcmpl,fcmpg,fcmpl,lcmp
  * 对于double和float类型,由于NaN的存在,各有两个版本的比较指令,它们的区别在于在数字比较时,遇到NaN的处理结果不同
  * fcmpg遇到NaN返回1,fcmgl遇到NaN返回-1.指令dcmpl和dcmpg也是类似的
  * `0.0/0.0`会出现NaN
  * 指令lcmp针对long型整数,由于long型整数没有NaN值,故无需准备两套指令




# 类型转换指令



* 类型转换指令可以将两种不同的数值类型进行相互转换,这些转换操作一般用于实现用户代码中的显示类型转换以及处理字节码指令集中数据类型相关指令无法与数据类型一一对应的问题
* 宽化类型处理和窄化类型处理:类似子类转父类和父类转子类,int转long,long转int
* 从int到long,float,double: i2l,i2f,i2d
* 从long到float,double: l2f,l2d
* 从fload到double: f2d
* 从int到byte,short,char: i2b,i2s,i2c
* 从long到int: l2i
* 从long到float,double: l2f,l2d
* 从float到int,long: f2i,f2l
* 从double到int,long,float: d2i,d2l,d2f
* 没有直接转的,可以由多次转达成:如double转byte,先转int,再从int转byte
* 当将一个浮点值窄化转换为整数类型int或long时,将遵循以下转换规则:
  * 如果浮点值是NaN,那转换结果就是int或long类型的0
  * 如果浮点值不是无穷大的话,浮点值使用IEEE 754的向零舍入模式取整,获得整数值V,如果V在目标类型T(int或long)的表示范围之内,那转换结果就是V.否则,将根据V的符号,转换为T所能表示的最大或者最小正数

* 当将一个 double 转换为 float 时,将遵循以下转换规则:通过向最接近数舍入模式舍入一个可以使用float表示的数字,最后结果根据情况判断:
  * 如果转换结果的绝对值太小而无法使用 float来表示,将返回 float类型的正负零
  * 如果转换结果的绝对值太大而无法使用 float来表示,将返回 float类型的正负无穷大
  * 对于double 类型的 NaN值将按规定转换为 float类型的 NaN值




# 对象创建与访问指令



* new:创建普通类实例的指令,接收一个操作数,为指向常量池的索引,表示要创建的类型.执行完后,将对象引入压入栈顶
* newarray:基本类型数组创建
* anewarray:引用类型数组创建
* multianewarray:多维引用数组创建
* getfield:获取字段的值
* putfield:设置字段的值,从操作数栈中弹出
* getstatic:获取静态字段的值
* putstatic:设置静态字段的值
* 把数组元素加载到操作数栈的指令:baload(byte和boolean),caload,saload,iaload,laload,faload,daload,aaload(引用)
  * xaload在执行时,要求操作数栈栈顶元素为数组索引i,栈顶顺位第2个元素为数组引用a,该指令会弹出栈顶这两个元素,并将a[i]重新压入栈

* 将操作数栈的值存储到数组元素(操作堆,而不是局部变量表):bastore,castore,satore,iastore,lastore,fastore,dastore,aastore
  * 在xastore执行前,操作数栈顶需要以此准备3个元素: 值,索引,数组引用,xastore会弹出这3个值,并将值赋给数组中指定索引的位置

* 取数组长度的指令:arraylength,弹出栈顶数组元素,获取数组长度,将长度压入栈顶
* 检查实例类型的指令:
  * instanceof: 同Java关键字instanceof,会将判断结果压入栈顶
  * checkcast: 强转.如果可以强转,不会改变操作数栈,否则抛异常




# 操作数栈管理指令



* 操作数栈指令用于直接操作操作数栈
* pop,pop2:将操作数栈的一个或两个元素出栈,这里的1个或2个是指32位的Slot(槽),Slot是栈帧的基本单位,一个Slot占32字节
* dup,dup2,dup_x1,dup_x2,dup2_x1,dup2_x2:复制栈顶一个或两个数值并将复制或双份值重新压入栈顶
  * 不带_x的指令是复制栈顶数据并压入栈顶.dup2代表要复制的Slot个数
  * 带_x的指令是复制栈顶数据并插入栈顶以下的某个位置.如`dup2_x1`插入到栈顶3个Slot下面

* swap:将栈顶的两个数值交换位置
* nop:什么都不做,主要用来调试,占位



# 控制转移指令



* 控制转移指令可以让JVM有条件或无条件的从指定位置指令执行而不是顺序的从下一条指令继续执行程序,即控制转移指令就是在修改PC寄存器的值
* 条件分支,这些指令接收两个字节的操作数用于计算跳转的位置:
  * ifeq/ifne:如果栈顶元素为0/不为0,则跳转
  * iflt/ifle:小于0/小于等于0,则跳转
  * ifgt/ifge:大于0/大于de等于0,则跳转
  * ifnull/ifnonnull:为null/不为null,则跳转
  * if_icmpeq/if_icmpne:栈顶2个int相同/不同,则跳转
  * if_icmplt/if_icmple:栈顶前1个int小于/小于等于后一个int,则跳转
  * if_icmpgt/if_icmpge:栈顶前1个int大于/大于等于后一个int,则跳转
  * if_acmpeq/if_acmpne:栈顶2个引用类型相同/不同,则跳转
* 复合条件(多条件)分支:tableswitch,lookupswitch.2者的区别在于tableswitch的值连续,效率较高
* 无条件分支:goto,goto_w.goto接收2个字节的的操作数,goto_w接收4个字节的操作数
* 无条件分支:jsr,jsr_w,ret,主要用于try-finally,且已逐渐被废弃
* boolean,byte,char,short的条件分支比较操作都使用int比较指令来完成,而对于long,float,double类型的条件分支比较操作,则会先执行相应类型的比较运算指令,运算指令会返回一个整形值到操作数栈中,随后再执行int类型的条件分支比较操作来完成整个分支跳转
* 所有int类型的条件分支转移指令进行的都是有符号的比较操作



# 方法调用和返回指令



* invokevirtual:用于调用对象的实例方法,根据对象的实际类型进行分派(虚方法分派),这也是Java语言中最常见的方法分派方式
* invokeinterface:用于调用接口方法,它会在运行时搜索一个实现了这个接口方法的对象,找出适合的方法进行调用
* invokespecial:用于调用一些需要特殊处理的实例方法,包括实例初始化方法,私有方法和父类方法.通常根据引用的类型选择方法,而不是对象的类来选择,即它使用静态绑定而不是动态绑定
* invokestatic:用于调用类方法(static方法),这些方法也是静态绑定的
* invokedynamic:调用动态链接方法,用于在运行时动态解析出调用点限定符锁引用的方法并执行
* 方法返回指令是根据返回值的类型区分的,包括有ireturn(当返回值是boolean,byte,char,short,int时使用),lreturn,freturn,dreturn,areturn.return供声明为void的方法,实例初始化方法,类和接口的类初始化方法使用
  * 方法返回时会将栈顶元素弹出并将该元素压入调用者方法的操作数栈中,所有在当前操作数栈中的元素都会被丢弃
  * 如果当前返回的是synchronized方法,还会执行一个隐含的monitorexit执行,退出临界区
  * 最后会丢弃当前方法的整个帧,恢复调用者的帧,并将控制权转交给调用者



# 比较控制指令



# 异常指令



* 在程序中显式抛出异常的操作会由athrow指令实现,除了这种情况,还有别的异常会在Java虚拟机指令检测到异常状况时由虚拟机自动抛出
* 如果程序抛出的异常被主动捕获,会使用异常表处理
* 正常情况下,操作数栈的压入弹出都是一条条指令完成的,唯一的例外情况是在抛异常时,Java 虚拟机会清除操作数栈上的所有内容,而后将异常实例压入调用者操作数栈上
* 当一个异常被抛出时,JVM会在当前的方法里寻找一个匹配的处理,如果没有找到,这个方法会强制结束并弹出当前栈帧,并且异常会重新抛给上层调用的方法(在调用方法栈帧).如果在所有栈帧弹出前仍然没有找到合适的异常处理,这个线程将终止.如果这个异常在最后一个非守护线程里抛出,将会导致JVM自己终止,比如这个线程是个main线程
* 不管什么时候抛出异常,如果异常处理最终匹配了所有异常类型,代码就会继续执行.在这种情况下,如果方法结束后没有抛出异常,仍然执行finally块,在return前,它直接跳到finally块来完成目标



## 异常表



* 如果方法定义了try-catch 或者try-finally的,就会创建一个异常表,它包含了每个异常处理或者finally块的信息.异常表保存了每个异常处理信息:
  * 起始位置
  * 结束位置
  * 程序计数器记录的代码处理的偏移地址
  * 被捕获的异常类在常量池甫的索引
* finally在字节码中会复制2份,如果抛出异常会走异常的一部分;如果有return,则finally中的字节码会复制一份到return之前,见17.案例2



# 同步控制指令



* Java虚拟机可以支持方法级的同步和方法内部一段指令序列的同步,这两种同步结构都是使用管程(Monitor)来支持的
* 方法级的同步是隐式的,无需通过字节码指令来控制的,虚拟机从常量池的方法表结构(method_info)中的ACC_SYNCHRONIZED访问标志区分方法是否同步
  * 当方法调用时,调用指令将会检查方法的ACC_SYNCHRONIZED访问标志是否被设置,如果设置了,执行线程将先持有管程,然后再执行方法,最后方法完成(无论是正常完成还是非正常完成)时释放管程
  * 在方法执行期间,执行线程持有了管程,其他任何线程都无法再获得同一个管程
  * 如果一个同步方法执行期间抛出了异常,并且在方法内部无法处理此异常,那这个同步方法所持有的管程将在异常抛到同步方法之外时自动释放
* monitorenter,monitorexit:JVM指令集使用上述两条指令来支持synchronized标识的同步代码块
  * 当一个线程进入同步代码块时,它使用monitorenter指令请求进入.如果当前对象的监视器计数器为0,则它会被准许进入;若为1,则判断持有当前监视器的线程是否为自己,如果是,则进入,否则进行等待,直到对象的监视器计数器为0,才会被允许进入同步块
  * 当线程退出同步块时,需要使用monitorexit声明退出.在Java虚拟机中,任何对象都有一个监视器与之相关联,用来判对象是否被锁定,当监视器被持有后,对象处于锁定状态
  * monitorenter和monitorexit在执行时,都需要在操作数栈顶压入对象,之后monitorenter和monitorexit的锁定和释放都是针对这个对象的监视器进行的

* 结构化锁定(Structured Locking)是指在方法调用期间每一个管程退出都与前面的管程进入相匹配的情形.因为无法保证所有提交给Java虚拟机执行的代码都满足结构化锁定,所以Java虚拟机允许(但不强制要求)通过以下两条规则来保证结构化锁定成立.假设T代表一条线程,M代表一个管程:
  * T在方法执行时持有管程M的次数必须与T在方法完成(正常和非正常完成)时释放管程M的次数相等
  * 在方法调用过程中,任何时刻都不会出现线程T释放管程M的次数比T持有管程M次数多的情况
  * 在同步方法调用时自动持有和释放管程的过程也被认为是在方法调用期间发生



# ASM



* Java字节码操作框架,可以用于修改现有类或者动态产生新类.如AspectJ,Clojure,spring,cglib

```java
ClassWriter cw = new ClassWriter(ClassWriter.COMPUTE_MAXS|ClassWriter.COMPUTE_FRAMES);  
cw.visit(V1_7, ACC_PUBLIC, "Example", null, "java/lang/Object", null);  
MethodVisitor mw = cw.visitMethod(ACC_PUBLIC, "<init>", "()V", null,  null);  
mw.visitVarInsn(ALOAD, 0);  //this 入栈
mw.visitMethodInsn(INVOKESPECIAL, "java/lang/Object", "<init>", "()V");  
mw.visitInsn(RETURN);  
mw.visitMaxs(0, 0);  
mw.visitEnd();  
mw = cw.visitMethod(ACC_PUBLIC + ACC_STATIC, "main",  "([Ljava/lang/String;)V", null, null);  
mw.visitFieldInsn(GETSTATIC, "java/lang/System", "out",  "Ljava/io/PrintStream;");  
mw.visitLdcInsn("Hello world!");  
mw.visitMethodInsn(INVOKEVIRTUAL, "java/io/PrintStream", "println",  "(Ljava/lang/String;)V");  
mw.visitInsn(RETURN);  
mw.visitMaxs(0,0);  
mw.visitEnd();  
byte[] code = cw.toByteArray();  
AsmHelloWorld loader = new AsmHelloWorld();  
Class exampleClass = loader  
    .defineClass("Example", code, 0, code.length);  
exampleClass.getMethods()[0].invoke(null, new Object[] { null }); 
```



## 模型AOP



在函数开始部分或者结束部分嵌入字节码,可用于进行鉴权、日志等

```java
// 在操作前加上鉴权或日志
public class Account { 
    public void operation() { 
        System.out.println("operation...."); 
    } 
}
// 需要加入的内容
public class SecurityChecker { 
    public static boolean checkSecurity() { 
        System.out.println("SecurityChecker.checkSecurity ...");
        return true;
    } 
}
```

```java
class AddSecurityCheckClassAdapter extends ClassVisitor {
    public AddSecurityCheckClassAdapter( ClassVisitor cv) {
        super(Opcodes.ASM5, cv);
    }
    // 重写 visitMethod,访问到operation方法时,给出自定义MethodVisitor,实际改写方法内容
    public MethodVisitor visitMethod(final int access, final String name, 
                                     final String desc, final String signature, final String[] exceptions) { 
        MethodVisitor mv = cv.visitMethod(access, name, desc, signature,exceptions);
        MethodVisitor wrappedMv = mv; 
        if (mv != null) { 
            // 对于operation方法
            if (name.equals("operation")) { 
                // 使用自定义 MethodVisitor,实际改写方法内容
                wrappedMv = new AddSecurityCheckMethodAdapter(mv); 
            } 
        } 
        return wrappedMv; 
    } 
}
class AddSecurityCheckMethodAdapter extends MethodVisitor { 
    public AddSecurityCheckMethodAdapter(MethodVisitor mv) { 
        super(Opcodes.ASM5,mv); 
    } 
    public void visitCode() { 
        visitMethodInsn(Opcodes.INVOKESTATIC, "geym/jvm/ch10/asm/SecurityChecker", 
                        "checkSecurity", "()Z"); 
        super.visitCode();
    } 
}
public class Generator{ 
    public static void main(String args[]) throws Exception { 
        ClassReader cr = new ClassReader("geym.jvm.ch10.asm.Account"); 
        ClassWriter cw = new ClassWriter(ClassWriter.COMPUTE_MAXS|ClassWriter.COMPUTE_FRAMES); 
        AddSecurityCheckClassAdapter classAdapter = new AddSecurityCheckClassAdapter(cw); 
        cr.accept(classAdapter, ClassReader.SKIP_DEBUG); 
        byte[] data = cw.toByteArray(); 
        File file = new File("bin/geym/jvm/ch10/asm/Account.class"); 
        FileOutputStream fout = new FileOutputStream(file); 
        fout.write(data); 
        fout.close(); 
    } 
}
```



# ++i和i++



```java
public static void test2() {
    int a = 10;
    int b = a++;

    int c = 20;
    int d = ++c;

    System.out.println(b + d);
}
```



```
public static void test2();
    ....
      stack=3, locals=4, args_size=0
         0: bipush        10
         2: istore_0
         3: iload_0								   // 先将a的值10取出来压入栈顶
         4: iinc          0, 1						// 直接将局部变量表中的a进行自增,但是栈顶的值并没有自增,仍然是10
         7: istore_1							  // 将栈顶的10赋值给b
         8: bipush        20
        10: istore_2
        11: iinc          2, 1						// 直接将c的值进行自增,此时栈顶没有值
        14: iload_2								  // 将c的值取出压入栈顶
        15: istore_3							 // 将栈顶的21赋值给d
        16: getstatic     #16                 // Field java/lang/System.out:Ljava/io/PrintStream;
        19: iload_1
        20: iload_3
        21: iadd
        22: invokevirtual #22                 // Method java/io/PrintStream.println:(I)V
        25: return
      ....
      LocalVariableTable:
        Start  Length  Slot  Name   Signature
            3      23     0     a   I
            8      18     1     b   I
           11      15     2     c   I
           16      10     3     d   I
```



* 在字节码中编译后是相同的,没有区别,都是`iinc i, 1`,i为局部变量表中变量索引
* i++:先iload,将值加载到操作数栈顶,但是不做其他操作,之后i++会直接在局部变量表中将i自增1;之后栈顶的10赋值给b
* ++i:先自增,赋值给c,然后再iload其中c的值到栈顶,之后再istore给d



# 案例1



```java
// 在字节码层面就是先load还是先自增:i++先load,++i先自增
public void test(){
    int i = 10;
    int j = i++;
    
    int m = 20;
    int n = ++m;
}
```



```java
0 bipush 10			 // 从常量池加载常量10,压入栈顶
2 istore_1			// 将10赋值给局部变量表索引为1的变量,即将10赋值给i
3 iload_1			// 从局部变量表中将索引为1的变量压入栈顶,即将10取出压入栈顶
4 iinc 1 by 1		    // 将局部变量表索引为1的变量自增1,即将10自增1,i变为11;栈顶的10不变,弹出
7 istore_2			// 将栈顶弹出的10赋值给局部变量表索引为2的变量,即j赋值为10

8 bipush 20			// 从常量池加载常量20,压入栈顶
10 istore_3			// 将栈顶的20赋值给局部变量表索引为3的变量,即将m赋值为20
11 iinr 3 by 1		    // 将局部变量表中索引为3的变量自增1,即将20自增为21,m变为21
14 iload_3			// 将局部变量表索引为3的值压入栈顶,即将21压入栈顶
15 istore 4			 // 将栈顶的21弹出,赋值给布局变量表索引为4的变量,即n赋值为21
17 return
```



# 案例2



```java
public static String test(){
    String sss = "heiheihei";
    try{
        return sss;
    }finally{
        sss="lalala";
    }
}
```



```java
// 异常表
start pc				end pc					handler pc					catchType
3							5							10								cp_info #0
																							any
```



```java
0 ldc #17 <sss>
2 astore_0
3 aload_0						 // 将sss从局部变量表取出,此时为heiheihei压入栈顶
4 astore_1						// 将heiheihei再存储到局部变量表索引为1的位置
5 ldc #18 <lalala>			  // 从常量池取出lalala压入栈顶
7 astore_0					   // 将lalala存储到局部变量表0的位置,覆盖掉原来的heiheihei
8 aload_1						// 取出局部变量表索引为1的值,此时为heiheihei
9 areturn						// 返回heiheihei
10 astore_2					  // 从异常表中可得:当3到5的程序发生异常,即try中的代码发生异常时,直接跳到10.将异常类型存入局部变量表索引为2的位置
11 ldc #18 <lalala>
13 astore_0
14 aload_2					   // 抛出异常
15 athrow
```



# 案例3



```java
public class User {
    private int id;
    private String name;
    private int age;
    public int getId() {
        return id;
    }
    public void setId(int id) {
        this.id = id;
    }
    public String getName() {
        return name;
    }
    public void setName(String name) {
        this.name = name;
    }
    public int getAge() {
        return age;
    }
    public void setAge(int age) {
        this.age = age;
    }
}
```

16进制文件

![](F:/repository/dream-study-notes/Jvm/img/007.png)



![](F:/repository/dream-study-notes/Jvm/img/008.png)



![](F:/repository/dream-study-notes/Jvm/img/009.png)



![](F:/repository/dream-study-notes/Jvm/img/010.png)





# 案例4



```java
public class MyClass {

	private int a = 5;

	private int ttt;

	private String b = "test";

	private float c = 5.5f;

	private double d = 55.6;

	private int[] aa = new int[7];

	private String[] bb = new String[5];

	private Object obj = new Object();

	private Object[] objs = new Object[5];
    
    public int add(int a, int b) {
        int c = a + b;
        return 1 + 1;
	}
}
```

使用javap -c 反编译该类的class文件,如下

```java
Compiled from "MyClass.java"
public class com.wy.jvm.MyClass {
  public com.wy.jvm.MyClass();
    Code:
       0: aload_0
       1: invokespecial #25                 // Method java/lang/Object."<init>":()V
       4: aload_0
       5: iconst_5
       6: putfield      #27                 // Field a:I
       9: aload_0
      10: ldc           #29                 // String test
      12: putfield      #31                 // Field b:Ljava/lang/String;
      15: aload_0
      16: ldc           #33                 // float 5.5f
      18: putfield      #34                 // Field c:F
      21: aload_0
      22: ldc2_w        #36                 // double 55.6d
      25: putfield      #38                 // Field d:D
      28: aload_0
      29: bipush        7
      31: newarray       int
      33: putfield      #40                 // Field aa:[I
      36: aload_0
      37: iconst_5
      38: anewarray     #42                 // class java/lang/String
      41: putfield      #44                 // Field bb:[Ljava/lang/String;
      44: aload_0
      45: new           #3                  // class java/lang/Object
      48: dup
      49: invokespecial #25                 // Method java/lang/Object."<init>":()V
      52: putfield      #46                 // Field obj:Ljava/lang/Object;
      55: aload_0
      56: iconst_5
      57: anewarray     #3                  // class java/lang/Object
      60: putfield      #48                 // Field objs:[Ljava/lang/Object;
      63: return

  public int add(int, int);
    Code:
       0: iload_1
       1: iload_2
       2: iadd
       3: istore_3
       4: iconst_2
       5: ireturn
}
```

使用javap -v反编译该类的class文件如下

```java
Classfile MyClass.class
  Last modified 2021-9-11; size 853 bytes
  MD5 checksum e4223d95d677282f40148c88c42eb20e
  Compiled from "MyClass.java"
public class com.wy.jvm.MyClass
  minor version: 0
  major version: 52
  flags: ACC_PUBLIC, ACC_SUPER
Constant pool:
   #1 = Class              #2             // com/wy/jvm/MyClass
   #2 = Utf8               com/wy/jvm/MyClass
   #3 = Class              #4             // java/lang/Object
   #4 = Utf8               java/lang/Object
   #5 = Utf8               a
   #6 = Utf8               I
   #7 = Utf8               ttt
   #8 = Utf8               b
   #9 = Utf8               Ljava/lang/String;
  #10 = Utf8               c
  #11 = Utf8               F
  #12 = Utf8               d
  #13 = Utf8               D
  #14 = Utf8               aa
  #15 = Utf8               [I
  #16 = Utf8               bb
  #17 = Utf8               [Ljava/lang/String;
  #18 = Utf8               obj
  #19 = Utf8               Ljava/lang/Object;
  #20 = Utf8               objs
  #21 = Utf8               [Ljava/lang/Object;
  #22 = Utf8               <init>
  #23 = Utf8               ()V
  #24 = Utf8               Code
  #25 = Methodref          #3.#26         // java/lang/Object."<init>":()V
  #26 = NameAndType        #22:#23        // "<init>":()V
  #27 = Fieldref           #1.#28         // com/wy/jvm/MyClass.a:I
  #28 = NameAndType        #5:#6          // a:I
  #29 = String             #30            // test
  #30 = Utf8               test
  #31 = Fieldref           #1.#32         // com/wy/jvm/MyClass.b:Ljava/lang/String;
  #32 = NameAndType        #8:#9          // b:Ljava/lang/String;
  #33 = Float              5.5f
  #34 = Fieldref           #1.#35         // com/wy/jvm/MyClass.c:F
  #35 = NameAndType        #10:#11        // c:F
  #36 = Double             55.6d
  #38 = Fieldref           #1.#39         // com/wy/jvm/MyClass.d:D
  #39 = NameAndType        #12:#13        // d:D
  #40 = Fieldref           #1.#41         // com/wy/jvm/MyClass.aa:[I
  #41 = NameAndType        #14:#15        // aa:[I
  #42 = Class              #43            // java/lang/String
  #43 = Utf8               java/lang/String
  #44 = Fieldref           #1.#45         // com/wy/jvm/MyClass.bb:[Ljava/lang/String;
  #45 = NameAndType        #16:#17        // bb:[Ljava/lang/String;
  #46 = Fieldref           #1.#47         // com/wy/jvm/MyClass.obj:Ljava/lang/Object;
  #47 = NameAndType        #18:#19        // obj:Ljava/lang/Object;
  #48 = Fieldref           #1.#49         // com/wy/jvm/MyClass.objs:[Ljava/lang/Object;
  #49 = NameAndType        #20:#21        // objs:[Ljava/lang/Object;
  #50 = Utf8               LineNumberTable
  #51 = Utf8               LocalVariableTable
  #52 = Utf8               this
  #53 = Utf8               Lcom/wy/jvm/MyClass;
  #54 = Utf8               add
  #55 = Utf8               (II)I
  #56 = Utf8               MethodParameters
  #57 = Utf8               SourceFile
  #58 = Utf8               MyClass.java
{
  public com.wy.jvm.MyClass();
    descriptor: ()V
    flags: ACC_PUBLIC
    Code:
      stack=3, locals=1, args_size=1
         0: aload_0
         1: invokespecial #25                 // Method java/lang/Object."<init>":()V
         4: aload_0
         5: iconst_5
         6: putfield      #27                 // Field a:I
         9: aload_0
        10: ldc           #29                 // String test
        12: putfield      #31                 // Field b:Ljava/lang/String;
        15: aload_0
        16: ldc           #33                 // float 5.5f
        18: putfield      #34                 // Field c:F
        21: aload_0
        22: ldc2_w        #36                 // double 55.6d
        25: putfield      #38                 // Field d:D
        28: aload_0
        29: bipush        7
        31: newarray       int
        33: putfield      #40                 // Field aa:[I
        36: aload_0
        37: iconst_5
        38: anewarray     #42                 // class java/lang/String
        41: putfield      #44                 // Field bb:[Ljava/lang/String;
        44: aload_0
        45: new           #3                  // class java/lang/Object
        48: dup
        49: invokespecial #25                 // Method java/lang/Object."<init>":()V
        52: putfield      #46                 // Field obj:Ljava/lang/Object;
        55: aload_0
        56: iconst_5
        57: anewarray     #3                  // class java/lang/Object
        60: putfield      #48                 // Field objs:[Ljava/lang/Object;
        63: return
      LineNumberTable:
        line 10: 0
        line 12: 4
        line 16: 9
        line 18: 15
        line 20: 21
        line 22: 28
        line 24: 36
        line 26: 44
        line 28: 55
        line 10: 63
      LocalVariableTable:
        Start  Length  Slot  Name   Signature
            0      64     0  this   Lcom/wy/jvm/MyClass;

  public int add(int, int);
    descriptor: (II)I
    flags: ACC_PUBLIC
    Code:
      stack=2, locals=4, args_size=3
         0: iload_1
         1: iload_2
         2: iadd
         3: istore_3
         4: iconst_2
         5: ireturn
      LineNumberTable:
        line 31: 0
        line 32: 4
      LocalVariableTable:
        Start  Length  Slot  Name   Signature
            0       6     0  this   Lcom/wy/jvm/MyClass;
            0       6     1     a   I
            0       6     2     b   I
            4       2     3     c   I
    MethodParameters:
      Name                           Flags
      a
      b
}
SourceFile: "MyClass.java"
```

* 0: aload_0,加载默认构造函数
* 1: invokespecial,执行特殊方法,次数表示执行构造函数.()表示空构造,V表示Void,无返回值
* 4: aload_0:表示加载a字段
* 5: iconst_5,i表示上一步加载的字段类型为int,初始化为5.如果没有初始化,则没有该行,如ttt字段
* 6: putfield,将字段加入到字节码中,最后的注释表明了该字段的类型
  * Field表示是字段,a表示变量名,I表示int类型
* add方法
  * 0: iload_1:从局部变量表中加载第一个int类型的参数到操作数栈中.该方法的args_size=3,但实际参数个数要比该值少1,其实是默认加载了this,所有的非静态方法都是如此,构造方法也一样
  * 1: iload_2:同iload_1,只不过加载的是第2个参数,以此类推
  * 2: iadd:进行int类型的加法运算
  * 3: istore_3:将操作数栈中的值存储到局部变量表
  * 4: iconst_2:由编译器进行优化,直接在编译时期就返回常量



# 案例5



```java
public class MyClass {

	public static int add(int a, int b) {
		int hour = 24;
		long m1 = hour * 60 * 60 * 1000;
		long m2 = hour * 60 * 60 * 1000 * 1000;
		// 结果是500654080
		// 在内存中计算时由于都是int类型,计算的结果也是int类型,但超出了int类型的最大值
		// 根据2进制int类型的长度,只会获得最终bit位的后32位,前面超出的舍弃,最后获得是500654080,得出的结果才会转换为long
		// 可以使用javap -verbose 该类的字节码文件,查看运行指令
		System.out.println((int) m2);
		// 5
		System.out.println(m2 / m1);
		return 1 + 1;
	}

	public static void main(String[] args) {
		add(1, 2);
	}
}
```

java -verbose MyClass.class

```java
Classfile MyClass.class
  Last modified 2021-9-11; size 800 bytes
  MD5 checksum 6caf640ba85fb6b564360472712d45c0
  Compiled from "MyClass.java"
public class com.wy.jvm.MyClass
  minor version: 0
  major version: 52
  flags: ACC_PUBLIC, ACC_SUPER
Constant pool:
   #1 = Class              #2             // com/wy/jvm/MyClass
   #2 = Utf8               com/wy/jvm/MyClass
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
  #13 = Utf8               Lcom/wy/jvm/MyClass;
  #14 = Utf8               add
  #15 = Utf8               (II)I
  #16 = Fieldref           #17.#19        // java/lang/System.out:Ljava/io/PrintStream;
  #17 = Class              #18            // java/lang/System
  #18 = Utf8               java/lang/System
  #19 = NameAndType        #20:#21        // out:Ljava/io/PrintStream;
  #20 = Utf8               out
  #21 = Utf8               Ljava/io/PrintStream;
  #22 = Methodref          #23.#25        // java/io/PrintStream.println:(I)V
  #23 = Class              #24            // java/io/PrintStream
  #24 = Utf8               java/io/PrintStream
  #25 = NameAndType        #26:#27        // println:(I)V
  #26 = Utf8               println
  #27 = Utf8               (I)V
  #28 = Methodref          #23.#29        // java/io/PrintStream.println:(J)V
  #29 = NameAndType        #26:#30        // println:(J)V
  #30 = Utf8               (J)V
  #31 = Utf8               a
  #32 = Utf8               I
  #33 = Utf8               b
  #34 = Utf8               hour
  #35 = Utf8               m1
  #36 = Utf8               J
  #37 = Utf8               m2
  #38 = Utf8               MethodParameters
  #39 = Utf8               main
  #40 = Utf8               ([Ljava/lang/String;)V
  #41 = Methodref          #1.#42         // com/wy/jvm/MyClass.add:(II)I
  #42 = NameAndType        #14:#15        // add:(II)I
  #43 = Utf8               args
  #44 = Utf8               [Ljava/lang/String;
  #45 = Utf8               SourceFile
  #46 = Utf8               MyClass.java
{
  public com.wy.jvm.MyClass();
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
            0       5     0  this   Lcom/wy/jvm/MyClass;

  public static int add(int, int);
    descriptor: (II)I
    flags: ACC_PUBLIC, ACC_STATIC
    Code:
      stack=5, locals=7, args_size=2
         0: bipush        24
         2: istore_2
         3: iload_2
         4: bipush        60
         6: imul
         7: bipush        60
         9: imul
        10: sipush        1000
        13: imul
        14: i2l
        15: lstore_3
        16: iload_2
        17: bipush        60
        19: imul
        20: bipush        60
        22: imul
        23: sipush        1000
        26: imul
        27: sipush        1000
        30: imul
        31: i2l
        32: lstore        5
        34: getstatic     #16                 // Field java/lang/System.out:Ljava/io/PrintStream;
        37: lload         5
        39: l2i
        40: invokevirtual #22                 // Method java/io/PrintStream.println:(I)V
        43: getstatic     #16                 // Field java/lang/System.out:Ljava/io/PrintStream;
        46: lload         5
        48: lload_3
        49: ldiv
        50: invokevirtual #28                 // Method java/io/PrintStream.println:(J)V
        53: iconst_2
        54: ireturn
      LineNumberTable:
        line 13: 0
        line 14: 3
        line 15: 16
        line 20: 34
        line 22: 43
        line 23: 53
      LocalVariableTable:
        Start  Length  Slot  Name   Signature
            0      55     0     a   I
            0      55     1     b   I
            3      52     2  hour   I
           16      39     3    m1   J
           34      21     5    m2   J
    MethodParameters:
      Name                           Flags
      a
      b

  public static void main(java.lang.String[]);
    descriptor: ([Ljava/lang/String;)V
    flags: ACC_PUBLIC, ACC_STATIC
    Code:
      stack=2, locals=1, args_size=1
         0: iconst_1
         1: iconst_2
         2: invokestatic  #41                 // Method add:(II)I
         5: pop
         6: return
      LineNumberTable:
        line 27: 0
        line 28: 6
      LocalVariableTable:
        Start  Length  Slot  Name   Signature
            0       7     0  args   [Ljava/lang/String;
    MethodParameters:
      Name                           Flags
      args
}
SourceFile: "MyClass.java"
```

* 从字节码指令集中可以看出,运行时一直都是int类型,到最后得到结果才从int转换为long,这导致最终的结果与预期的不符



# 案例6



```java
public class Demo01{
	static{
		i = 0; // 编译通过
		System.out.println(i); // 编译不通过
	}
	staitc int i = 1;
}
```

* 该代码变量的赋值语句可以通过编译,而下面的输出却不能
* <clinit>()方法是由编译器自动收集类中所有类变量的赋值动作和静态语句块中的语句合并产生的,并在类加载的初始化时调用
* 编译器收集变量的顺序是由语句在源文件中出现的顺序决定的,**静态语句块中只能访问定义在静态语句块之前的变量,定义在它之后的变量,在前面的语句中可以赋值,但是不能访问**



# 案例7



```java
public class Calc {
    public int calc() {
        int a = 500;
        int b = 200;
        int c = 50;
        return (a + b) / c;
    }
}
```

```java
public int calc();
  Code:
   Stack=2, Locals=4, Args_size=1
   0:   sipush  500
   3:   istore_1
   4:   sipush  200
   7:   istore_2
   8:   bipush  50
   10:  istore_3
   11:  iload_1
   12:  iload_2
   13:  iadd
   14:  iload_3
   15:  idiv
   16:  ireturn
}
```

简单的执行过程

* sipush:500入栈

![](F:/repository/dream-study-notes/Jvm/img/012.png)



![](F:/repository/dream-study-notes/Jvm/img/013.png)



![](F:/repository/dream-study-notes/Jvm/img/014.png)



* iload_1:第一个局部变量压栈



![](F:/repository/dream-study-notes/Jvm/img/015.png)



* iadd:2个数出栈,相加,和入栈



![](F:/repository/dream-study-notes/Jvm/img/016.png)



* idiv:2元素出栈,结果入栈;ireturn:将栈顶的整数结果返回



![](F:/repository/dream-study-notes/Jvm/img/017.png)



* 简单的字节码执行过程



![](F:/repository/dream-study-notes/Jvm/img/018.png)



* 字节码指令为一个byte整数

```java
_nop                  =   0, // 0x00
_aconst_null          =   1, // 0x01
_iconst_0             =   3, // 0x03
_iconst_1             =   4, // 0x04
_dconst_1             =  15, // 0x0f
_bipush               =  16, // 0x10
_iload_0              =  26, // 0x1a
_iload_1              =  27, // 0x1b
_aload_0              =  42, // 0x2a
_istore               =  54, // 0x36
_pop                  =  87, // 0x57
_imul                 = 104, // 0x68
_idiv                 = 108, // 0x6c
```

* `void setAge(int)`的字节码
  * 2A 1B B5 00 20 B1
  * 2A _aload_0
    * 无参
    * 将局部变量slot0 作为引用 压入操作数栈
  * 1B _iload_1
    * 无参
    * 将局部变量slot1 作为整数 压入操作数栈
  * B5 _putfield
    * 设置对象中字段的值
    * 参数为2bytes (00 20) (指明了字段)
      * 指向常量池的引用
      * Constant_Fieldref
      * 此处为User.age
    * 弹出栈中2个对象:objectref, value
    * 将栈中的value赋给objectref的给定字段
  * B1 _return



# 案例8



* javap -v:只能反编译非private的信息,需要加上-p才能编译所有的信息
