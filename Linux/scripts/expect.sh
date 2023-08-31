#!/bin/bash

# 使用 expect 工具自动交互密码远程其他主机安装 httpd 软件,

# 如果没有进行密钥绑定(~/.ssh/known_hosts),ssh 远程任何主机都会询问是否确认要连接该主机
USER=root
PASS=123.com
IP=192.168.1.120
expect -c "
    spawn ssh $USER@$IP

    expect {  
        \"(yes/no)\" {send \"yes\r\"; exp_continue}  
        \"password:\" {send \"$PASS\r\"; exp_continue}  
        \"$USER@*\" {send \"df -h\r exit\r\"; exp_continue}  
    }"

## 方法2
#!/bin/bash
USER=root
PASS=123.com
IP=192.168.1.120
expect << EOF set timeout 30 spawn ssh $USER@$IP   expect {    "(yes/no)" {send "yes\r"; exp_continue}    "password:" {send "$PASS\r"}
}
expect "$USER@*"  {send "$1\r"}
expect "$USER@*"  {send "exit\r"}
expect eof
EOF

## 方法3
#!/bin/bash
USER=root
PASS=123.com
IP=192.168.1.120
expect -c "
    spawn ssh $USER@$IP
    expect {
        \"(yes/no)\" {send \"yes\r\"; exp_continue}
        \"password:\" {send \"$PASS\r\"; exp_continue}
        \"$USER@*\" {send \"df -h\r exit\r\"; exp_continue}
    }"