# MySQLOpt



# 基准测试



- sysbench: 一个模块化,跨平台以及多线程的性能测试工具
- iibench-mysql: 基于 Java 的 MySQL/Percona/MariaDB 索引进行插入性能测试工具
- tpcc-mysql: Percona开发的TPC-C测试工具



# 分页优化



* 利用覆盖索引优化.在查询的字段中添加主键索引或其他索引字段,不要使用*
* 利用范围查找,减少分页的偏移量查找时间,即减少limit第一个参数的查找时间,如limit 10,10比limit 10000 10快很多
* 利用子查询优化,效果等同于范围查找优化,都是减少偏移量的查找时间