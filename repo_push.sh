#!/bin/bash
ROOT_DIR="/f/repository/"
ALL_REPOSITORYS=`ls $ROOT_DIR`
LABEL="nothing to commit, working tree clean"
DEFAULT_COMMENT="fix or study something"
for repository in $ALL_REPOSITORYS; do
	echo ${ROOT_DIR}${repository}
	# 不是目录
	if [ ! -d ${ROOT_DIR}${repository} ]; then
		continue;
	fi
	# 是目录并判断是否是git仓库
	cd ${ROOT_DIR}${repository}
	if [ -d .git ]; then
		echo -e "\033[1;35m----- git push ${repository} start -----\033[0m"
		# 判断是否有可以提交的文件
		GIT_STATUS=`git status|grep "$LABEL"`
		if [ "$GIT_STATUS" != "" ];then
		    echo -e "\033[1;34m----- nothing to commit and push to remote -----\033[0m"
		    continue;
		fi
		sleep 1

		# 判断是否已经存在gitPush.sh脚本
		if [ -f gitPush.sh ]; then
			sh gitPush.sh
			echo -e "\033[1;35m----- git push ${repository} end -----\033[0m"
			continue;
		fi

		# 没有gitPush脚本
		echo -e "\033[1;32m----- add all of the modify file -----\033[0m"
		git add -A
		echo ""

		echo -e "\033[1;32m----- commit to local repository -----\033[0m"
		git commit -am "${DEFAULT_COMMENT}"
		echo ""

		echo -e "\033[1;35m----- commit to remote repository -----\033[0m"
		git push
		echo ""

		echo -e "\033[1;32m----- check status -----\033[0m"
		git status

		echo -e "\033[1;35m----- git push ${repository} end -----\033[0m"
		sleep 1
	fi
done
echo "git push complete"
sleep 1
read -p "输入任意字符退出"
exit