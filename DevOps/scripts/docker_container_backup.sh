#!/bin/bash

### volumn备份,容器配置导出,镜像导出,适用于volumn直接在docker容器内部的应用
### 如果volumn直接映射在宿主机,即docker run -v /data/mysql:/var/lib/mysql这种,直接备份宿主机的目录,同步到新机器对应路径即可

set -euo pipefail
# 备份指定volume，打包成tar
VOL_NAME="$1"
BACKUP_DIR="/data/docker_volume_bak"
TS=$(date +%Y%m%d_%H%M%S)
mkdir -p "${BACKUP_DIR}"
OUT="${BACKUP_DIR}/${VOL_NAME}_${TS}.tar.gz"

docker run --rm \
  -v "${VOL_NAME}:/source" \
  -v "${BACKUP_DIR}:/dest" \
  alpine tar -czf "/dest/${VOL_NAME}_${TS}.tar.gz" -C /source .

echo "volume ${VOL_NAME} 备份完成：${OUT}"

# 导出容器配置（拿到挂载、端口、环境变量、重启策略）
docker inspect 容器名 > mysql_inspect.json
# 导出镜像
docker save -o mysql.tar mysql:8.0
