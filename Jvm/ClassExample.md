# ClassExample



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



* 在字节码中编译后是相同的,没有区别
* 在程序赋值时,++i是先自增再赋值;i++是先赋值再自增



# 实例



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





# 实例1



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



# 实例2



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



# 实例3



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



# 实例4



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



# 实例5



* javap -v:只能反编译非private的信息,需要加上-p才能编译所有的信息



# 特殊点



* Class类中的getDeclaredField()只能拿到当前类中的字段,不能拿到父类中的字段,需要递归
* Class类中的`getField()/getDeclaredField()`拿到的字段顺序是不固定的,但是长度和每个字段内容都仍然是相同的
* 类中的修饰符在编译器就已经在字节码文件中确定了,不需要等到运行期