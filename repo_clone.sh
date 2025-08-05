#!/bin/sh

ROOT_DIR=/f/repository

function checkRepositoryName(){
	read -p "请输入仓库名:" repositoryName
	echo 仓库名为:$repositoryName
	if [ ! -n "$repositoryName" ];then
		echo "仓库名为空,请重新输入"
		checkRepositoryName
	fi
}

function cloneReporitory(){
	cd $ROOT_DIR
	git clone git@gitee.com:dreamFlyingFlower/${repositoryName}

	sleep 1

	cd $ROOT_DIR/${repositoryName}
	git remote add github git@github.com:dreamFlyingFlower/${repositoryName}

	read -p "输入任意字符退出,输入1继续" goon

	if [ 1 -eq $goon ];then
		checkRepositoryName
		cloneReporitory
	fi
}

checkRepositoryName

cloneReporitory

exit