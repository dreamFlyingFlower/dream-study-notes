#!/bin/bash

### 恢复docker volumn,容器,镜像
### 恢复脚本依赖 jq，目标机器提前装：`dnf install -y jq`

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

if [ "$(id -u)" -ne 0 ]; then
    echo -e "${RED}[ERROR] 需要root执行${NC}"
    exit 1
fi

read -p "输入备份目录完整路径: " BKDIR
[[ ! -d "${BKDIR}" ]] && { echo "目录不存在"; exit 1; }

# 1. 恢复Volume
echo -e "\n${GREEN}[1/3] 恢复所有Volume${NC}"
VOL_FILE="${BKDIR}/volume_list.txt"
while IFS= read -r vol; do
    [[ -z "${vol}" ]] && continue
    tgz="${BKDIR}/volumes/${vol}.tar.gz"
    if [[ ! -f "${tgz}" ]]; then
        echo "⚠️ ${vol} 备份包缺失，跳过"
        continue
    fi
    echo "恢复 volume: ${vol}"
    docker volume create "${vol}"
    docker run --rm \
        -v "${vol}:/targetvol" \
        -v "${BKDIR}/volumes:/srcbk" \
        alpine sh -c "rm -rf /targetvol/* && tar -xzf /srcbk/${vol}.tar.gz -C /targetvol"
done < "${VOL_FILE}"

# 2. 导入镜像
echo -e "\n${GREEN}[2/3] 导入镜像${NC}"
for tarfile in "${BKDIR}/images/"*.tar; do
    [[ -f "${tarfile}" ]] || continue
    echo "load镜像: ${tarfile}"
    docker load -i "${tarfile}"
done

# 3. 重建容器（根据inspect json，不自动启动）
echo -e "\n${GREEN}[3/3] 重建容器（不会自动启动）${NC}"
for json in "${BKDIR}/containers/inspect/"*.json; do
    [[ -f "${json}" ]] || continue
    echo "重建容器: ${json}"
    # 解析参数重建，依赖jq
    docker run $(jq -r '
        .[] |
        "--name \(.Name | ltrimstr("/"))",
        (.HostConfig.PortBindings | to_entries[] | "--publish \(.key | split("/")[0]):\(.value[0].HostPort)"),
        (.Env[] | "--env \(.)"),
        (.HostConfig.Binds[] | "--volume \(.)"),
        "--restart \(.HostConfig.RestartPolicy.Name)",
        (.NetworkSettings.Networks | keys[] | select(. != "bridge") | "--network \(.)"),
        .Config.Image
    ' "${json}") --detach=false >/dev/null 2>&1 || echo "⚠️ 容器重建异常，请手动核对json"
done

echo -e "\n${GREEN}✅ 恢复脚本执行完毕，手动 docker start 按需启动容器${NC}"
echo "提示：自定义网络如果重建失败，先在目标机器创建同名docker network"
