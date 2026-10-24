@echo off
chcp 65001 >nul
color 0A
title 打包cummins-loto-branch并上传到服务器备份重启

rem ====================== 【只改这里】 ======================
set JAVA_PROJECT_PATH=D:\work\repository\cummins-loto-branch
set JAVA_TARGET_JAR=%JAVA_PROJECT_PATH%\target\cummins-loto-branch-2.0.0.RELEASE.jar

set LINUX_USER=root
set LINUX_IP=8.153.96.30
set REMOTE_JAR=/data/server/cummins-loto-branch/app/cummins-loto-branch-2.0.0.RELEASE.jar
set START_SHELL=/data/server/cummins-loto-branch/deploy.sh

set SSH_KEY=D:\work\project\company\UAT.pem
set JDK8_HOME=D:\software\jdk8
rem ==========================================================

echo ==================== 开始部署 ====================

rem 修复密钥权限
icacls "%SSH_KEY%" /inheritance:r /grant:r "%username%:(R)" >nul

echo.
echo [1/4] 打包Java...
cd /d "%JAVA_PROJECT_PATH%"
set JAVA_HOME=%JDK8_HOME%
set PATH=%JDK8_HOME%\bin;%PATH%
call mvn clean package -DskipTests
echo Java打包完成

echo.
echo [2/4] 备份旧文件...
ssh -n -T -i "%SSH_KEY%" %LINUX_USER%@%LINUX_IP% "if [ -f \"%REMOTE_JAR%\" ]; then num=1; file_date=$(stat -c %%y \"%REMOTE_JAR%\" | cut -d' ' -f1 | tr -d '-'); while [ -f \"%REMOTE_JAR%${file_date}-0$num\" ]; do num=$((num+1)); done; suf=$(printf %%02d $num); mv \"%REMOTE_JAR%\" \"%REMOTE_JAR%${file_date}-$suf\"; fi"
echo 备份完成！

echo.
echo [3/4] 上传新文件...
scp -i "%SSH_KEY%" "%JAVA_TARGET_JAR%" %LINUX_USER%@%LINUX_IP%:"%REMOTE_JAR%"

echo.
echo [4/4] 启动服务...
ssh -n -T -i "%SSH_KEY%" %LINUX_USER%@%LINUX_IP% "chmod +x '%START_SHELL%'"
ssh -n -T -i "%SSH_KEY%" %LINUX_USER%@%LINUX_IP% '%START_SHELL%'

echo.
echo ==================== 部署成功！====================
pause