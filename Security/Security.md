# Security



# 安全检查



* AES/DES等对称加密类型,不要使用ECB,CCB加密模式,使用CCM或GCM模式,效率更高,更安全

* RSA不要使用默认的Cipher模式,使用`RSA/ECB/OAEPWithSHA-256AndMGF1Padding`加密和填充模式

* 不要直接使用`Method/Field/Constructor.setAccessible(true)`,会报安全漏洞,使用`org.springframework.util.ReflectionUtils#makeAccessible()`或参照该方法自己写

* 使用SecureRandom替代Random,更安全,但效率要慢10倍

* 不要使用File去拼接文件路径,使用Paths

  ```java
  Path path = Paths.get("filename").normalize();
  path.startsWith("指定目录,防止非法访问其他目录,如/etc/passwd");
  ```

* 密码加密:使用`jasypt-spring-boot-starter`

  ```shell
  # 控制台使用以下命令加密
  java -cp jasypt-1.9.3.jar org.jasypt.intf.cli.JasyptPBEStringEncryptionCLI input="需要加密的密码" password=加密密钥 algorithm=PBEWithMD5AndDES
  ```

  

  ```yaml
  # springboot的yml配置
  jasypt:
    encryptor:
      password: 加密密钥
      algorithm: PBEWithMD5AndDES
      iv-generator-classname: org.jasypt.iv.NoIvGenerator
  ```

* 密码安全策略
  * 密码长度: 至少8个字符
  * 密码重复使用: 12个(用户不能使用最近使用过的12个密码中的任何一个)
  * 密码寿命: 最长90天,最少1天
  * 密码复杂性: 不能是用户ID的衍生物;至少包含1个小字母、1个大字母、1个数字和1个特殊字符;不能包含两个相同的连续字符
  * 密码输入次数: 在尝试5次失败后,如果输入密码不正确,则被吊销或暂停一段时间