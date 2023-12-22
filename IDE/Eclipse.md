# Eclipse



# 配置



## General



* 勾选
  * Always run in background
  * Show heap status



### Editors



#### Text Editors



##### Spelling



* 不勾选
  * Enable spell checking



### Keys



* `Close Project`:SHIFT+`,关闭项目
* `Multi caret down`:`CTRL+SHIFT+Q`,从鼠标选中的当前行一直往下选择多行进行编辑
* `Add all matches to multi-selection`:CTRL+SHIFT+`,先选一个字符串,按快捷键后选中所有相同字符串,可进行同时编辑




### WorkSpace



* 勾选
  * Text file encoding->Other->UTF-8
  * New text file line delimiter->Other->Unix



## Install/Update



### Automatic Updates



* Automatically find new ...:不勾选



## Java



### Appearance



#### Type Filters



* `java.awt.*`:勾选,会在导入或自动提示时不导入awt包



### Bytecode Outline



* 全部勾选



### Code Style



#### Code Templates



##### Comments



* 直接导入eclipse_java_codestyle_codetemplates.xml或按照下方设置

* Files

```java
/**
 * 
 *
 * @author 飞花梦影
 * @date ${currentDate:date('yyyy-MM-dd HH:mm:ss')}
 * @git {@link https://github.com/dreamFlyingFlower}
 */
```

* Types

```java
/**
 * 
 * @author 飞花梦影
 * @date ${currentDate:date('yyyy-MM-dd HH:mm:ss')}
 * @git {@link https://github.com/dreamFlyingFlower}
 */
```

* Overriding methods

```java
/**
 * ${tags}
 */
```



##### Code

* New Java Files

```java
${filecomment}
${package_declaration}
/**
 * 
 *
 * @author 飞花梦影
 * @date ${currentDate:date('yyyy-MM-dd HH:mm:ss')}
 * @git {@link https://github.com/dreamFlyingFlower}
 */
${typecomment}
${type_declaration}
```



#### Formatter



* eclipse_formatter.xml



### Compiler



#### Building



* General
  * maximum number of problems...:500



#### Errors/Warnings



##### Deprecated and restricted API



* Forbidden reference (access rules):改为Ignore



##### Potential programing problems



* Class overrides 'equals()' but not 'hashCode()':改为Warning



##### Annotations



* Missing @Override annotation:改为Warning



### Editor



#### Content Assist



* 勾选
  * Completion inserts
  * Insert single proposals automatically
  * Disable insertion triggers except 'Enter'
  * Add import instead of qualified name
    * Use static imports
  * Fill method arguments and show guessed arguments
    * Insert parameter names
  * Show camel case matches
  * Show substring matches
  * Hide proposals not visible in the invocation context
* Auto Activation
  * 勾选Enable auto activation
  * Auto activation delay:自动提示延迟提示时间,单位毫秒,设置100
  * Auto activation triggers for Java:自动提示单词,将数字和字母,点全填进去
  * Auto activation triggers for Javadoc:@#



##### Advanced



* SWT Tempalte Proposals:都不勾选



#### Templates



* pfsstr,Java,new a final static String

```java
private final static ${String} ${NAME} = ${VALUE};${cursor}
```

* pfsmap,Java,new a final static HashMap<String,Object>

```java
private final static Map<${String},${Object}> ${HASH_MAP} = new HashMap<>();${cursor}
${imp:import(java.util.HashMap,java.util.Map)}
```

* pfsconmap,Java,new a final static ConcurrentHashMap

```java
private final static Map<${String},${Object}> ${CONCURRENT_HASH_MAP} = new ConcurrentHashMap<>();${cursor}
${imp:import(java.util.concurrent.ConcurrentHashMap,java.util.Map)}
```

* pfslist,Java,new a final static ArrayList

```java
private final static List<${String}> ${ARRAY_LIST} = new ArrayList<>();${cursor}
${imp:import(java.util.ArrayList,java.util.List)}
```

* pfslistmap,Java,new a final static List<Map<String,Object>>

```java
private final static List<Map<${String},${Object}>> ${LIST_MAP} = new ArrayList<>();${cursor}
${imp:import(java.util.ArrayList,java.util.List,java.util.Map)}
```

* pstr,Java,dealare a private String

```java
private String ${NAME};${cursor}
```

* pint,Java,declare a private Integer

```java
private Integer ${NAME};${cursor}
```

* plong,Java,declare a private Long

```java
private Long ${NAME};${cursor}
```

* plist,Java,declare a private List

```java
private List<${String}> ${NAME};${cursor}
${imp:import(java.util.List)}
```

* pmap,Java,declare a private Map<String,Object>

```java
private Map<${String},${Object}> ${map};${cursor}
${imp:import(java.util.Map)}
```



* newHashMap,Java,new a Hashmap<String,Object>

```java
Map<${String},${Object}> ${map} = new HashMap<>();${cursor}
${imp:import(java.util.HashMap,java.util.Map)}
```

* newConmap,Java,new a ConcurrentHashMap<String,Object>

