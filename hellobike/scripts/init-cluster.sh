#!/bin/bash

# 初始化 ai 集群需要设置一些 labels

set -ex

kubectl label namespace anonymous istio-injection-
kubectl label nodes ai-fat-k8s-01 hellobike.com/platform=kubeflow
