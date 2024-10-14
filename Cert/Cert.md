# Cert



* 证书相关信息



# Keytool



## JKS



* 用户创建使用SSL连接,需要已经安装了openssl

* 创建密钥仓库,用于存储证书文件:

  * `-genkeypair`:生成密钥对

  * `-alias`:别名
  * `-keyalg`:公钥算法
  * `-keysize`:密钥长度
  * `-keystore`:生成的密钥对文件名
  * `-storepass`:密钥库密码
  * `-keypass`:私钥密码
  * `-validity`:证书的有效期
  * `-dname`:证书的主题信息,可不输入,回车后会提示输入.注意:CN必须填域名,不能是IP,https不用写,其他都要写上去.其他根据实际情况填写即可
  * `-ext`:当http调用https时,防止报错

  ```shell
  # 生成默认算法默认长度的密钥对,keystore.jks可自定义,以jks结尾即可
  keytool -genkeypair -alias dream -keystore keystore.jks  -validity 36500
  # 推荐使用:生成一个RSA算法的2048位密钥对
  keytool -genkeypair -alias mykey -keyalg RSA -keysize 2048 -keystore keystore.jks -storepass password -keypass password -validity 36500 -dname "CN=example.com, OU=IT, O=Example, L=City, ST=State, C=Country" -ext SAN=dns:localhost,ip:127.0.0.1
  ```

* 创建CA: `openssl req -new -x509 -keyout ca-key -out ca-cert -days 100000`

* 将生成的CA添加到客户信任库: `keytool -keystore client.truststore.jks -alias CARoot -import -file ca-cert`

* 为程序提供信任库以及所有客户端签名了密钥的CA证书

  ```shell
  keytool -keystore server.truststore.jks -alias CARoot -import -file ca-cert
  ```

* 签名证书,用自己生成的CA来签名前面生成的证书:

  ```shell
  # 从密钥仓库导出证书
  keytool -keystore server.keystore.jks -alias dream -certreq -file cert-file
  # 用CA签名
  openssl x509 -req -CA ca-cert -CAkey ca-key -in cert-file -out cert-signed -days 100000 -CAcreateserial -passin pass:dream
  # 导入CA的证书和已签名的证书到密钥仓库
  keytool -keystore server.keystore.jks -alias CARoot -import -file ca-cert
  keytool -keystore server.keystore.jks -alias dream -import -file cert-signed
  ```



## P12



* 导出P12

  * `-importcert`:导入签名证书
  * `-alias mykey`:指定要导入证书的密钥对的别名为mykey
  * `-file cert.cer`:指定要导入的证书文件名为cert.cer
  * `-keystore mykeystore.jks`:指定密钥库文件为keystore.jks
  * `-importkeystore`:导入密钥库
  * `-srckeystore keystore.jks`:指定要导入的密钥库文件名为keystore.jks
  * `-destkeystore keystore.p12`:指定导出的p12文件名为keystore.p12
  * `-deststoretype PKCS12`:指定密钥库类型为PKCS12格式

  ```shell
  keytool -importkeystore -srckeystore keystore.jks -destkeystore keystore.p12 -srcstoretype JKS -deststoretype PKCS12
  # 或
  keytool -export -alias mydomain -file keystore.p12 -keystore keystore.jks -storetype PKCS12
  ```



## 自签名证书



* 生成自签名证书.如果自用,不向颁发证书的机构申请证书,可以使用该名称;如果要向颁发证书的机构申请认证证书,需要生成csr文件,不能使用当前命令

  * `-selfcert`:表示自签名证书
  * `-alias mydomain`:指定使用之前生成的密钥对的别名
  * `-keystore keystore.jks`:指定使用之前生成的密钥库文件
  * `-validity 365`:指定证书有效期为365天

  ```shell
  keytool -selfcert -alias mydomain -keystore keystore.jks -validity 365
  ```



## 生成CA证书CSR



