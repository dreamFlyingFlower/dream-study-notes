@echo off
chcp 65001 >nul
color 0A
title 最终完美版 — 绝对正确

rem ====================== 【只改这里】 ======================
set VUE_PROJECT_PATH=D:\work\repository\cummins-loto-web
set VUE_DIST_FOLDER=%VUE_PROJECT_PATH%\dist

set LINUX_USER=root
set LINUX_IP=8.153.96.30
set REMOTE_VUE=/data/nginx/html/cummins-loto-branch/cummins-loto-branch
set START_SHELL=/data/script/nginx_restart.sh

set SSH_KEY=D:\work\project\company\UAT.pem
rem ==========================================================

echo ==================== 开始部署 ====================

rem 修复密钥权限
icacls "%SSH_KEY%" /inheritance:r /grant:r "%username%:(R)" >nul

echo.
echo [1/4] 打包Vue...
cd /d "%VUE_PROJECT_PATH%"
call npm run build:prod
echo Vue打包完成

echo.
echo [2/4] 备份旧文件...
ssh -n -T -i "%SSH_KEY%" %LINUX_USER%@%LINUX_IP% "if [ -d \"%REMOTE_VUE%\" ]; then num=1; file_date=$(stat -c %%y \"%REMOTE_VUE%\" | cut -d' ' -f1 | tr -d '-'); while [ -d \"%REMOTE_VUE%${file_date}-0$num\" ]; do num=$((num+1)); done; suf=$(printf %%02d $num); mv \"%REMOTE_VUE%\" \"%REMOTE_VUE%${file_date}-$suf\"; fi"
echo 备份完成！

echo.
echo [3/4] 上传新文件...
ssh -n -T -i "%SSH_KEY%" %LINUX_USER%@%LINUX_IP% "mkdir -p '%REMOTE_VUE%'"
scp -i "%SSH_KEY%" -r "%VUE_DIST_FOLDER%\*" %LINUX_USER%@%LINUX_IP%:"%REMOTE_VUE%/"

echo.
echo [4/4] 启动服务...
ssh -n -T -i "%SSH_KEY%" %LINUX_USER%@%LINUX_IP% "chmod +x '%START_SHELL%'"
ssh -n -T -i "%SSH_KEY%" %LINUX_USER%@%LINUX_IP% '%START_SHELL%'

echo.
echo ==================== 部署成功！====================
pause