```java
Map<${String},${Object}> ${concurrentHashMap} = new ConcurrentHashMap<>();${cursor}
${imp:import(java.util.concurrent.ConcurrentHashMap,java.util.Map)}
```

* newArrayList,Java,new a ArrayList

```java
List<${String}> ${list} = new ArrayList<>()${cursor};
${imp:import(java.util.List,java.util.ArrayList)}
```

* newListMap,Java,new a List<Map<String,Object>>

```java
List<Map<${String},${Object}>> ${listMap} = new ArrayList<>();${cursor}
${imp:import(java.util.ArrayList,java.util.List,java.util.Map)}
```



* streamGroupBy,Java,list transfer throuth  group by

```java
stream().collect(Collectors.groupingBy(k -> ${k}));${cursor}
${imp:import(java.util.stream.Collectors)}
```

* streamMapGroupBy,Java,list through map and then groupby

```java
stream().map(t -> ${t}).collect(Collectors.groupingBy(k -> ${k}));${cursor}
${imp:import(java.util.stream.Collectors)}
```

* streamMapToList,Java,a list throuth map to other list

```java
stream().map(t -> ${t}).collect(Collectors.toList());${cursor}
${imp:import(java.util.stream.Collectors)}
```

* streamMapToMap,Java,list through map transfer to a map

```java
stream().map(t -> ${t}).collect(Collectors.toMap(k -> ${k}, v -> ${v}, (o, n) -> null == n ? o : n));${cursor}
${imp:import(java.util.stream.Collectors)}
```

* streamToMap,Java,list transfer to map

```java
stream().collect(Collectors.toMap(k -> ${k}, v -> ${v}, (o, n) -> null == n ? o : n));${cursor}
${imp:import(java.util.stream.Collectors)}
```



* apic,Java,add a @Api to a class controller

```java
/**
 * ${comment} API
 * 
 * @auther 飞花梦影
 * @date ${currentDate:date('yyyy-MM-dd HH:mm:ss')}
 * @git {@link https://github.com/dreamFlyingFlower}
 */
@Api(tags = "${comment} API")${imp:import(io.swagger.annotations.Api)}
```

* apim,Java,add a @ApiModel to a class po,dto,vo,do

```java
/**
 * ${comment}
 * 
 * @auther 飞花梦影
 * @date ${currentDate:date('yyyy-MM-dd HH:mm:ss')}
 * @git {@link https://github.com/dreamFlyingFlower}
 */
@ApiModel(description = "${comment}")${imp:import(io.swagger.annotations.ApiModel)}
```

* apimp,Java type members,add a @ApiModelProperty to a field

```java
/**
 * ${comment}
 */
@ApiModelProperty("${comment}")${cursor}${imp:import(io.swagger.annotations.ApiModelProperty)}
```

* apio,Java,add a @ApiOperation to a controller method

```java
/**
 * ${comment}
 */
@ApiOperation(value = "${comment}")${imp:import(io.swagger.annotations.ApiOperation)}
```

* lomAll,Java,add lombok getter,setter,builder,tostring,noarg,allarg annotation

```java
@Getter
@Setter
@Builder
@ToString
@NoArgsConstructor
@AllArgsConstructor${imp:import(lombok.AllArgsConstructor,lombok.Builder,lombok.Getter,lombok.NoArgsConstructor,lombok.Setter,lombok.ToString)}
```

* lomData,Java,add lombok data,builder,noarg,allarg,builder annotation

```java
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor${imp:import(lombok.AllArgsConstructor,lombok.Builder,lombok.Data,lombok.NoArgsConstructor)}
```

* lomGetSet,Java,add lombok getter and setter

```java
@Getter
@Setter${imp:import(lombok.Getter,lombok.Setter)}
```

* lomSuperAll,Java,add lombok all annotation with superbuilder

```java
@Getter
@Setter
@ToString
@SuperBuilder
@NoArgsConstructor
@AllArgsConstructor${imp:import(lombok.AllArgsConstructor,lombok.Getter,lombok.NoArgsConstructor,lombok.Setter,lombok.ToString,lombok.experimental.SuperBuilder)}
```



## Language Servers



* 如果有文件无法进行自动提示或跳转,可查看该配置中的相关文件类型是否未勾选



## Maven



* Do not automatically...:勾选
* Download Artifact sources:不勾选
* Automatically update...:不勾选



### Installations



* add->选择自己的maven插件



### UserSettings



* 选择自己的Maven插件,使用自己的Maven配置文件,修改默认的仓库地址,不要放C盘



## Spring



* 需要先安装Spring插件才有
* Start Language Server at...:不勾选



## Boot Launch Support



* Show warning message ...:不勾选



### OpenRewrite



* Prompt for Reconciling of Java Sources:不勾选,否则每次启动都有提示Spring xxxx Reconciling



### Validation



#### Boot 2.x Best Practices & Optimizations



* Enablement:可关闭,SpringBoot2.x一些优化



#### Boot 3.x Best Practices & Optimizations



