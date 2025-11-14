#!/bin/bash

# 공통 설정 스크립트 - 마스터와 워커 노드에서 모두 실행

set -e

echo "=== 시스템 업데이트 및 필수 패키지 설치 ==="
apt-get update
apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release

echo "=== Docker 설치 ==="
# Docker GPG 키 추가
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -

# Docker 저장소 추가
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

# Docker CE 18.06 설치 (Kubernetes 1.11과 호환)
apt-get update
apt-get install -y docker-ce=5:18.06.3~ce~3-0~ubuntu containerd.io

# Docker 서비스 시작 및 활성화
systemctl enable docker
systemctl start docker

# vagrant 사용자를 docker 그룹에 추가
usermod -aG docker vagrant

echo "=== Kubernetes 패키지 설치 ==="
# Kubernetes GPG 키 추가
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -

# Kubernetes 저장소 추가
cat <<EOF > /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF

# 패키지 목록 업데이트
apt-get update

# Kubernetes 1.11.x 버전 설치
K8S_VERSION="1.11.10-00"
apt-get install -y kubelet=$K8S_VERSION kubeadm=$K8S_VERSION kubectl=$K8S_VERSION

# 패키지 자동 업데이트 방지
apt-mark hold kubelet kubeadm kubectl

echo "=== 시스템 설정 ==="
# swap 비활성화
swapoff -a
sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

# 필요한 커널 모듈 로드
modprobe br_netfilter

# sysctl 설정
cat <<EOF > /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl --system

# kubelet 서비스 활성화 (아직 시작하지 않음)
systemctl enable kubelet

echo "=== 공통 설정 완료 ==="