* 生成CA请求.该方式和自签名证书不同,需要到被信任的证书颁发机构去申请文件

  * `-certreq`:生成证书请求
  * `-alias`:别名,一般使用完整域名,不包括https
  * `-file`:指定保存证书请求的文件名为cert.csr
  * `-keystore`:指定密钥对所在的密钥库文件为keystore.jks

  ```shell
  # 生成CSR
  keytool -certreq -alias www.mydomain.com -file www.mydomain.com.csr -keystore keystore.jks
  # 导入CSR
  keytool -importcert -trustcacerts -alias www.mydomain.com -file www.mydomain.com.csr -keystore keystore.jks
  ```



## 生成非CA证书CER



* 导出CER证书,该证书并未经过CA机构认证,能用,但是浏览器会报警告

  * `-exportcert`:导出证书
  * `-alias mydomain`:证书别名,一般使用完整域名,不包括https
  * `-file mydomain.cer`:导出的证书文件名,一般为完整域名,后缀为cer
  * `-keystore keystore.jks`:使用之前生成的密钥库文件
  * `-rfc`:证书样式
  * `-storepass`:证书密码

  ```shell
  # 生成CER
  keytool -exportcert -alias www.mydomain.com -file www.mydomain.com.cer -keystore keystore.jks -rfc -storepass 123456
  # 导入CER
  keytool -importcert -trustcacerts -alias www.mydomain.com -file www.mydomain.com.cer -keystore keystore.jks
  ```



## 导入证书



### P12



* 直接将P12导入到Java信任环境中

```shell
keytool -importkeystore -srcstoretype PKCS12 -srckeystore keystore.p12 -destkeystore "$JAVA_HOME/jre/lib/security/cacerts" -storepass changeit
```

* 查看信任证书列表

```shell
keytool -list -keystore "$JAVA_HOME/jre/lib/security/cacerts" -storepass changeit
```



### PEM



* 已经有PME格式或是将P12格式转成PEM格式之后再导入PEM

```shell
# 将p12格式转为PEM,提取证书和私钥,并去除bag attributes和key attributes,但有时候可能无效,需要授权删除PEM文件中的bag attributes和key attributes信息
# -nodes表示不去除证书链中的节点,这样就会保留证书和私钥在一个文件中
openssl pkcs12 -in keystore.p12 -out certificate.pem -nodes
# 只提取证书而不需要私钥
openssl pkcs12 -in keystore.p12 -out certificate.crt -clcerts -nokeys
```

* 导入PEM证书
  * `-import`:导入证书
  * `-alias dream`:给证书指定一个别名
  * `-keystore`:指定信任库的路径,一般是JAVA_HOME/jre/lib/security/cacerts
  * `-file certificate.crt`:指定要导入的证书文件
  * `-storepass changeit`:默认信任库密码,只有在修改过的情况下才需要更改

```shell
keytool -import -alias dream -keystore "$JAVA_HOME/jre/lib/security/cacerts" -file certificate.pem  -storepass changeit
```



### CRT



* 已经有CRT格式或是将P12格式转成CRT格式之后再导入CRT

```shell
# 将p12格式转为PEM,提取证书和私钥,并去除bag attributes和key attributes,但有时候可能无效,需要授权删除PEM文件中的bag attributes和key attributes信息
# 只提取证书而不需要私钥,生成crt文件
openssl pkcs12 -in keystore.p12 -out certificate.crt -clcerts -nokeys
```

* 导入CRT证书
  * `-importcert`:导入证书
  * `-alias dream`:给证书指定一个别名
  * `-keystore`:指定信任库的路径
  * `-file certificate.crt`:指定要导入的证书文件
  * `-storepass changeit`:默认信任库密码,只有在修改过的情况下才需要更改

```shell
keytool -importcert -alias dream -keystore "$JAVA_HOME/jre/lib/security/cacerts" -file certificate.crt -storepass changeit
```



### 程序中使用



