#!/bin/bash
ROOT_DIR="/f/repository/"
ALL_REPOSITORYS=`ls $ROOT_DIR`
for repository in $ALL_REPOSITORYS; do
	echo ${ROOT_DIR}${repository}
	if [ ! -d ${ROOT_DIR}${repository} ]; then
		continue;
	fi
	cd ${ROOT_DIR}${repository}
	if [ -d .git ]; then
		echo -e "\033[1;35m----- git pull ${repository} start -----\033[0m"
		sleep 1
		git pull
		echo -e "\033[1;35m----- git pull ${repository} end -----\033[0m"
	fi
done
echo "git pull complete"
sleep 1
read -p "输入任意字符退出"
exit