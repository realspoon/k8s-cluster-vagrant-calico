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

## 시스템 요구사항

### 필수 사항
- **운영체제**: macOS (Intel 프로세서)
- **가상화**: VirtualBox 7.0 이상
- **Vagrant**: 2.4.0 이상
- **메모리**: 최소 8GB RAM (권장 16GB)
- **디스크**: 최소 20GB 여유 공간

### 지원되는 환경
- ✅ Intel 기반 Mac (x86_64)
- ❌ Apple Silicon Mac (M1/M2/M3) - **현재 지원되지 않음**

## 제한사항

### Apple Silicon (M1/M2/M3) Mac 비호환
현재 이 프로젝트는 **Intel 기반 Mac에서만** 작동합니다. Apple Silicon Mac에서는 다음과 같은 문제가 있습니다:

1. **VirtualBox 미지원**: VirtualBox가 Apple Silicon을 공식 지원하지 않습니다
2. **아키텍처 불일치**:
   - 현재 스크립트는 `amd64` (x86_64) 아키텍처용 바이너리를 다운로드합니다
   - Apple Silicon은 `arm64` 아키텍처가 필요합니다
3. **Ubuntu 이미지**: `ubuntu/bionic64` 박스는 x86_64 전용입니다

### Apple Silicon Mac 대안
- **UTM**: ARM64 Ubuntu VM 사용 (무료)
- **Parallels Desktop**: ARM64 가상화 지원 (유료)
- **Docker Desktop + Kind/k3d**: 컨테이너 기반 Kubernetes
- **Multipass**: Canonical의 경량 VM 솔루션

### 기타 주의사항
- 마스터 노드가 완전히 초기화된 후 워커 노드를 시작해야 합니다
- 각 VM은 2GB RAM을 사용하므로 총 4GB RAM이 할당됩니다
- VirtualBox 네트워크 설정으로 인해 방화벽 경고가 나올 수 있습니다
- Kubernetes 1.11은 EOL(End of Life) 버전이므로 프로덕션 환경에서는 사용하지 마세요

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