* Enablement:可关闭,SpringBoot3.x一些优化



#### SpEL Expresions



* Enablement:ON,开启SpEL表达式提示



#### Versions and Support Ranges



* Enablement:OFF,关闭版本提示



## Validation



* MyBatis XML Mapper Validator:勾选,其他全部不勾选



## XML



### XML Files



#### Editor



* Line Width:120
* Split multiple attributes each on anew line:勾选



##### Templates



* foreachlist,mybatis if foreach tag,All XML

  ```xml
  <if test="query.${ids} != null and query.${ids}.size() > 0">
  				AND a.${id} IN
  				<foreach collection="query.${ids}" item="item" open="(" separator="," close=")">
  					#{item}
  				</foreach>
  			</if>
  ```

* ifstr,mybatis if string query tag,All XML

  ```xml
  <if test="query.${name} != null and query.${name} != '' ">
  				AND a.${column} = #{query.${name}}
  			</if>
  ```

* ifstrlike,mybatis if string like query tag,All XML

  ```xml
  <if test="query.${name} != null and query.${name} != '' ">
  				<bind name="${name}Like" value=" '%'+ query.${name} + '%' " />
  				AND a.${column} LIKE #{${name}Like}
  			</if>
  ```

* ifobj,mybatis if object query tag,All XML

  ```xml
  <if test="query.${name} != null ">
  				AND a.${column} = #{query.${name}}
  			</if>
  ```



## XML(Wild Web Developer)



### Formatting



* Max line width:120



# 快捷键



* `ALT+CLICK`:多编辑点选中,可同时编辑多行
* `ALT+LEFT`:在导航历史记录中后退
* `ALT+RIGHT`:在导航历史记录中前进
* `ALT+SHIFT+R`:重命名文件或方法,需要先选中,会自动修改使用该文件的其他文件,连续按2次会弹出对话框
* `ALT+SHIFT+M`:方法重构
* `CTRL+1`:
  * 选中有错误或警告的变量,会修改建议的快捷键
  * 选中类名,可快捷显示`getter/setter,tostring(),hashcode()/equals()`
* `CTRL+2,L`:为变量赋值.先按ctrl+2,右下角会出现选项,选择L给变量赋值
* `CTRL+6`:按1次查询整个WorkSpace,按2次查询当前Project,按3次查询当前文件
  * `@+`:查找所有bean定义
  * `@/`:查找所有Controller中的RequestMapping
  * `@>` :查找所有方法(prototype implementation)
  * `@`:查找所有Spring注解
  * `//` :查找所有http请求地址
* `CTRL+.`:将光标移动至当前文件中的下一个报错处或警告处
* `CTRL+O`:快速outline,查看当前文件的方法以及变量等
* `CTRL+Q`:回到最后一次编辑的地方
* `CTRL+T`:列出接口的实现类列表,再按一次则显示自底层向上的结构
* `CTRL+SHIFT+C`: 如果该快捷键无效,可以修改Toggle Line Comment,将When修改为In Windows
* `CTRL+SHIFT+O`:自动导包
* `CTRL+SHIFT+R`:打开资源,只能打开自己写的文件,不能打开JAR包内的文件
* `CTRL+SHIFT+T`:打开任何文件,包括资源文件,但不包括class
* `SHIFT+ENTER/CTRL+SHIFT+ENTER`:在当前行下/上新增一行空白行



# 插件



## SpringTool4

* 生成SpringBoot和SpringCloud项目



## Lombok

* `java -jar lombok.jar`:找到Eclipse安装地址,安装即可

* 若出现错处,可在eclipse.ini中添加如下代码

  ```ini
  --illegal-access=permit
  --add-opens=java.base/java.lang=ALL-UNNAMED
  --add-exports=java.base/sun.nio.ch=ALL-UNNAMED 
  --add-opens=java.base/java.lang.reflect=ALL-UNNAMED 
  --add-opens=java.base/java.io=ALL-UNNAMED 
  --add-exports=jdk.unsupported/sun.misc=ALL-UNNAMED
  ```




## MyBatipse



* 配合MyBatis,鼠标左键+CTRL可直接选择跳到相应的XML文件的相应方法中



## CallGraph Viewer



* 以流程图的形式展现选中类或方法的调用链



## DBeaver



* 数据库管理工具,可以代替Navicat



## UMLet



* 画UML流程图,并且可以导出pdf,jpg等格式



## JAutoDoc



* 自动代码注释



## Eclipse Color Theme



* Eclipse多种主题切换



## Bytecode Outline



* 显示Java文件编译后的指令文件,即JVM真正运行时的指令文件



## aiXcoder



* 同codota,需要在Brower for more solutions中搜索



## Codota



* 代码提示以及最新的代码样例,需要在Brower for more solutions中搜索



## ResourceBundle Editor



* 同时修改国际化配置文件



## Jar2UML



* 将Jar文件转换为UML图



## SonarLint



* 代码检查



## Enhanced Class Decompiler



* 无需源码即可debug



## Checkstyle Plug-in



* 检查代码样式