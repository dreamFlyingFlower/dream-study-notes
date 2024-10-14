# Cert



* 证书相关信息
* 编码转换:DER<->BASE64
* 证书标准:PKCS系列<->PEM/CER
* PKCS:Public Key Cryptography Standards,促进公钥密码的发展而制订的一系列标准,PKCS 目前共发布过 15 个标准
* PKCS#7:Cryptographic Message Syntax Standard,常用的后缀是:`.P7B .P7C .SPC`
* PKCS#10:Certification Request Standard
* PKCS#12:Personal Information Exchange Syntax Standard,包含了个人证书和私钥,二进制格式,常用的后缀有:`.P12 .PFX`
  * 在pfx证书的导入过程中有一项是“标志此密钥是可导出的,这将您在稍候备份或传输密钥”.一般是不选中的,如果选中,别人就有机会备份密钥.如果是不选中,其实密钥也导入了,只是不能再次被导出.这就保证了密钥的安全
  * 如果导入过程中没有选中这一项,做证书备份时“导出私钥”这一项是灰色的,不能选,只能导出cer格式的公钥.如果导入时选中该项,则在导出时“导出私钥”这一项就是可选的
  * 如果要导出私钥(pfx),是需要输入密码的,这个密码就是对私钥再次加密.其他人即使拿到了证书备份(pfx),不知道加密私钥的密码,也无法导入证书.如果只是导入导出cer格式的证书,是不会提示输入密码的.因为公钥一般来说是对外公开的,不用加密
* X.509:常见通用的证书格式,所有的证书都符合为Public Key Infrastructure (PKI) 制定的 ITU-T X509 国际标准
  * X.509 DER 编码(ASCII)的后缀是:`.DER .CER .CRT`
  * X.509 PAM 编码(Base64)的后缀是:`.PEM .CER .CRT`
  * cer/crt:证书中没有私钥,以二进制形式存放
  * pem:证书中没有私钥,但是以AscII存放
* PEM格式:PEM证书通常具有扩展名`.pem,.crt,.cer和.key`
  * 是Base64编码的ASCII文件,包含“----- BEGIN CERTIFICATE -----”和“----- END CERTIFICATE -----”语句
  * 服务器证书,中间证书和私钥都可以放入PEM格式
  * 几个PEM证书,甚至私钥,可以包含在一个文件中,一个在另一个文件之下,但是大多数平台希望证书和私钥位于单独的文件中

* DER格式:DER格式只是证书的二进制形式,而不是ASCII PEM格式.它有时会有.der的文件扩展名,但它的文件扩展名通常是.cer.
  * 判断DER .cer文件和PEM .cer文件之间区别的唯一方法是在文本编辑器中打开它并查找BEGIN / END语句.
  * 所有类型的证书和私钥都可以用DER格式编码
  * DER通常与Java平台一起使用
  * SSL转换器只能将证书转换为DER格式,如果需要将私钥转换为DER,要使用OpenSSL命令

* PKCS＃7 / P7B格式:PKCS＃7或P7B格式通常以Base64 ASCII格式存储,文件扩展名为.p7b或.p7c
  * P7B证书包含“----- BEGIN PKCS7 -----”和“----- END PKCS7 -----”语句
  * P7B文件仅包含证书和链证书,而不包含私钥
  * 多个平台支持P7B文件,包括Microsoft Windows和Java Tomcat

* PKCS＃12 / PFX格式:二进制格式,用于将服务器证书,任何中间证书和私钥存储在一个可加密文件中
  * PFX文件通常具有扩展名`.pfx,.p12`
  * PFX文件通常在Windows计算机上用于导入和导出证书和私钥
  * 将PFX文件转换为PEM格式时,OpenSSL会将所有证书和私钥放入一个文件中.之后需要在文本编辑器中打开该文件,并将每个证书和私钥(包括BEGIN / END语句)复制到其各自的文本文件中,并将它们分别保存为certificate.cer,CACert.cer和privateKey.key




# Keytool



## JKS



