# Kubernetes 1.11 클러스터 (마스터 1대 + 워커 1대)

macOS 환경에서 Vagrant와 VirtualBox를 사용하여 Kubernetes 1.11 클러스터를 구성합니다.

## 구성

- **마스터 노드**: k8s-master (192.168.56.10)
- **워커 노드**: k8s-worker (192.168.56.11)
- **CNI**: Calico v3.2
- **Kubernetes 버전**: 1.11.10

## 사용 방법

### 1. 클러스터 시작

```bash
# 마스터 노드 먼저 시작
vagrant up k8s-master

# 워커 노드 시작 (마스터가 완전히 초기화된 후)
vagrant up k8s-worker
```

### 2. 마스터 노드 접속 및 확인

```bash
# 마스터 노드 접속
vagrant ssh k8s-master

# 클러스터 상태 확인
kubectl get nodes
kubectl get pods --all-namespaces
```

### 3. 기본 테스트

```bash
# 멀티노드 디플로이먼트 테스트
kubectl apply -f /vagrant/test-deployment.yaml

# 파드가 각 노드에 분산되어 배포되는지 확인
kubectl get pods -o wide

# 서비스 확인
kubectl get services
```

### 4. Calico NetworkPolicy 테스트

```bash
# 네트워크 정책 테스트 리소스 생성
kubectl apply -f /vagrant/network-policy-test.yaml

# 정책 확인
kubectl get networkpolicies -n policy-test

# 테스트용 파드에서 연결 테스트
kubectl exec -n policy-test -it deployment/web-app -- curl database-service:5432
```

## 주요 명령어

### 클러스터 관리

```bash
# 노드 상태 확인
kubectl get nodes

# 모든 네임스페이스의 파드 확인
kubectl get pods --all-namespaces

# 클러스터 정보 확인
kubectl cluster-info
```

### Calico 관리

```bash
# Calico 파드 상태 확인
kubectl get pods -n kube-system | grep calico

# 네트워크 정책 확인
kubectl get networkpolicies --all-namespaces
```

### 트러블슈팅

```bash
# 노드 상세 정보 확인
kubectl describe node <node-name>

# 파드 로그 확인
kubectl logs -n kube-system <calico-pod-name>

# 이벤트 확인
kubectl get events --all-namespaces --sort-by=.metadata.creationTimestamp
```

## 정리

```bash
# VM 정지
vagrant halt

# VM 삭제
vagrant destroy
```

## 주의사항

- 마스터 노드가 완전히 초기화된 후 워커 노드를 시작해야 합니다
- 각 VM은 2GB RAM을 사용하므로 충분한 메모리가 필요합니다
- VirtualBox 네트워크 설정으로 인해 방화벽 경고가 나올 수 있습니다

## 파일 구조

```
.
├── Vagrantfile              # Vagrant 설정 파일
├── scripts/
│   ├── common.sh            # 공통 설정 스크립트
│   ├── master.sh            # 마스터 노드 초기화
│   └── worker.sh            # 워커 노드 설정
├── test-deployment.yaml     # 기본 테스트용 디플로이먼트
├── network-policy-test.yaml # NetworkPolicy 테스트용 리소스
└── README.md               # 이 파일
```