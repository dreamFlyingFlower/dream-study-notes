#!/bin/bash


################## 1 ##################


# 批量修改服务器用户密码

OLD_INFO=old_pass.txt
NEW_INFO=new_pass.txt
for IP in $(awk '/^[^#]/{print $1}' $OLD_INFO); do
    USER=$(awk -v I=$IP 'I==$1{print $2}' $OLD_INFO)
    PASS=$(awk -v I=$IP 'I==$1{print $3}' $OLD_INFO)
    PORT=$(awk -v I=$IP 'I==$1{print $4}' $OLD_INFO)
    # 随机密码
    NEW_PASS=$(mkpasswd -l 8)
    echo "$IP   $USER   $NEW_PASS   $PORT" >> $NEW_INFO
    expect -c "
    spawn ssh -p$PORT $USER@$IP
    set timeout 2
    expect {
        \"(yes/no)\" {send \"yes\r\";exp_continue}
        \"password:\" {send \"$PASS\r\";exp_continue}
        \"$USER@*\" {send \"echo \'$NEW_PASS\' |passwd --stdin $USER\r exit\r\";exp_continue}
    }"
done