* 创建密钥仓库,用于存储证书文件:

  * `-genkeypair`:生成密钥对

  * `-alias`:别名,一般是证书完整地址,不包含https
  * `-keyalg`:公钥算法
  * `-keysize`:密钥长度
  * `-keystore`:生成的密钥对文件名
  * `-storepass`:密钥库密码
  * `-keypass`:私钥密码
  * `-validity`:证书的有效期,单位天
  * `-dname`:证书的主题信息,可不输入,回车后会提示输入.CN:必须填完整域名,不能是IP,不包含https.其他根据实际情况填写即可
  * `-ext`:当http调用https时,防止报错

  ```shell
  # 生成一个RSA算法的2048位密钥对
  keytool -genkeypair -alias www.dream.com -keyalg RSA -keysize 2048 -keystore keystore.jks -storepass password -keypass password -validity 36500 -dname "CN=example.com, OU=IT, O=Example, L=City, ST=State, C=Country" -ext SAN=dns:localhost,ip:127.0.0.1
  ```



## P12



* 导出P12

  * `-alias www.dream.com`:指定要导入证书的密钥对的别名为,一般为域名地址
  * `-file cert.cer`:指定要导入的证书文件名为cert.cer
  * `-keystore keystore.jks`:指定密钥库文件为keystore.jks
  * `-importkeystore`:导入密钥库
  * `-srckeystore keystore.jks`:指定要导入的密钥库文件名为keystore.jks
  * `-destkeystore keystore.p12`:指定导出的p12文件名为keystore.p12
  * `-srcstoretype JKS`:指定密钥导入的密钥库类型为JKS
  * `-deststoretype PKCS12`:指定密钥库类型为PKCS12格式

  ```shell
  keytool -importkeystore -srckeystore keystore.jks -destkeystore keystore.p12 -srcstoretype JKS -deststoretype PKCS12
  # 或
  keytool -export -alias www.dream.com -file keystore.p12 -keystore keystore.jks -storetype PKCS12
  ```



## 导出证书



* 导出证书

  * `-selfcert`:表示自签名证书
  * `-certreq`:生成证书请求
  * `-alias`:别名,一般使用完整域名,不包括https
  * `-keystore`:指定使用之前生成的密钥库文件
  * `-file`:导出的证书文件名,一般为完整域名,后缀为cer/csr
  * `-validity 36500`:指定证书有效期为36500天
  * `-exportcert`:导出证书
  * `-rfc`:证书样式
  * `-storepass`:证书密码
  
  ```shell
  # 自签名证书,不向颁发证书的机构申请证书(CER),会被浏览器警告
  keytool -selfcert -alias www.dream.com -keystore keystore.jks -file www.dream.com.cer -validity 36500
  # 或
  keytool -exportcert -alias www.dream.com -keystore keystore.jks -file www.dream.com.cer -rfc -storepass 123456
  # 需要被证书颁发机构认证的证书(CSR)
  keytool -certreq -alias www.dream.com -keystore keystore.jks -file www.dream.com.csr -validity 36500
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



* 已经有PEM格式或是将P12格式转成PEM格式之后再导入PEM

```shell
# 将p12格式转为PEM,提取证书和私钥,并去除bag attributes和key attributes,但有时候可能无效,需要授权删除PEM文件中的bag attributes和key attributes信息
# -nodes表示不去除证书链中的节点,这样就会保留证书和私钥在一个文件中
openssl pkcs12 -in keystore.p12 -out certificate.pem -nodes
# 只提取证书而不需要私钥
openssl pkcs12 -in keystore.p12 -out certificate.crt -clcerts -nokeys
```

* 导入PEM证书
  * `-import`:导入证书
  * `-alias www.dream.com`:给证书指定一个别名,一般为完整域名,不包含https
  * `-keystore`:指定信任库的路径,一般是JAVA_HOME/jre/lib/security/cacerts
  * `-file certificate.crt`:指定要导入的证书文件
  * `-storepass changeit`:默认信任库密码,只有在修改过的情况下才需要更改

```shell
keytool -import -alias www.dream.com -keystore "$JAVA_HOME/jre/lib/security/cacerts" -file certificate.pem  -storepass changeit
```



### CRT



* 已经有CRT格式或是将P12格式转成CRT格式之后再导入CRT

```shell
# 将p12格式转为PEM,提取证书和私钥,并去除bag attributes和key attributes,但有时候可能无效,需要授权删除PEM文件中的bag attributes和key attributes信息
# 只提取证书而不需要私钥,生成crt文件
openssl pkcs12 -in keystore.p12 -out certificate.crt -clcerts -nokeys
```

* 导入CRT证书到Java信任库
  * `-importcert`:导入签名证书
  * `-alias www.dream.com`:给证书指定一个别名
  * `-keystore`:指定信任库的路径
  * `-file certificate.crt`:指定要导入的证书文件
  * `-storepass changeit`:默认信任库密码,只有在修改过的情况下才需要更改

```shell
keytool -importcert -alias www.dream.com -keystore "$JAVA_HOME/jre/lib/security/cacerts" -file certificate.crt -storepass changeit
```



## 添加信任库



* 签名证书,用自己生成的CA来签名前面生成的证书

  ```shell
  # 从密钥仓库导出证书
  keytool -keystore keystore.jks -alias www.dream.com -certreq -file cert-file
  # 用CA签名
  openssl x509 -req -CA ca.crt -CAkey ca.key -in cert-file -out www.dream.com.crt -days 36500 -CAcreateserial -passin pass:dream
  # 导入CA证书和已签名的证书到密钥仓库
  keytool -keystore keystore.jks -alias CARoot -import -file ca-cert.crt
  keytool -keystore keystore.jks -alias www.dream.com -import -file www.dream.com.crt
  # 或
  keytool -importcert -trustcacerts -alias www.dream.com -file www.dream.com.crt -keystore keystore.jks
  ```





## 程序中使用



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



## 证书转换



* 将PFX/P12转换为JKS

```shell
keytool -importkeystore -srckeystore craftificate.pfx -srcstoretype pkcs12 -destkeystore craftificate.jks -deststoretype JKS
```



# Openssl



## 证书生成



* 使用openssl创建证书等,需要先安装openssl模块
* 生成根证书,以后的服务端证书和客户端证书都用他来签发,可以建立多个根证书.**根证书的私钥(KEY)和证书请求文件(CSR)一定要保存好**

```shell
# 生成根证书(CA)私钥,root.key(PEM格式)为私钥路径
openssl genrsa -out root.key 2048
# 利用私钥生成一个根证书的申请文件,一般证书的申请文件格式都是CSR.CN等其他信息都不填
openssl req -newkey root.key -out root.csr -days 36500
# 自签名的方式签发之前的申请的证书,生成的证书为CRT格式
openssl x509 -req -in root.csr -signkey root.key -out root.crt -days 36500
# 可选操作.为证书建立第一个序列号,一般都是用4个字符,这个不影响之后的证书颁发等操作
echo ROOT > /home/user/serial
# 可选操作.建立ca的证书库,不影响后面的操作,默认配置文件里也有存储的地方
touch /home/user/index.txt
# 可选操作.建立证书回收列表保存失效的证书
openssl ca -gencrl -out /home/user/root.crl -crldays 7

