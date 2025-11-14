#!/bin/bash

# 마스터 노드 초기화 스크립트

set -e

echo "=== Kubernetes 마스터 노드 초기화 ==="

# kubeadm으로 클러스터 초기화 (Calico를 위한 pod-network-cidr 설정)
kubeadm init \
  --apiserver-advertise-address=192.168.56.10 \
  --pod-network-cidr=192.168.0.0/16 \
  --kubernetes-version=v1.11.10

echo "=== kubectl 설정 ==="
# vagrant 사용자를 위한 kubectl 설정
mkdir -p /home/vagrant/.kube
cp -i /etc/kubernetes/admin.conf /home/vagrant/.kube/config
chown vagrant:vagrant /home/vagrant/.kube/config

# root 사용자를 위한 kubectl 설정
export KUBECONFIG=/etc/kubernetes/admin.conf
mkdir -p /root/.kube
cp -i /etc/kubernetes/admin.conf /root/.kube/config

echo "=== Calico CNI 설치 ==="
# Calico v3.2 설치 (Kubernetes 1.11 호환)
kubectl apply -f https://docs.projectcalico.org/v3.2/getting-started/kubernetes/installation/hosted/rbac-kdd.yaml
kubectl apply -f https://docs.projectcalico.org/v3.2/getting-started/kubernetes/installation/hosted/kubernetes-datastore/calico-networking/1.7/calico.yaml

echo "=== 조인 토큰 생성 및 저장 ==="
# 워커 노드가 참조할 수 있도록 조인 명령어 저장
kubeadm token create --print-join-command > /vagrant/join-command.sh
chmod +x /vagrant/join-command.sh

echo "=== 마스터 노드 단독 스케줄링 허용 (선택사항) ==="
# 작은 클러스터에서 마스터에도 파드 스케줄링을 허용하려면 아래 주석 해제
# kubectl taint nodes --all node-role.kubernetes.io/master-

echo "=== 마스터 노드 초기화 완료 ==="
echo "워커 노드에서 다음 명령어로 클러스터에 참여할 수 있습니다:"
cat /vagrant/join-command.sh

echo "=== 클러스터 상태 확인 ==="
sleep 30
kubectl get nodes
kubectl get pods --all-namespaces