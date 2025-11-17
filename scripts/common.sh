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
apt-get install -y docker-ce=18.06.0~ce~3-0~ubuntu containerd.io

# Docker 서비스 시작 및 활성화
systemctl enable docker
systemctl start docker

# vagrant 사용자를 docker 그룹에 추가
usermod -aG docker vagrant

echo "=== Kubernetes 패키지 설치 ==="
# Kubernetes 1.11.10 패키지 직접 다운로드 및 설치
cd /tmp

# CNI 플러그인 다운로드
CNI_VERSION="v0.6.0"
mkdir -p /opt/cni/bin
curl -L "https://github.com/containernetworking/plugins/releases/download/${CNI_VERSION}/cni-plugins-amd64-${CNI_VERSION}.tgz" | tar -C /opt/cni/bin -xz

# crictl 다운로드
CRICTL_VERSION="v1.11.0"
curl -L "https://github.com/kubernetes-sigs/cri-tools/releases/download/${CRICTL_VERSION}/crictl-${CRICTL_VERSION}-linux-amd64.tar.gz" | tar -C /usr/local/bin -xz

# Kubernetes 바이너리 직접 다운로드
K8S_VERSION="v1.11.10"
RELEASE_VERSION="v0.3.0"

# kubeadm, kubelet, kubectl 다운로드
cd /usr/bin
curl -L --remote-name-all https://storage.googleapis.com/kubernetes-release/release/${K8S_VERSION}/bin/linux/amd64/{kubeadm,kubelet,kubectl}
chmod +x {kubeadm,kubelet,kubectl}

# kubelet systemd 서비스 파일 다운로드
curl -sSL "https://raw.githubusercontent.com/kubernetes/kubernetes/${K8S_VERSION}/build/debs/kubelet.service" | sed "s:/usr/bin:/usr/bin:g" > /etc/systemd/system/kubelet.service
mkdir -p /etc/systemd/system/kubelet.service.d
curl -sSL "https://raw.githubusercontent.com/kubernetes/kubernetes/${K8S_VERSION}/build/debs/10-kubeadm.conf" | sed "s:/usr/bin:/usr/bin:g" > /etc/systemd/system/kubelet.service.d/10-kubeadm.conf

# systemd 리로드
systemctl daemon-reload

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