```java
// 1.服务启动时,使用启动命令,指定jks文件路径和密码(初始密码:changeit)
-Djavax.net.ssl.trustStore={证书jks绝对路径} 
-Djavax.net.ssl.trustStorePassword=changeit(密码)

// 2.使用jks,在代码里加载证书
Properties systemProps = System.getProperties();
systemProps.put("javax.net.ssl.trustStore", "证书jks绝对路径");
systemProps.put("javax.net.ssl.trustStorePassword", "密码");
System.setProperties(systemProps);

// 3.使用p12,在代码里加载证书
KeyStore keyStore = KeyStore.getInstance("PKCS12");
FileInputStream fis = new FileInputStream("p12证书的绝对路径");
// P12证书密码
keyStore.load(fis, "password".toCharArray());
// path/to/keystore为证书库绝对路径,一般是jks文件路径
System.setProperty("javax.net.ssl.keyStore", "path/to/keystore");
System.setProperty("javax.net.ssl.keyStorePassword", "password");

 // 4.使用P12以及别名加载P12证书
String p12File = "<P12证书文件路径>";
String p12Password = "<P12证书密码>";
FileInputStream fis = new FileInputStream(p12File);
KeyStore ks = KeyStore.getInstance("PKCS12");
ks.load(fis, p12Password.toCharArray());
// 获取证书
String alias = "<别名>";
Certificate certificate = ks.getCertificate(alias);
// 导入证书
String trustStoreFile = "<信任库文件路径>";
String trustStorePassword = "<信任库密码>";
KeyStore trustStore = KeyStore.getInstance("JKS");
trustStore.load(new FileInputStream(trustStoreFile), trustStorePassword.toCharArray());
trustStore.setCertificateEntry(alias, certificate);
// 保存信任库
trustStore.store(new FileOutputStream(trustStoreFile), trustStorePassword.toCharArray());
```



# CSR



* 使用openssl生成CSR证书以及私钥

  ```shell
  # 生成私钥key文件,其中servername参数为域名的完整地址,如果有www,也要带上,文件结尾为key
  sudo openssl genrsa -des3 -out servername.key 2048
  # 使用上一步的key生成csr文件,csr文件的名称同key一样,以csr结尾.证书密码要记住
  # 在生成csr文件过程中需要填写相关信息,根据实际填写,也可不写,但是Common Name必须填写为完整的域名地址
  sudo openssl req -new -key servername.key -out servername.csr
  # 再加密
  sudo openssl rsa -in servername.key -out servername.key
  ```



# Openssl



* 生成一个私钥(KEY)和证书请求(CSR)

```shell
openssl req -newkey rsa:2048 -nodes -keyout private.key -out request.csr
```

* 使用证书请求文件(CSR)来生成证书.可以将CSR文件发送给证书颁发机构(CA)或自己签名证书,之后会获得有效的证书文件(certificate.crt)
* 使用证书和私钥生成P12证书

```shell
openssl pkcs12 -export -in certificate.crt -inkey private.key -out certificate.p12
```



# 问题



## 问题1



* 导入CA证书报错 keytool error: java.lang.Exception: Input not an X.509 certificate

* 证书格式一般如下,如果有多于的信息,使用编辑模式删除即可

  ```shell
  -----BEGIN CERTIFICATE----- 
  MIIFODCCBCCgAwIBAgIQU
  yjELMAkGA1UEBhMCVVM
  ExZWZXJpU2lnbiBUcnVz
  U2lnbiwgSW5jLiAtIEZv
  ZXJpU2lnbiBDbGFz
  -----END CERTIFICATE-----
  ```



## 问题2



* No subject alternative names present
* 原因大概是生成证书的时候,CN不能用ip,必须用域名,需要用域名重新生成证书

```shell
keytool -genkeypair -alias <别名> -keyalg RSA -validity 36500 -keystore <keystore路径> -dname "CN=<域名>或localhost"
# 或
keytool -genkeypair -alias <别名> -keyalg RSA -validity 36500 -keystore <keystore路径> -ext SAN=dns:localhost,ip:127.0.0.1 -dname "CN=<域名>或localhost"
```



## 问题3



* Java导入证书失败Keystore was tampered with, or password was incorrect
* 在进行证书相关操作,如更新、删除、导入时,需要输入保护密码,默认的是**changeit**,输入即可,而不是生成证书时自己设置的

