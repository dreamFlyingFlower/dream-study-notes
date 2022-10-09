# MySQLExplain





# 概述



* explain可以分析sql的表读取顺序,数据读取操作的操作类型,那些索引可以使用,那些索引被实际使用,表之间的引用,每张表有多少行被优化器查询

* explain sql:直接在sql前面加上explain即可

* explain内容:id,select_type,table,type,possible_keys,key,key_len,ref,rows,extra

  

# ID



* select查询的序列号,包含一组数字,表示查询中执行select子句或操作表的顺序

* id相同:table加载的顺序由上而下
* id不同:如果是子查询,id的序号会递增,id越大优先级越高,越先被执行.一般是先执行子句
* id不同和相同同时存在:先加载数字大的,数字相同的顺序执行.若table行内出现衍生表(derived+id),衍生表后的数字是id的值,表示该验证表是由那一个id衍生而来
* id为null,表示这是一个结果集,不需要进行查询

```mysql
# id相同,此时id是相同的,都为1,而表加载顺序是t1->t3->t2
explain select * from t1,t2,t3 where t1.id =t2.id and t2.id = t3.id;
# id不同,此时id递增,1,2,3,而表加载顺序是t3->t1->t2
explain select * from t2 where id=(select id from t1 where id = (select t3.id from t3 where t3.name=''));
# id相同和不同同时存在,数字大的先加载,相同的顺序执行,加载顺序为t3->t2
explan select * from (select t3.id from t3 where t3.name='') s1,t2 where s1.id=t2.id
```



# Select_type



* 查询类型,在版本8和版本5中可能出现的情况不一样

* simple:简单select查询,查询中不包含子查询或union.有连接查询时,外层查询为simple,且只有一个
* primary:查询中若包含任何子查询或union,最外层查询将会认为是primary,且只有一个
* subquery:除了from子句中包含的子查询外,其他地方的子查询都可能是subquery
* dependent subquery:表示当前subquery的查询结果会受到外部表查询的影响
* derived:在from列表中包含的子查询被标记为DERIVED(衍生),mysql会递归执行这些子查询,把结果放在临时表中
* union:union连接的2个查询.除第一个查询是derived之外,之后的表都是union;若union包含在from子句的子查询中,外层select将被标记为derived
* union result:在union表获取结果的select,不需要参与查询,所以id为null
* dependent union:与union一样,出现在union中,但是union中第二个或后续的查询语句,使用了外部查询结果
* materialized:物化通过将子查询结果作为一个临时表来加快查询速度,正常来说是常驻内存,下次查询会再次引用临时表.通常情况下是作为子查询的大表第一次被查询之后,结果将会被存储在内存中,下次再试用该大表查询时就能直接从内存中读取



# Table



* 显示查询表名,也可能是表别名.如果不涉及数据操作,就显示null
* <subqueryN>:表示这个是子查询.N就是执行计划的id,表示结果来自于该子查询id
* <derivedN>:表示这个是临时表.N就是执行计划中的id,表示结果来自于该查询id
* <union M,N>:与derived类型,表示结果来自于union查询的id为M,N的结果集



# Prititions



* 查询涉及到的分区



# Type



* 表示查询的数据使用了何种类型,从好到坏:system>const>eq_ref>ref>range>index>all
* 一般来说,得保证查询至少达到range级别,最好能达到ref

* system:表只有一行记录,这是const的特例,一般不会出现.而且只能用于myisam和memory表,如果是innodb表,通常显示all或index

* const:表示通过unique索引或主键等值查询.因为只匹配一行数据,所以很快.如将主键置于where子句中,mysql就能将该查询转换为一个常量

* eq_ref:主键和唯一索引扫描.出现在要连接多个表的查询中,表示前面表的每一个记录,都只能匹配后面表的一行结果.此时驱动表该行数据的连接条件是第二个表的主键或唯一索引,作为条件查询只返回一条数据,且必须是not null.唯一索引和主键是多列时,只有所有列都用作比较时才会出现eq_ref

* ref:非唯一性索引扫描,返回匹配某个单值的所有行,属于查找和扫描的混合体,但本质上也是一种索引访问.和eq_ref不同,ref不要求连接顺序,也不一定需要唯一索引和主键,只要使用等值查找或多列主键,唯一索引中,使用第一个列之外的列作为等值查找也会出现

* fulltext:全文索引检索,优先级很高.若全文索引和普通索引同时存在时,优先使用全文索引.只能在创建了全文索引(fulltext)的表中,才可以使用match和against函数

* ref_or_null:与ref类似,只是增加了null值的比较,实际用的不多

* unique_subquery:用户where中的in子查询,子查询返回不重复唯一值

* index_subquery:用户in子查询使用了辅助索引或in常数列表,子查询可能返回重复值

* range:只检索给定范围的行,使用一个索引来选择行,key列显示使用了那个索引

  * 一般是where语句中出现了between,<,>,in等查询时会出现range
  * 这种范围索引扫描比全表扫描要好,因为它只需要开始于索引的某一点,而结束于另一点,不用扫描全部索引
  * range会让复合索引在排序时失效:当range类型用于复合索引的中间时,即使where子句中的字段和顺序都符合复合索引,同时排序,仍然用不上索引

  ```mysql
  # col1,col2,col3为复合索引
  # 此时虽然用上了索引,但是在排序时因为col2为range模式,使得排序的col3使用了using filesort
  explain select * from t1 where t1.col1=1 and t1.col2>1 order by t1.col3;
  # 解决办法:将col2从索引中剔除或直接建立col1和col3的独立索引
  ```

