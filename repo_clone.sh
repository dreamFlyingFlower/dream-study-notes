#!/bin/sh
cd /f/repository
function checkRepositoryName(){
	read -p "请输入仓库名:" repositoryName
	if [ ! -n "$repositoryName" ];then
		echo "仓库名为空,请重新输入"
		checkRepositoryName
	fi
}

checkRepositoryName

git clone git@gitee.com:dreamFlyingFlower/${repositoryName}

sleep 1

cd /f/repository/${repositoryName}
git remote add github git@github.com:dreamFlyingFlower/${repositoryName}

read -p "输入任意字符退出" xxxx

exit
