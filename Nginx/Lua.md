# Lua



# 概述



* Lua是一种轻量、小巧的脚本语言,设计的目的是为了嵌入到其他应用程序中,从而为应用程序提供灵活的扩展和定制功能
* 轻量级.Lua用标准C语言编写并以源代码形式开发,编译后仅仅一百余千字节,可以很方便的嵌入到其他程序中
* 可扩展.Lua提供非常丰富易于使用的扩展接口和机制,由宿主语言(通常是C或C++)提供功能,Lua可以使用它们,就像内置的功能一样
* 支持面向过程编程和函数式编程



# 应用场景



* 游戏开发、独立应用脚本、web应用脚本、扩展和数据库插件、系统安全上



# 安装



* [官网](https://www.lua.org)
* 从官网下载安装包上传到服务器或直接用wget下载,解压,安装依赖: `yum install -y readline-devel`
* 编译安装: `make linux test && make install`
* 验证是否安装成功:`lua -v`



# 语法



* Lua和C/C++语法非常相似,整体上比较清晰,简洁.条件语句、循环语句、函数调用都与C/C++基本一致
* Lua有两种交互方式:交互式和脚本式



## 交互式



* 交互式是指可以在命令行输入程序,然后回车就可以看到运行的效果
* 交互式编程模式可以通过命令lua -i 或lua来启用



## 脚本式



* 脚本式是将代码保存到一个以lua为扩展名的文件中,在文件中添加要执行的代码,然后通过命令 `lua hello.lua`来执行,会在控制台输出对应的结果
* 或者类似shell脚本

```lua
#!/usr/local/bin/lua
print("Hello World!!!")
```

* 第一行用来指定Lua解释器所在位置为 /usr/local/bin/lua,加上#号标记解释器会忽略它
* 一般情况下#!就是用来指定用哪个程序来运行本文件,但是hello.lua并不是一个可执行文件,需要通过chmod来设置可执行权限
* 然后执行该文件: `./hello.lua`
* 如果想在交互式中运行脚本式的hello.lua中的内容,可以使用dofile函数,如:

```lua
dofile("lua_demo/hello.lua")
```

* 在Lua语言中,连续语句之间的分隔符并不是必须的,也就是说后面不需要加分号,加上也不会报错.表达式之间的换行也起不到任何作用



## Lua的注释



* 单行注释

```
--注释内容
```

* 多行注释

```
--[[
	注释内容
	注释内容
--]]
```

* 如果想取消多行注释,只需要在第一个--之前在加一个-即可

```
---[[
	注释内容
	注释内容
--]]
```



## 标识符



* 标识符就是变量名,Lua定义变量名以一个字母 A 到 Z 或 a 到 z 或下划线 _ 开头后加上0个或多个字母,下划线,数字
* 最好不要使用下划线加大写字母的标识符,因为Lua的保留字也是这样定义的,容易发生冲突
* Lua是区分大小写字母的



## 关键字



| and      | break | do    | else   |
| -------- | ----- | ----- | ------ |
| elseif   | end   | false | for    |
| function | if    | in    | local  |
| nil      | not   | or    | repeat |
| return   | then  | true  | until  |
| while    | goto  |       |        |



## 运算符



* Lua中支持的运算符有算术运算符、关系运算符、逻辑运算符、其他运算符

* 算术运算符:`+,-,*,/,%,^ 乘幂`
* 关系运算符:

```
==	等于
~=	不等于
>	大于
<	小于
>=	大于等于
<=	小于等于
```

* 逻辑运算符

```
and	逻辑与	 A and B     &&   
or	逻辑或	 A or B     ||
not	逻辑非  取反,如果为true,则返回false  !
```

* 逻辑运算符可以作为if的判断条件
* 其他运算符

```
..	连接两个字符串
#	一元预算法,返回字符串或表的长度
```



## 全局变量&局部变量



* 在Lua语言中,全局变量无须声明即可使用,在默认情况下,变量总是认为是全局的,如果未提前赋值,默认为nil:
* 要想声明一个局部变量,需要使用local来声明



## Lua数据类型



```
nil(空,无效值)
boolean(布尔,true/false)
number(数值)
string(字符串)
function(函数)
table（表）
thread(线程)
userdata（用户数据）
```

* 可以使用type函数测试给定变量或者的类型

```
print(type(nil))				-->nil
print(type(true))               --> boolean
print(type(1.1*1.1))             --> number
print(type("Hello world"))      --> string
print(type(io.stdin))			-->userdata
print(type(print))              --> function
print(type(type))               -->function
print(type{})					-->table
print(type(type(X)))            --> string
```



### nil



* nil是一种只有一个nil值的类型,它的作用可以用来与其他所有值进行区分,也可以当想要移除一个变量时,只需要将该变量名赋值为nil,垃圾回收就会会释放该变量所占用的内存



### boolean



* boolean类型具有两个值,true和false.在Lua语言中,只会将false和nil视为假,其他的都视为真,特别是在条件检测中0和空字符串都会认为是真



### number



* 在Lua5.3版本开始,Lua语言为数值格式提供了两种选择:integer(整型)和float(双精度浮点型)
* 数值常量的表示方式:

```
>4			-->4
>0.4		-->0.4
>4.75e-3	-->0.00475
>4.75e3		-->4750
```

* 不管是整型还是双精度浮点型,使用type()函数来取其类型,都会返回的是number,所以它们之间是可以相互转换的,同时,具有相同算术值的整型值和浮点型值在Lua语言中是相等的

```
>type(3)	-->number
>type(3.3)	-->number
```



### string



* Lua语言中的字符串即可以表示单个字符,也可以表示一整本书籍.在Lua语言中,操作100K或者1M个字母组成的字符串的程序很常见
* 可以使用单引号或双引号来声明字符串
* 如果声明的字符串比较长或者有多行,则可以使用如下方式进行声明

```
html = [[
<html>
<head>
<title>Lua-string</title>
</head>
<body>
<a href="http://www.lua.org">Lua</a>
</body>
</html>
]]
```



### table



* table是Lua语言中最主要的数据结构.使用表, Lua 语言可以以一种简单、统一且高效的方式表示数组、集合、记录和其他很多数据结构
* Lua语言中的表本质上是一种辅助数组,可以使用数值做索引,也可以使用字符串或其他任意类型的值作索引(除nil外)
* 创建表的最简单方式: `a = {}`
* 创建数组: `arr = {"TOM","JERRY","ROSE"}`
* 要想获取数组中的值,可以通过如下内容来获取:

```
print(arr[0])		nil
print(arr[1])		TOM
print(arr[2])		JERRY
print(arr[3])		ROSE
```

* 数组的下标默认是从1开始的,所以上述创建数组,也可以通过如下方式来创建

```
>arr = {}
>arr[1] = "TOM"
>arr[2] = "JERRY"
>arr[3] = "ROSE"
```

* 表的索引可以是数字,也可以是字符串等其他的内容,所以我们也可以将索引更改为字符串来创建

```
>arr = {}
>arr["X"] = 10
>arr["Y"] = 20
>arr["Z"] = 30
```

* 如果想要获取这些数组中的值,可以使用下面的方式

```
方式一
>print(arr["X"])
>print(arr["Y"])
>print(arr["Z"])
方式二
>print(arr.X)
>print(arr.Y)
>print(arr.Z)
```

* 当前table的灵活不进于此,还有更灵活的声明方式

```
>arr = {"TOM",X=10,"JERRY",Y=20,"ROSE",Z=30}
```

* 获取上面的值

```
TOM :  arr[1]
10  :  arr["X"] | arr.X
JERRY: arr[2]
20  :  arr["Y"] | arr.Y
ROESE?
```



### function



* 在 Lua语言中,函数是对语句和表达式进行抽象的主要方式
* 定义函数的语法为:

```lua
function functionName(params)

end
```

* 函数被调用的时候,传入的参数个数与定义函数时使用的参数个数不一致的时候,Lua 语言会抛弃多余参数或将不足的参数设为 nil
* 可变长参数函数

```
function add(...)
a,b,c=...
print(a)
print(b)
print(c)
end

add(1,2,3)  --> 1 2 3
```

* 函数返回值可以有多个

```
function f(a,b)
return a,b
end

x,y=f(11,22)	--> x=11,y=22	
```



### thread



* 在Lua中,thread用来表示执行的独立线路,用来执行协同程序



### userdata



* userdata是一种用户自定义数据,用于表示一种由应用程序或C/C++语言库所创建的类型



## Lua控制结构



* 用于循环的 while、 repeat 和 for,所有的控制结构都有一个显式的终结符: end.用于终结 if, for 及 while 结构, until 用于终结 repeat 结构



### if



```lua
function show(age)
    if age<=18 then
        return "青少年"
    elseif age>18 and age<=45 then
        return "青年"
    elseif age>45 and age<=60 then
        return "中年人"
    elseif age>60 then
        return "老年人"
    end
end

function testif(a)
    if a>0 then
        print("a是正数")
    else
        print("a是负数")
    end
end
```



### while



```lua
function testWhile()
    local i = 1
    while i<=10 do
        print(i)
        i=i+1
    end
end
```



### repeat



* repeat-until语句会重复执行其循环体直到条件为真时结束,由于条件测试在循环体之后执行,所以循环体至少会执行一次

```lua
function testRepeat()
    local i = 10
    repeat
        print(i)
        i=i-1
    until i < 1
end
```



### for



```
for param=exp1,exp2,exp3 do
 循环体
end
```

* param的值从exp1变化到exp2之前的每次循环会执行循环体,并在每次循环结束后将步长(step)exp3增加到param上.exp3可选,默认为1

```lua
for i = 1,100,10 do
    print(i)
end
```



#### 泛型for循环



* 泛型for循环通过一个迭代器函数来遍历所有值

```
for i,v in ipairs(x) do
	循环体
end
```

* i是数组索引值,v是对应索引的数组元素值,ipairs是Lua提供的一个迭代器函数,用来迭代数组,x是要遍历的数组

```lua
arr = {"TOME","JERRY","ROWS","LUCY"}
for i,v in ipairs(arr) do
    print(i,v)
end
```