# 直接生成私钥和CSR申请文件
openssl req -newkey rsa:2048 -nodes -keyout root.key -out root.csr -days 36500
# 先生成root.key私钥,根据私钥直接生成CRT证书
openssl req -new -x509 -key root.key -out root.crt -days 36500
# 直接生成私钥,CSR,CRT的自签名证书
openssl req -newkey rsa:2048 -nodes -keyout root.key -x509 -days 36500 -out root.crt
```

* 生成和签发服务器身份验证证书.因为证书是自签名的,浏览器会提示不受信任.如果需要受信任的证书

```shell
# 建立服务器验证证书的私钥
openssl genrsa -out server.key
# 生成证书申请文件
openssl req -newkey server.key -out server.csr
# 利用根证书签发服务器身份验证证书
openssl ca -cert root.crt -keyfile root.key -in server.csr  -out server.crt
# 至此,服务器端身份认证证书已经完成,可以利用证书和私钥生成pfx格式的证书给微软使用
openssl pkcs12 -export -clcerts -in server.crt -inkey server.key -out server.p12
```

* 签发客户端身份认证证书.如果在web服务器上使用客户端证书,需要在web服务器上使用根证书对客户端进行验证

```shell
# 生成私钥
openssl genrsa -des3 -out client.key 1024
# 生成证书请求文件
openssl req -newkey client.key -out client.csr
# 利用根证书签发客户端证书
openssl ca -cert root.crt -in client.csr -keyfile client.crt
# 生成pfx格式
openssl pkcs12 -export -clcerts -in client.crt -inkey client.key -out client.p12
```

* 从 .p12 文件中提取私钥,并将其保存到一个.key文件中
  * `-in keystore.p12`:指定要提取的 .p12 文件
  * `-nocerts`:不提取证书,仅提取私钥
  * `-nodes`:私钥不进行加密,即无密码保护
  * `-out private.key`:输出私钥到 private.key 文件

```shell
openssl pkcs12 -in keystore.p12 -nocerts -nodes -out private.key
```

* 提取私钥之后,可以通过私钥提取公钥
  * `-in private.key`:指定私钥文件
  * `-pubout`:提取公钥
  * `-out public.key`:输出公钥到 public.key 文件

```shell
openssl rsa -in private.key -pubout -out public.key
```

* 提取证书
  * `-clcerts`:仅提取用户证书,不包括 CA 证书
  * `-nokeys`:不提取私钥
  * `-out certificate.crt`:输出证书到 certificate.crt 文件

```shell
openssl pkcs12 -in keystore.p12 -clcerts -nokeys -out certificate.crt
```

* 提取CA证书(根证书)
  * `-cacerts`:仅提取 CA 证书
  * `-chain`:包括整个证书链
  * `-nokeys`:不提取私钥
  * `-out ca.crt`:输出 CA 证书到 ca.crt 文件

```shell
# 如果 .p12 文件中包含 CA 证书,可以使用以下命令提取 CA 证书.如果不包含,则提取无效
openssl pkcs12 -in keystore.p12 -cacerts -nokeys -chain -out ca.crt
```

* 其他命令

```shell
# 生成加密的根证书(CA)私钥,root.key(PEM格式)为私钥路径
openssl genrsa -des3 -out private.key 2048
# 生成RSA私钥(使用aes256加密)
openssl genrsa -aes256 -passout pass:111111 -out private.key 2048
# 若生成公钥,需要提供密码
openssl rsa -in private.key -passin pass:111111 -pubout -out public.key
# 私钥转非加密
openssl rsa -in private.key -passin pass:111111 -out private.key
# 私钥转加密
openssl rsa -in private.key -aes256 -passout pass:111111 -out private.key
# 私钥PEM转DER
openssl rsa -in private.key -outform der-out private.der
# 查看私钥明细
openssl rsa -in rsa_private.key -noout -text
```



* 使用证书请求文件(CSR)来生成证书.可以将CSR文件发送给证书颁发机构(CA)或自己签名证书,之后会获得有效的证书文件(certificate.crt)
* 使用证书和私钥生成P12证书

```shell
openssl pkcs12 -export -in certificate.crt -inkey private.key -out certificate.p12
```



## 证书互转



* X509/CRT/CER/DER转换为PFX/P12

```shell
openssl pkcs12 -export -in server.crt -inkey server.key -out server.pfx
```

* PFX/P12--PEM(PKCS#12--PEM)

```shell
# 证书和私钥都要.-nodes:私钥不进行加密
openssl pkcs12 -in certificate.p12 -out certificate.pem -nodes
# -nocerts:不要证书要私钥
openssl pkcs12 -in certificate.p12 -out certificate.key -nocerts -nodes
# 不要私钥要证书
openssl pkcs12 -in certificate.p12 -out certificate.cer -clcerts -nokeys
```

* PEM--P12(PEM--PKCS#12)

```shell
# 将普通证书和pem证书合成P12
openssl pkcs12 -export -in certificate.pem -inkey private.key -out certificate.p12
# 将CA证书和pem证书合成P12:-chain指示同时添加证书链,-CAfile 指定了CA证书,导出的p12文件将包含多个证书
openssl pkcs12 -export -in certificate.crt -inkey server.key -chain -CAfile ca.crt -out certificate.p12
```

* PEM--DER/CER/CRT(BASE64--DER编码的转换)

```shell
openssl x509 -inform pem -in certificate.pem -outform der -out certificate.der
openssl x509 -inform pem -in certificate.pem -outform der -out certificate.crt
```

* CER/DER/CRT--PEM(编码DER--BASE64)

```shell
openssl x509 -inform der -in certificate.cer -outform pem -out certificate.pem
```

* PEM--P7B(PEM--PKCS#7)

```shell
openssl crl2pkcs7 -nocrl -certfile certificate.cer -out certificate.p7b -certfile CA.cer
```

* P7B--PEM(PKCS#7--PEM)

```shell
openssl pkcs7 -print_certs -in certificate.p7b -out certificate.cer
```

* P7B--PFX(PKCS#7--PKCS#12)

```shell
openssl pkcs7 -print_certs -in certificate.p7b -out certificate.cer
openssl pkcs12 -export -in certificate.cer -inkey private.key -out certificate.pfx -certfile CA.cer
```

* PEM--PFX(PEM--PKCS#12)

```shell
openssl pkcs12 -export -in certificate.crt -inkey private.key -out certificate.pfx -certfile CA.crt
```

* PEM BASE64--X.509文本格式

```shell
openssl x509 -in Key.pem -text -out Cert.pem
```

* PEM--SPC

```shell
openssl crl2pkcs7 -nocrl -certfile venus.pem -outform DER -out venus.spc
```

* PEM--PVK(openssl 1.x开始支持)

```shell
openssl rsa -in mycert.pem -outform PVK -pvk-strong -out mypvk.pvk
```

* PEM--PVK(对于openssl 1.x之前的版本,可以下载pvk转换器后通过以下命令完成)

```shell
pvk -in ca.key -out ca.pvk -nocrypt -topvk
```



## 证书文档





```
1. openssl list-standard-commands(标准命令)
    1) asn1parse: asn1parse用于解释用ANS.1语法书写的语句(ASN一般用于定义语法的构成) 
    2) ca: ca用于CA的管理 
    openssl ca [options]:
        2.1) -selfsign
        使用对证书请求进行签名的密钥对来签发证书。即"自签名"，这种情况发生在生成证书的客户端、签发证书的CA都是同一台机器(也是我们大多数实验中的情况)，我们可以使用同一个
