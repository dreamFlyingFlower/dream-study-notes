#!/bin/bash

### 自动备份全部镜像 tar 包 + 全部容器(inspect 配置 + 容器快照导出)

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# ========== 配置区 ==========
BACKUP_ROOT="/data/docker_backup"
# 备份后是否自动停止运行中的容器（升级Docker需要，1开启 0关闭）
STOP_RUNNING_CONTAINER=1
# ============================

if [ "$(id -u)" -ne 0 ]; then
    echo -e "${RED}[ERROR] 需要root权限执行${NC}"
    exit 1
fi

TS=$(date +%Y%m%d_%H%M%S)
BK_DIR="${BACKUP_ROOT}/full_bk_${TS}"
mkdir -p "${BK_DIR}/images" "${BK_DIR}/containers/inspect" "${BK_DIR}/containers/export"

echo -e "${GREEN}====================================${NC}"
echo "Docker 镜像+容器全量备份开始"
echo "备份目录: ${BK_DIR}"
echo -e "${GREEN}====================================${NC}"

# 保存清单文件
IMG_LIST="${BK_DIR}/image_list.txt"
CONTAINER_LIST="${BK_DIR}/container_list.txt"

# 1. 备份所有镜像
echo -e "\n[1/2] 开始备份镜像"
IMAGES=$(docker images --format "{{.Repository}}:{{.Tag}}" | grep -v "<none>:<none>")
echo "${IMAGES}" > "${IMG_LIST}"
IMG_COUNT=$(echo "${IMAGES}" | wc -l)
echo "待备份镜像数量: ${IMG_COUNT}"

while IFS= read -r img; do
    if [ -z "${img}" ]; then continue; fi
    safe_name=$(echo "${img}" | tr '/:' '_')
    tar_path="${BK_DIR}/images/${safe_name}.tar"
    echo "备份镜像: ${img}  -> ${safe_name}.tar"
    docker save -o "${tar_path}" "${img}"
done <<< "${IMAGES}"

# 2. 备份所有容器（inspect配置 + export文件系统快照）
echo -e "\n[2/2] 开始备份容器"
ALL_CONTAINERS=$(docker ps -a -q)
echo "${ALL_CONTAINERS}" > "${CONTAINER_LIST}"
CON_CNT=$(echo "${ALL_CONTAINERS}" | wc -l)
echo "待备份容器数量: ${CON_CNT}"

for cid in ${ALL_CONTAINERS}; do
    cname=$(docker inspect --format '{{.Name}}' "${cid}" | sed 's/^\///')
    running=$(docker inspect --format '{{.State.Running}}' "${cid}")
    echo -e "\n--- 容器 ${cname} [${cid}] ---"

    # 导出容器配置JSON（恢复启动参数必备）
    docker inspect "${cid}" > "${BK_DIR}/containers/inspect/${cname}_${cid}.json"
    echo "✅ inspect配置已保存"

    # 导出容器文件系统快照
    docker export -o "${BK_DIR}/containers/export/${cname}_${cid}.tar" "${cid}"
    echo "✅ 容器文件快照导出完成"

    # 可选：备份后停止容器（升级docker前）
    if [ "${STOP_RUNNING_CONTAINER}" -eq 1 ] && [ "${running}" = "true" ]; then
        docker stop "${cid}"
        echo "✅ 容器已停止"
    fi
done

# 额外备份daemon.json
if [ -f /etc/docker/daemon.json ]; then
    cp /etc/docker/daemon.json "${BK_DIR}/daemon.json.bak"
    echo -e "\n✅ daemon.json 配置已备份"
fi

echo -e "\n${GREEN}===== 备份全部完成 =====${NC}"
echo "备份目录：${BK_DIR}"
echo "镜像清单：${IMG_LIST}"
echo "容器清单：${CONTAINER_LIST}"
echo -e "${YELLOW}提醒：export容器快照不会备份volume内数据，数据库卷请单独备份！${NC}"
