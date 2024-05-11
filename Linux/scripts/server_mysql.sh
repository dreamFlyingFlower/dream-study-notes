#!/bin/bash

#####################################################################
########            备份MySQL数据库,生成定时任务脚本,上传本脚本到服务器任意目录,赋权后执行即可            ########
########       赋权命令为chmod 755 server_mysql.sh,执行命令./server_mysql.sh或sh server_mysql.sh       ########
#####################################################################

read -p "请输入数据库名称,帐号,密码,用空格隔开.若不输入数据库账号密码,默认使用root,root@123:" DB_NAME DB_USERNAME DB_PASSWORD

if [ ! -n "$DB_NAME" ];then
	echo -e "\e[31m----- 未输入数据库名称,请重新运行脚本 -----\e[0m"
	exit
fi

if [ ! -n "$DB_USERNAME" ];then
	echo -e "\e[33m----- 未输入数据库帐号,默认使用root -----\e[0m"
	DB_USERNAME=root
fi

if [ ! -n "$DB_PASSWORD" ];then
	echo -e "\e[33m----- 未输入数据库密码,默认使用root@123 -----\e[0m"
	DB_PASSWORD=root@123
fi

# 数据存放根目录
DIR_ROOT=/data
# 数据库文件存放根目录
DIR_DB_MYSQL=$DIR_ROOT/bak/mysql
# 数据库单个服务根目录
DIR_DB_PROJECT=$DIR_DB_MYSQL/$DB_NAME

# 数据库备份脚本,删除超时备份目录
DIR_SCRIPT=$DIR_ROOT/scripts

# 生成数据库备份所有层级目录
if [ ! -d "$DIR_DB_PROJECT" ];then
	mkdir -p $DIR_DB_PROJECT
fi

# 生成脚本目录所有层级目录
if [ ! -d "$DIR_SCRIPT" ];then
	mkdir -p $DIR_SCRIPT
fi

# 生成备份脚本
cat>$DIR_SCRIPT/${DB_NAME}_bak.sh<<EOF
#!/bin/bash

mysqldump -u${DB_USERNAME} -p${DB_PASSWORD} $DB_NAME | gzip > $DIR_DB_PROJECT/${DB_NAME}_bak_\`date +%Y%m%d\`.sql.gz

EOF

chmod 755 $DIR_SCRIPT/${DB_NAME}_bak.sh

# 生成超时删除脚本
cat>$DIR_SCRIPT/${DB_NAME}_bak_remove.sh<<EOF
#!/bin/bash

find $DIR_DB_PROJECT/ -mtime +7 -name "*.gz" -exec rm -f {} \;

EOF

chmod 755 $DIR_SCRIPT/${DB_NAME}_bak_remove.sh

# 生成定时任务语句,可根据需求自行修改定时任务时间
systemctl restart crond

EXIST_BAK_NUM=`crontab -l | grep ${DIR_SCRIPT}/${DB_NAME}_bak.sh | wc -l`
if [[ $EXIST_BAK_NUM -ge 1 ]]; then
	echo -e "\e[33m----- 定时执行${DIR_SCRIPT}/${DB_NAME}_bak.sh的定时任务已经存在,无需重新添加 -----\e[0m"
else
	crontab -l > /tmp/conf && echo "0 2,8,13,19 * * * sh ${DIR_SCRIPT}/${DB_NAME}_bak.sh" >> /tmp/conf && crontab /tmp/conf && rm -f /tmp/conf
	echo -e "\e[32m----- 定时执行${DIR_SCRIPT}/${DB_NAME}_bak.sh的定时任务添加成功 -----\e[0m"
fi

EXIST_BAK_REMOVE_NUM=`crontab -l|grep ${DIR_SCRIPT}/${DB_NAME}_bak_remove.sh|wc -l`
if [[ $EXIST_BAK_NUM -ge 1 ]]; then
	echo -e "\e[33m----- 定时执行${DIR_SCRIPT}/${DB_NAME}_bak_remove.sh的定时任务已经存在,无需重新添加 -----\e[0m"
else
	crontab -l > /tmp/conf && echo "0 3 * * * sh ${DIR_SCRIPT}/${DB_NAME}_bak_remove.sh" >> /tmp/conf && crontab /tmp/conf && rm -f /tmp/conf
	echo -e "\e[32m----- 定时执行${DIR_SCRIPT}/${DB_NAME}_bak_remove.sh的定时任务添加成功 -----\e[0m"
fi

echo ""

echo -e "\e[35m----- 请将其他脚本文件放入${DIR_SCRIPT}目录下,方便统一管理 -----\e[0m"
echo ""
echo -e "\e[32m----- 请注意定时任务的备份时间和备份删除时间,默认每天2,8,13,19点定时备份,备份会覆盖;7天删除一次备份 -----\e[0m"
echo ""
echo -e "\e[34m----- 请注意使用 crontab -l 查看冷备脚本和删除冷备脚本是否添加成功,或重复添加 -----\e[0m"
echo ""
echo -e "\e[34m----- 如定时任务出现重复,请使用 crontab -e 自行编辑删除 -----\e[0m"
echo ""

read -p "按任意键退出"

exit