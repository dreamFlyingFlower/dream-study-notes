# Security



# 安全检查



* AES/DES等对称加密类型,不要使用ECB,CCB加密模式,使用CCM或GCM模式,效率更高,更安全
* RSA不要使用默认的Cipher模式,使用`RSA/ECB/OAEPWithSHA-256AndMGF1Padding`加密和填充模式
* 不要直接使用`Method/Field/Constructor.setAccessible(true)`,会报安全漏洞,使用`org.springframework.util.ReflectionUtils#makeAccessible()`或参照该方法自己写
* 使用SecureRandom替代Random,更安全,但效率要慢10倍
* 不要使用File去拼接文件路径,使用Paths
* 密码加密:使用`jasypt-spring-boot-starter`