* index:扫描索引全部数据,比all快一点,因为索引文件通常比较小

* all:扫描全表数据,效率最低



# Possible_keys



* 显示可能应用在这张表中的索引,一个或多个,并非真实应用
* 查询涉及到的字段上若存在索引,则该索引将被列出,但不一定被查询使用
* 和key一起判断是否使用了索引,索引是否失效.多个索引竞争下,到底用了那一个索引



# Key



* 实际使用的索引,null表示没有使用.若查询中使用了覆盖索引,则该索引仅出现在key列表中



# Key_len



* 表示索引中使用的字节数,可通过该列计算查询中使用的索引长度
* 在不损失精确性的情况下,长度越短越好
* key_len显示的值为索引字段的最大可能长度,并非实际使用长度
* 多列索引时,索引可能不会全部使用,需要手动计算使用了那些索引
* 只会计算where条件中使用的索引,排序分组使用的索引不会计算进去
* 计算规则,字符串类型和字符集有关:latin1=1,gbk=2,utf8=3,utf8mb4=4,数字类型无关
  * char(n):n*字符集长度
  * varchar(n):n*字符集长度+2字节
  * tinyint:1字节
  * smallint:2字节
  * int,float:4
  * bigint,double:8
  * date:3字节
  * datetime:8字节
  * timestamp:4字节
  * NULL属性占用1个字节,如果设置了NOT NULL,则不占用字节




# Ref



* 显示索引使用了那些列或常量被用于查找索引列上的值
  * const:表示使用的是一个常量
  * db.table.column:表示使用的是某个数据库的某张表的某个字段
  * null:没有使用索引
* 如果连接查询时,被驱动表的执行计划显示的是驱动表的关联字段
* 如果是条件使用了表达式,函数或条件列发生了内部隐式转换,可能显示为func



# Rows



* 根据表统计信息以及索引选用情况,大致估算出找到所需记录要读取的行数,越小效率越高



# Extra



* 包含不适合在其他列显示但十分重要的额外信息



## Using filesort



* 该类型需要避免出现.文件内排序,MySQL中无法利用索引完成的排序操作称为文件排序,相当于排序字段并非索引字段.此时MySQL会对数据使用外部索引排序,而不是按照表内的索引顺序进行读取行.当索引字段为复合索引时,where里使用了索引字段,且是按照复合索引的顺序使用,那么排序所使用的字段若不符合复合索引的顺序,也将不使用索引

  ```mysql
  # col1,col2,col3为复合索引
  # col3将无法使用索引进行排序,此时会出现using filesort的内排序
  select * from t1 where col1='' order by col3;
  # 此时仍然使用的是索引排序,而不会出现using filesort,性能更好
  select * from t1 where col1='' order by col2,col3;
  # 此时虽然复合索引中间出现了其他的字段,但仍然会使用索引排序,而不会出现using filesort
  select * from t1 where col1='' and col4='' order by col2,col3;
  ```




## Using temporary



* 该类型需要避免出现.新建了一个内部临时表,保存中间结果.mysql对结果进行排序时使用临时表.该种情况多出现于复合索引的时候使用group by和order by

  ```mysql
  # col1,col2为复合索引
  # col2将无法使用索引进行排序,此时会出现using temporary,using filesort
  explain select * from t1 where col1 in('','') group by col2;
  # 此时仍然使用的是索引排序,而不会出现using temporary,using filesort,性能更好
  explain select * from t1 where col1 in('','') group by col1,col2;
  ```




## Using index



* 表示相应的select操作中使用了覆盖索引(Covering Index),避免访问了表的数据,效率还行

  ```mysql
  # col1,col2为复合索引
  # 此时会用到using where和using index
  explain select col2 from t1 where col1 ='';
  # 只用到了using index
  explain select col1,col2 from t1;
  ```

  * 如果同时出现using where,表明索引被用来执行索引键值的查找
  * 如果没有同时出现using where,表明索引用来读取数据而非执行查找动作.




## Using where



* 用到了where条件,但未使用索引




## Using where Using index



* 查询的列被索引覆盖,并且where筛选条件是索引列之一但是不是索引的前导列,意味着不能直接通过索引查找符合条件的数据.多出现于复合索引中,被查询字段非复合索引的第一个字段,而是其他字段




## Using index condition



* 与Using where类似,查询的列不完全被索引覆盖,where条件中是一个前导列的索引,即查询的字段中包含了非索引中的字段




## Using join buffer



* 表示使用了连接缓存,可以调整join buffer来调优



## impossible where



* where子句的值总是false,不能用来获取任何元组



## select tables optimized away



* 在没有group by子句的情况下,基于索引优化MIN/MAX操作或者对于MyISAM存储引擎优化count(*)操作,补习等到执行阶段再进行计算,查询执行计划生成的的阶段即完成优化



## distinct



* 优化distinct操作,在找到第一行匹配的元组后即停止找同样值的动作



## no tables used



* 不带from子句的查询或from dual查询



## null



* 查询的列未被索引覆盖,并且where筛选条件是索引的前导列,意味着用到了索引



## Using intersect



* 表示使用and连接各个索引条件时,从处理结果获取交集



## Using union



* 表示使用or连接各个使用索引的条件时,从处理结果获得并集,只有一个or



## Using sort_union,Using sort_intersect



* 用and和or查询信息量大时,先查询主键,然后排序合并后返回结果集



# Filtered



* 表示存储引擎返回的数据在srever层过来后,剩下多少满足查询的记录数量的比例
* 是百分比,不是具体记录数
