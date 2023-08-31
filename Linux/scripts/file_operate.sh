#!/bin/bash


################## 1 ##################

# 将文件中所有的小写字母转换为大写字母 

# $1是位置参数,是你需要转换大小写字母的文件名称
# 执行脚本,给定一个文件名作为参数,脚本就会将该文件中所有的小写字母转换为大写字母
tr "[a‐z]" "[A‐Z]" < $1


################## 2 ##################

# 计算文档每行出现的数字个数,并计算整个文档的数字总数

# 使用awk只输出文档行数(截取第一段)
n=`wc -l a.txt|awk '{print $1}'`
sum=0
# 文档中每一行可能存在空格,因此不能直接用文档内容进行遍历
for i in `seq 1 $n`do
	# 输出的行用变量表示时,需要用双引号
	line=`sed -n "$i"p a.txt`
	n_n=`echo $line|sed s'/[^0-9]//'g|wc -L`
	echo $n_nsum=$[$sum+$n_n]
done
echo "sum:$sum"


################## 3 ##################

# 从 FTP 服务器下载文件

if [ $# -ne 1 ]; then
    echo "Usage: $0 filename"
fi
dir=$(dirname $1)
file=$(basename $1)
# -n 自动登录
# open后的ip地址为ftp服务器地址
# user后的admin和password是ftp服务器的登录账号
# binary:设置ftp传输模式为二进制,避免MD5值不同或.tar.gz压缩包格式错误
ftp -n -v << EOF
open 192.168.1.10
user admin password
binary
cd $dir
get "$file"
EOF


################## 4 ##################

# 批量修改文件名

for file in $(ls *html); do  
    mv $file bbs_${file#*_}  
    # mv $file $(echo $file |sed -r 's/.*(_.*)/bbs\1/')
    # mv $file $(echo $file |echo bbs_$(cut -d_ -f2)
done


################## 5 ##################

# 批量修改文件名

for file in $(find . -maxdepth 1 -name "*html"); do
     mv $file bbs_${file#*_}
 done