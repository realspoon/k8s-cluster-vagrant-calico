#!/bin/bash

# 워커 노드 설정 스크립트

set -e

echo "=== 워커 노드 클러스터 참여 대기 ==="

# 마스터 노드에서 생성된 조인 명령어 파일이 생성될 때까지 대기
echo "마스터 노드 초기화가 완료될 때까지 대기 중..."
while [ ! -f /vagrant/join-command.sh ]; do
    sleep 10
    echo "조인 명령어 파일 대기 중..."
done

echo "=== 클러스터 참여 ==="
# 마스터에서 생성된 조인 명령어 실행
bash /vagrant/join-command.sh

echo "=== 워커 노드 설정 완료 ==="
echo "클러스터 참여가 완료되었습니다."
echo "마스터 노드에서 'kubectl get nodes' 명령어로 확인해주세요."