密钥对来进行"自签名"
        2.2) -in file
        需要进行处理的PEM格式的证书
        2.3) -out file
        处理结束后输出的证书文件
        2.4) -cert file
        用于签发的根CA证书
        2.5) -days arg 
        指定签发的证书的有效时间
        2.6) -keyfile arg   
        CA的私钥证书文件
        2.7) -keyform arg
        CA的根私钥证书文件格式:
            2.7.1) PEM
            2.7.2) ENGINE 
        2.8) -key arg   
        CA的根私钥证书文件的解密密码(如果加密了的话)
        2.9) -config file    
        配置文件
    example1: 利用CA证书签署请求证书
    openssl ca -in server.csr -out server.crt -cert ca.crt -keyfile ca.key  

    3) req: X.509证书签发请求(CSR)管理
    openssl req [options] <infile >outfile
        3.1) -inform arg
        输入文件格式
            3.1.1) DER
            3.1.2) PEM
        3.2) -outform arg   
        输出文件格式
            3.2.1) DER
            3.2.2) PEM
        3.3) -in arg
        待处理文件
        3.4) -out arg
        待输出文件
        3.5) -passin        
        用于签名待生成的请求证书的私钥文件的解密密码
        3.6) -key file
        用于签名待生成的请求证书的私钥文件
        3.7) -keyform arg  
            3.7.1) DER
            3.7.2) NET
            3.7.3) PEM
        3.8) -new
        新的请求
        3.9) -x509          
        输出一个X509格式的证书 
        3.10) -days
        X509证书的有效时间  
        3.11) -newkey rsa:bits 
        生成一个bits长度的RSA私钥文件，用于签发  
        3.12) -[digest]
        HASH算法
            3.12.1) md5
            3.12.2) sha1
            3.12.3) md2
            3.12.4) mdc2
            3.12.5) md4
        3.13) -config file   
        指定openssl配置文件
        3.14) -text: text显示格式
    example1: 利用CA的RSA密钥创建一个自签署的CA证书(X.509结构) 
    openssl req -new -x509 -days 3650 -key server.key -out ca.crt 
    example2: 用server.key生成证书签署请求CSR(这个CSR用于之外发送待CA中心等待签发)
    openssl req -new -key server.key -out server.csr
    example3: 查看CSR的细节
    openssl req -noout -text -in server.csr

    4) genrsa: 生成RSA参数
    openssl genrsa [args] [numbits]
        [args]
        4.1) 对生成的私钥文件是否要使用加密算法进行对称加密:
            4.1.1) -des: CBC模式的DES加密
            4.1.2) -des3: CBC模式的DES加密
            4.1.3) -aes128: CBC模式的AES128加密
            4.1.4) -aes192: CBC模式的AES192加密
            4.1.5) -aes256: CBC模式的AES256加密
        4.2) -passout arg: arg为对称加密(des、des、aes)的密码(使用这个参数就省去了console交互提示输入密码的环节)
        4.3) -out file: 输出证书私钥文件
        [numbits]: 密钥长度
    example: 生成一个1024位的RSA私钥，并用DES加密(密码为1111)，保存为server.key文件
    openssl genrsa -out server.key -passout pass:1111 -des3 1024 

    5) rsa: RSA数据管理
    openssl rsa [options] <infile >outfile
        5.1) -inform arg
        输入密钥文件格式:
            5.1.1) DER(ASN1)
            5.1.2) NET
            5.1.3) PEM(base64编码格式)
         5.2) -outform arg
         输出密钥文件格式
            5.2.1) DER
            5.2.2) NET
            5.2.3) PEM
        5.3) -in arg
        待处理密钥文件 
        5.4) -passin arg
        输入这个加密密钥文件的解密密钥(如果在生成这个密钥文件的时候，选择了加密算法了的话)
        5.5) -out arg
        待输出密钥文件
        5.6) -passout arg  
        如果希望输出的密钥文件继续使用加密算法的话则指定密码 
        5.7) -des: CBC模式的DES加密
        5.8) -des3: CBC模式的DES加密
        5.9) -aes128: CBC模式的AES128加密
        5.10) -aes192: CBC模式的AES192加密
        5.11) -aes256: CBC模式的AES256加密
        5.12) -text: 以text形式打印密钥key数据 
        5.13) -noout: 不打印密钥key数据 
        5.14) -pubin: 检查待处理文件是否为公钥文件
        5.15) -pubout: 输出公钥文件
    example1: 对私钥文件进行解密
    openssl rsa -in server.key -passin pass:111 -out server_nopass.key
    example:2: 利用私钥文件生成对应的公钥文件
    openssl rsa -in server.key -passin pass:111 -pubout -out server_public.key

    6) x509:
    本指令是一个功能很丰富的证书处理工具。可以用来显示证书的内容，转换其格式，给CSR签名等X.509证书的管理工作
    openssl x509 [args]    
        6.1) -inform arg
        待处理X509证书文件格式
            6.1.1) DER
            6.1.2) NET
            6.1.3) PEM
        6.2) -outform arg   
        待输出X509证书文件格式
            6.2.1) DER
            6.2.2) NET
            6.2.3) PEM
        6.3) -in arg 
        待处理X509证书文件
        6.4) -out arg
        待输出X509证书文件
        6.5) -req            
        表明输入文件是一个"请求签发证书文件(CSR)"，等待进行签发 
        6.6) -days arg       
        表明将要签发的证书的有效时间 
        6.7) -CA arg 
        指定用于签发请求证书的根CA证书 
        6.8) -CAform arg     
        根CA证书格式(默认是PEM) 
        6.9) -CAkey arg      
        指定用于签发请求证书的CA私钥证书文件，如果这个option没有参数输入，那么缺省认为私有密钥在CA证书文件里有
        6.10) -CAkeyform arg  
        指定根CA私钥证书文件格式(默认为PEM格式)
        6.11) -CAserial arg   
        指定序列号文件(serial number file)
        6.12) -CAcreateserial 
        如果序列号文件(serial number file)没有指定，则自动创建它     
    example1: 转换DER证书为PEM格式
    openssl x509 -in cert.cer -inform DER -outform PEM -out cert.pem
    example2: 使用根CA证书对"请求签发证书"进行签发，生成x509格式证书
    openssl x509 -req -days 3650 -in server.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out server.crt
    example3: 打印出证书的内容
    openssl x509 -in server.crt -noout -text 

    7) crl: crl是用于管理CRL列表 
    openssl crl [args]
        7.1) -inform arg
        输入文件的格式
            7.1.1) DER(DER编码的CRL对象)
            7.1.2) PEM(默认的格式)(base64编码的CRL对象)
        7.2) -outform arg
        指定文件的输出格式 
            7.2.1) DER(DER编码的CRL对象)
            7.2.2) PEM(默认的格式)(base64编码的CRL对象)
        7.3) -text: 
        以文本格式来打印CRL信息值。
        7.4) -in filename
        指定的输入文件名。默认为标准输入。
        7.5) -out filename
        指定的输出文件名。默认为标准输出。
        7.6) -hash
        输出颁发者信息值的哈希值。这一项可用于在文件中根据颁发者信息值的哈希值来查询CRL对象。
        7.7) -fingerprint
        打印CRL对象的标识。
        7.8) -issuer
        输出颁发者的信息值。
        7.9) -lastupdate
        输出上一次更新的时间。
        7.10) -nextupdate
        打印出下一次更新的时间。 
        7.11) -CAfile file
        指定CA文件，用来验证该CRL对象是否合法。 
        7.12) -verify
        是否验证证书。        
    example1: 输出CRL文件，包括(颁发者信息HASH值、上一次更新的时间、下一次更新的时间)
    openssl crl -in crl.crl -text -issuer -hash -lastupdate –nextupdate 
    example2: 将PEM格式的CRL文件转换为DER格式
    openssl crl -in crl.pem -outform DER -out crl.der  

    8) crl2pkcs7: 用于CRL和PKCS#7之间的转换 
    openssl crl2pkcs7 [options] <infile >outfile
    转换pem到spc
    openssl crl2pkcs7 -nocrl -certfile venus.pem -outform DER -out venus.spc
    https://www.openssl.org/docs/apps/crl2pkcs7.html

    9) pkcs12: PKCS#12数据的管理
    pkcs12文件工具，能生成和分析pkcs12文件。PKCS#12文件可以被用于多个项目，例如包含Netscape、 MSIE 和 MS Outlook
    openssl pkcs12 [options] 
    http://blog.csdn.net/as3luyuan123/article/details/16105475
    https://www.openssl.org/docs/apps/pkcs12.html

    10) pkcs7: PCKS#7数据的管理 
    用于处理DER或者PEM格式的pkcs#7文件
    openssl pkcs7 [options] <infile >outfile
    http://blog.csdn.net/as3luyuan123/article/details/16105407
    https://www.openssl.org/docs/apps/pkcs7.html
 
