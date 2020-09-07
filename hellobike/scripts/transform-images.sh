#!/bin/bash

# 将一个镜像列表文件转换成 hellobike 的镜像，push 到阿里云的镜像仓库
# 如 gcr.io/istio-release/kubectl:release-1.3-latest-daily -> registry.cn-hangzhou.aliyuncs.com/hellobike-public/kubectl:release-1.3-latest-daily

set -ex

filename=$1
prefix=registry.cn-hangzhou.aliyuncs.com/hellobike-public/

while read -r line; do
    # tag="${line##*:}"
    postfix="${line##*/}"
    newImage=${prefix}${postfix}

    docker pull "${line}"
    docker tag "${line}" "${newImage}"
    docker push "${newImage}"

done < "${filename}"
