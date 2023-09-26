# MySQLError



# SQL错误



## GROUP BY使用错误



### 错误提示



```shell
Expression #1 of SELECT list is not in GROUP BY clause and contains nonaggregated column 'xxx' which is not functionally dependent on columns in GROUP BY clause; this is incompatible with sql_mode=only_full_group_by
```



### 解决方案1



* 推荐.找出不规范的`group by`语句,将其中不属于分组字段的select中的字段去掉



### 解决方案2



* 不推荐.修改MySQL的配置文件,在mysqld下添加如下语句.添加后不会报错,但除分组字段之外的其他字段值不准确,不可直接使用

  ```mysql
  sql_mode='STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION'
  ```

  

