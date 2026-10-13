#!/bin/bash

###	适用：CentOS/RHEL/Rocky，已有大量业务容器、不想误删数据；只做检查，不会自动执行升级 / 删除
###	检查项：docker 运行状态、容器列表、挂载卷、镜像、磁盘空间、docker 源、锁文件、内核版本、旧包冲突、备份提示

set -euo pipefail

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}===== Docker Upgrade Pre-Check Script =====${NC}"
echo "Time: $(date)"
echo "============================================"

CHECK_PASS=0
CHECK_WARN=0
CHECK_FAIL=0

# 函数
pass() { echo -e "[${GREEN}PASS${NC}] $1"; ((CHECK_PASS++)); }
warn() { echo -e "[${YELLOW}WARN${NC}] $1"; ((CHECK_WARN++)); }
fail() { echo -e "[${RED}FAIL${NC}] $1"; ((CHECK_FAIL++)); }

# 1. 检测docker是否可调用
echo -e "\n[1/10] Check docker & docker-cli command"
if command -v docker &>/dev/null; then
    docker --version
    pass "docker command exists"
else
    fail "docker command not found"
fi

if command -v dockerd &>/dev/null; then
    pass "dockerd exists"
else
    warn "dockerd not found"
fi

# 2. 检测docker服务状态
echo -e "\n[2/10] Check docker service status"
if systemctl is-active docker &>/dev/null; then
    systemctl status docker --no-pager | head -3
    pass "docker service running"
else
    warn "docker service not active"
fi

# 3. 列出运行中容器（重点：业务容器）
echo -e "\n[3/10] Running containers (重点业务容器，升级前建议暂停/备份)"
RUN_CONT=$(docker ps -q | wc -l)
echo "Running container count: ${RUN_CONT}"
if [ "${RUN_CONT}" -gt 0 ];then
    docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Mounts}}"
    warn "存在 ${RUN_CONT} 个运行容器，升级Docker会重启docker服务，容器会停止！"
else
    pass "No running containers"
fi

# 4. 列出所有volume（持久化数据）
echo -e "\n[4/10] Docker volumes（持久数据卷，升级不会删除，但务必确认备份）"
VOL_CNT=$(docker volume ls -q | wc -l)
echo "Volume count: ${VOL_CNT}"
docker volume ls
pass "Volume list done"

# 5. 磁盘空间检查（/var/lib/docker 是数据根目录）
echo -e "\n[5/10] Disk space for docker root dir"
DOCKER_ROOT=$(docker info --format '{{.DockerRootDir}}' 2>/dev/null || echo "/var/lib/docker")
df -h "${DOCKER_ROOT}"
AVAIL=$(df -P "${DOCKER_ROOT}" | awk 'NR==2 {print $4}')
AVAIL_NUM=$(df -P "${DOCKER_ROOT}" | awk 'NR==2 {print $4}')
if [ "${AVAIL_NUM}" -lt 1048576 ];then
    fail "Docker目录剩余空间小于1G，升级风险高"
else
    pass "Disk space ok"
fi

# 6. 内核版本检查
echo -e "\n[6/10] Kernel version check"
KERN_VER=$(uname -r)
echo "Kernel: ${KERN_VER}"
MAJOR=$(echo ${KERN_VER}|cut -d. -f1)
MINOR=$(echo ${KERN_VER}|cut -d. -f2)
if [ ${MAJOR} -ge 5 ];then
    pass "Kernel >=5.0, satisfy new docker requirement"
elif [ ${MAJOR} -eq 4 ] && [ ${MINOR} -ge 14 ];then
    pass "Kernel 4.14+, basic support"
else
    warn "内核版本偏低，新版docker可能有兼容性问题"
fi

# 7. 检查yum源：docker源是否配置
echo -e "\n[7/10] Check docker yum repo"
if [ -f /etc/yum.repos.d/docker-ce.repo ];then
    pass "docker-ce repo file exists"
else
    warn "docker-ce.repo 不存在，大概率是脚本安装方式，升级方式不一样"
fi

# 8. 检查yum锁/进程占用
echo -e "\n[8/10] Check yum/dnf lock"
if [ -f /var/run/yum.pid ];then
    fail "yum/dnf正在运行，禁止同时升级docker"
else
    pass "No yum lock"
fi

# 9. 查看当前docker安装包（区分yum安装 / 脚本安装）
echo -e "\n[9/10] List docker installed rpm packages"
rpm -qa | grep -E 'docker-ce|docker-ce-cli|containerd.io|docker-compose-plugin'

# 10. containerd状态检查
echo -e "\n[10/10] containerd status"
if systemctl is-active containerd &>/dev/null;then
    pass "containerd running"
else
    warn "containerd not running"
fi

# 汇总 & 风险提示
echo -e "\n============================================"
echo -e "${GREEN}Check Summary: PASS=${CHECK_PASS} WARN=${CHECK_WARN} FAIL=${CHECK_FAIL}${NC}"
echo -e "${YELLOW}===== 重要风险提示 =====${NC}"
echo "1. 升级Docker会重启docker daemon，所有容器会停机（除非设置restart=always，会自动拉起）"
echo "2. 【数据安全】升级本身不会删除 volumes，但强烈建议先备份数据库等核心业务数据"
echo "3. 如果FAIL项不为0，先处理失败项再升级"
echo "4. 脚本仅预检，不会修改任何系统配置"
echo "============================================"

if [ ${CHECK_FAIL} -gt 0 ];then
    echo -e "${RED}>>> 检测到失败项，不建议直接升级！${NC}"
    exit 1
else
    echo -e "${GREEN}>>> 预检无致命错误，可以准备升级（注意业务停机窗口）${NC}"
    exit 0
fi
