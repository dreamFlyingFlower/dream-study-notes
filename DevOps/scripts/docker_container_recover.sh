#!/bin/bash

### volumn迁移到新服务器,容器迁移,镜像导入

# 创建同名volume
docker volume create 你的卷名

# 解压备份进volume
docker run --rm \
  -v "${VOL_NAME}:/target" \
  -v /data:/src \
  alpine sh -c "rm -rf /target/* && tar -xzf /src/${VOL_NAME}_xxxx.tar.gz -C /target"

docker load -i mysql.tar
# 用inspect json解析参数重建（和之前恢复脚本一致）
