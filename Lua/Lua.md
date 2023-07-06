# Lua



# 概述



* Lua是一个高效、简洁、轻量级、可扩展的脚本语言,可以很方便的嵌入到其它语言中使用
* 弱语言,支持面向过程编程和函数式编程



# 应用场景



* 游戏开发、独立应用脚本、web应用脚本、扩展和数据库插件、系统安全



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



## 注释



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

```lua
---[[
	注释内容
	注释内容
--]]
```



## 变量



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



* 算术运算符: `+,-,*,/,%,^ 乘幂`,如果操作数是字符串,会自动转换成数字进行操作

* 关系运算符: 关系运算符不会转换类型,如果类型不同进行比较,会返回false;可以手动使用tonumber或者tostring进行转换

```
==	等于
~=	不等于
>	大于
<	小于
>=	大于等于
<=	小于等于
```

* 逻辑运算符

```lua
and	-- 逻辑与	 A and B     &&   
or	-- 逻辑或	 A or B     ||
not	-- 逻辑非  取反,如果为true,则返回false  !
```

* 逻辑运算符可以作为if的判断条件
* 其他运算符

```lua
..	-- 连接两个字符串
#	-- 一元预算法,返回字符串或表的长度.如print(#'fdsfds')
```



## 全局变量



* 在Lua语言中,全局变量无须声明即可使用,在默认情况下,变量总是认为是全局的,如果未提前赋值,默认为nil



## 局部变量



* 要想声明一个局部变量,需要使用local来声明
* 局部变量的作用域为从声明开始到所在层的语句块结尾



## 数据类型



* Lua是一个动态类型的语言,一个变量可以存储任何类型的值
* nil: 空.也就是还没有赋值,它的作用可以用来与其他所有值进行区分,也可以当想要移除一个变量时,只需要将该变量名赋值为nil即可
* string: 字符串.用单引号或双引号引起来
* number: 数值.包含integer(整型)和float(双精度浮点型).不管是integer还是float,使用type()函数来取其类型,都会返回number,所以它们之间是可以相互转换的,同时,具有相同算术值的整型值和浮点型值在Lua语言中是相等的
* boolean: 布尔.true/false
* table: 表.表是Lua唯一的数据结构,既可以当数组,也可以做Map,或被视为对象
* function: 函数.封装某个或某些功能
* userData:是一种用户自定义数据,用于表示一种由应用程序或C/C++语言库所创建的类型
* Thread:线程.用来区别独立的执行线程,它被用来实现 coroutine (协同例程)
* 在Lua中,只有nil和false才是假,其它类型的值均被认为是真,在条件检测中0和空字符串也会认为是真

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

```lua
print(arr[0])		-- nil
print(arr[1])		-- TOM
print(arr[2])		-- JERRY
print(arr[3])		-- ROSE
```

* 数组的下标默认是从1开始的,所以上述创建数组,也可以通过如下方式来创建

```lua
arr = {}
arr[1] = "TOM"
arr[2] = "JERRY"
arr[3] = "ROSE"
```

* 表的索引可以是数字,也可以是字符串等其他的内容,所以我们也可以将索引更改为字符串来创建

```lua
arr = {}
arr["X"] = 10
arr["Y"] = 20
arr["Z"] = 30
```

* 如果想要获取这些数组中的值,可以使用下面的方式

```lua
-- 方式一
print(arr["X"])
print(arr["Y"])
print(arr["Z"])
-- 方式二
print(arr.X)
print(arr.Y)
print(arr.Z)
```

* 当前table的灵活不进于此,还有更灵活的声明方式

```
arr = {"TOM",X=10,"JERRY",Y=20,"ROSE",Z=30}
```

* 获取上面的值

```lua
TOM :  arr[1]
10  :  arr["X"] | arr.X
JERRY: arr[2]
20  :  arr["Y"] | arr.Y
ROESE?
```

* 向a中添加方法,注意中间是冒号

```lua
function a:test()
    -- self:相当于this
end
```





### function



* 函数是对语句和表达式进行抽象的主要方式
* 定义函数的语法为:

```lua
function functionName(params)

end
```

* 就算没有参数,括号也不能省略
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

```lua
function f(a,b)
    return a,b
end

x,y=f(11,22)	--> x=11,y=22	
```



## 控制结构



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
    elseif age>60 && age<80 then
        return "老年人"
    else
        return "寿星"
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



```lua
-- 步长可省略,默认为1,用break跳出循环
for 变量=初值,终值,步长 do
    -- dosomething
end

-- 增强for循环
for 变量1,变量2…,变量N in 迭带器 do
    -- dosomething
end

-- i是数组索引值,v是对应索引的元
-- ipairs是Lua提供的一个迭代器函数,用来迭代数组,arr是要遍历的数组,从索引1开始递增遍历到最后一个不为nil的整数索引
-- pairs,用来遍历非数组的表值,它会遍历所有值不为nil的索引
arr = {"TOME","JERRY","ROWS","LUCY"}
for i,v in ipairs(arr) do
    print(i,v)
end
```



# 面向对象



* Lua脚本的面向对象类似于JavaScript的面向对象,都是模拟的

  ```lua
  -- 直接创建对象
  local user={userId='user1',userName='sishuok'}
  -- 加新属性
  user.age = 12
  -- 添加方法,里面的self就相当于this
  function user:show(a)
      redis.log(redis.LOG_NOTICE,'a='..a..',age='..self['age'])
  end
  -- 调用方法
  user:show('abc')
  -- 子类继承,__index在这里起的作用就类似于JS中的Prototype
  local child={address='bj'}
  setmetatable(child,{__index=user})
  -- 子类调用父类方法
  child:show('child')
  -- 覆盖父类方法
  function child:show(a)
      redis.log(redis.LOG_NOTICE,'child='..a..',age='..self['age']..)
  end
  ```



# 模块化



* 直接使用require("model_name")来载入别的lua文件,文件后缀是.lua,载入时就会直接执行那个文件
* 载入同样的lua文件时,只有第一次的时候会去执行,后面的相同的都不执行
* 如果要让每一次文件都执行,可使用dofile("model_name")函数
* 如果要载入后不执行,等需要的时候执行,可使用 loadfile("model_name")函数,这种是把loadfile的结果赋值给一个变量,比如:local abc = loadfile("model_name") 后面需要运行时: abc()

