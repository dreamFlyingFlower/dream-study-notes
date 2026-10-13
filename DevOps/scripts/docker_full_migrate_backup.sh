#!/bin/bash

### 备份docker volumn,导出inspect json,导出镜像,然后在新服务器恢复
### 1. 镜像：`docker save`
### 2. 容器：inspect json（启动参数、端口、挂载、环境变量）
### 3. Volume：批量备份所有 docker managed volume（docker volume create 出来的卷）
### 4. **bind mount 宿主机目录挂载不会自动备份，这类需要你单独 rsync 同步**
### 5. 备份后可选自动停止运行容器（迁移 / 升级场景）

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# ========== 配置区 ==========
BACKUP_ROOT="/data/docker_migrate_backup"
STOP_RUNNING_CONTAINER=1    # 1=备份完停止运行容器；0=只备份不停
# ============================

if [ "$(id -u)" -ne 0 ]; then
    echo -e "${RED}[ERROR] 必须root执行${NC}"
    exit 1
fi

TS=$(date +%Y%m%d_%H%M%S)
BK_DIR="${BACKUP_ROOT}/migrate_bk_${TS}"
mkdir -p "${BK_DIR}/images" "${BK_DIR}/containers/inspect" "${BK_DIR}/volumes"

echo -e "${GREEN}=============================================${NC}"
echo "Docker全量迁移备份：镜像 + 容器配置 + 全部Volume"
echo "备份路径：${BK_DIR}"
echo -e "${GREEN}=============================================${NC}"

# 清单文件
IMG_LIST="${BK_DIR}/image_list.txt"
CON_LIST="${BK_DIR}/container_list.txt"
VOL_LIST="${BK_DIR}/volume_list.txt"

##############################################################################
# 1. 备份所有镜像
echo -e "\n${YELLOW}[1/3] 备份镜像 docker save${NC}"
IMAGES=$(docker images --format "{{.Repository}}:{{.Tag}}" | grep -v "<none>:<none>")
echo "${IMAGES}" > "${IMG_LIST}"
IMG_CNT=$(echo "${IMAGES}" | wc -l)
echo "镜像总数：${IMG_CNT}"
while IFS= read -r img; do
    [[ -z "${img}" ]] && continue
    safe_name=$(echo "${img}" | tr '/:' '_')
    out="${BK_DIR}/images/${safe_name}.tar"
    echo "save -> ${img}"
    docker save -o "${out}" "${img}"
done <<< "${IMAGES}"

##############################################################################
# 2. 备份所有容器（inspect json）
echo -e "\n${YELLOW}[2/3] 备份容器配置 inspect${NC}"
ALL_CONTAINERS=$(docker ps -a -q)
echo "${ALL_CONTAINERS}" > "${CON_LIST}"
CON_CNT=$(echo "${ALL_CONTAINERS}" | wc -l)
echo "容器总数：${CON_CNT}"
for cid in ${ALL_CONTAINERS}; do
    cname=$(docker inspect --format '{{.Name}}' "${cid}" | sed 's/^\///')
    running=$(docker inspect --format '{{.State.Running}}' "${cid}")
    echo "容器：${cname} [${cid}]"
    docker inspect "${cid}" > "${BK_DIR}/containers/inspect/${cname}_${cid}.json"

    if [[ ${STOP_RUNNING_CONTAINER} -eq 1 && "${running}" == "true" ]]; then
        docker stop "${cid}"
        echo "  -> 已停止容器"
    fi
done

##############################################################################
# 3. 批量备份全部docker volume
echo -e "\n${YELLOW}[3/3] 批量备份所有Volume${NC}"
ALL_VOLS=$(docker volume ls -q)
echo "${ALL_VOLS}" > "${VOL_LIST}"
VOL_CNT=$(echo "${ALL_VOLS}" | wc -l)
echo "Volume总数：${VOL_CNT}"
for vol in ${ALL_VOLS}; do
    echo "备份volume: ${vol}"
    docker run --rm \
        -v "${vol}:/srcvol" \
        -v "${BK_DIR}/volumes:/bkdest" \
        alpine tar -czf "/bkdest/${vol}.tar.gz" -C /srcvol .
done

##############################################################################
# 额外备份daemon.json
if [ -f /etc/docker/daemon.json ]; then
    cp /etc/docker/daemon.json "${BK_DIR}/daemon.json.bak"
    echo -e "\n✅ daemon.json配置已备份"
fi

echo -e "\n${GREEN}==== 全部备份完成 ====${NC}"
echo "备份目录：${BK_DIR}"
echo "镜像清单：${IMG_LIST}"
echo "容器清单：${CON_LIST}"
echo "Volume清单：${VOL_LIST}"
echo -e "${YELLOW}重要提醒：${NC}"
echo "1. 仅备份docker管理volume，bind mount（宿主机目录挂载）需要单独rsync同步"
echo "2. 迁移时：先恢复volume，再导入镜像，最后重建容器"
echo "3. 自定义docker网络，目标机器需要提前手动创建同名网络"
