#!/bin/bash

### 配套【恢复脚本】`docker_img_container_restore.sh`，从docker_img_container_full_backup备份目录还原镜像 + 重建容器

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

if [ "$(id -u)" -ne 0 ]; then
    echo -e "${RED}[ERROR] root执行${NC}"
    exit 1
fi

read -p "输入备份目录完整路径(如 /data/docker_backup/full_bk_20261013_153000): " BKDIR
if [ ! -d "${BKDIR}" ];then
    echo "目录不存在"
    exit 1
fi

echo -e "${GREEN}[1] 导入所有镜像tar${NC}"
for f in "${BKDIR}/images/"*.tar; do
    [ -f "$f" ] || continue
    echo "导入: $f"
    docker load -i "$f"
done

echo -e "\n${GREEN}[2] 根据inspect json重建容器（不会自动启动）${NC}"
for jsonfile in "${BKDIR}/containers/inspect/"*.json; do
    [ -f "${jsonfile}" ] || continue
    echo "解析容器配置: ${jsonfile}"
    # 提取docker run参数（简易还原；复杂挂载/网络可自己扩展）
    # 注意：如果原有volume还在才能正常挂载
    docker run $(jq -r '
        .[] |
        "--name \(.Name | ltrimstr("/"))",
        (.HostConfig.PortBindings | to_entries[] | "--publish \(.key | split("/")[0]):\(.value[0].HostPort)"),
        (.Env[] | "--env \(.)"),
        (.HostConfig.Binds[] | "--volume \(.)"),
        "--restart \(.HostConfig.RestartPolicy.Name)",
        .Config.Image
    ' "${jsonfile}") --detach=false >/dev/null 2>&1 || echo "⚠️ 该容器重建失败，需要手动检查配置"
done

echo -e "\n${GREEN}恢复完成，请手动按需docker start容器${NC}"