2. openssl list-message-digest-commands(消息摘要命令)
    1) dgst: dgst用于计算消息摘要 
    openssl dgst [args]
        1.1) -hex           
        以16进制形式输出摘要
        1.2) -binary        
        以二进制形式输出摘要
        1.3) -sign file    
        以私钥文件对生成的摘要进行签名
        1.4) -verify file    
        使用公钥文件对私钥签名过的摘要文件进行验证 
        1.5) -prverify file  
        以私钥文件对公钥签名过的摘要文件进行验证
        verify a signature using private key in file
        1.6) 加密处理
            1.6.1) -md5: MD5 
            1.6.2) -md4: MD4         
            1.6.3) -sha1: SHA1 
            1.6.4) -ripemd160
    example1: 用SHA1算法计算文件file.txt的哈西值，输出到stdout
    openssl dgst -sha1 file.txt
    example2: 用dss1算法验证file.txt的数字签名dsasign.bin，验证的private key为DSA算法产生的文件dsakey.pem
    openssl dgst -dss1 -prverify dsakey.pem -signature dsasign.bin file.txt

    2) sha1: 用于进行RSA处理
    openssl sha1 [args] 
        2.1) -sign file
        用于RSA算法的私钥文件 
        2.2) -out file
        输出文件爱你
        2.3) -hex   
        以16进制形式输出
        2.4) -binary
        以二进制形式输出  
    example1: 用SHA1算法计算文件file.txt的HASH值,输出到文件digest.txt
    openssl sha1 -out digest.txt file.txt
    example2: 用sha1算法为文件file.txt签名,输出到文件rsasign.bin，签名的private key为RSA算法产生的文件rsaprivate.pem
    openssl sha1 -sign rsaprivate.pem -out rsasign.bin file.txt

3. openssl list-cipher-commands (Cipher命令的列表)
    1) aes-128-cbc
    2) aes-128-ecb
    3) aes-192-cbc
    4) aes-192-ecb
    5) aes-256-cbc
    6) aes-256-ecb
    7) base64
    8) bf
    9) bf-cbc
    10) bf-cfb
    11) bf-ecb
    12) bf-ofb
    13) cast
    14) cast-cbc
    15) cast5-cbc
    16) cast5-cfb
    17) cast5-ecb
    18) cast5-ofb
    19) des
    20) des-cbc
    21) des-cfb
    22) des-ecb
    23) des-ede
    24) des-ede-cbc
    25) des-ede-cfb
    26) des-ede-ofb
    27) des-ede3
    28) des-ede3-cbc
    29) des-ede3-cfb
    30) des-ede3-ofb
    31) des-ofb
    32) des3
    33) desx
    34) rc2
    35) rc2-40-cbc
    36) rc2-64-cbc
    37) rc2-cbc
    38) rc2-cfb
    39) rc2-ecb
    40) rc2-ofb
    41) rc4
    42) rc4-40
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

