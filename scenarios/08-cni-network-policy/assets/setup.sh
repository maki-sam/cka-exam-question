#!/bin/bash
set -euo pipefail
systemctl start docker
curl -fL --retry 3 https://kind.sigs.k8s.io/dl/v0.33.0/kind-linux-amd64 -o /usr/local/bin/kind
chmod +x /usr/local/bin/kind
curl -fL --retry 3 https://dl.k8s.io/release/v1.35.0/bin/linux/amd64/kubectl -o /usr/local/bin/kubectl
chmod +x /usr/local/bin/kubectl
cat > /root/kind-cni.yaml <<'EOF'
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
networking:
  disableDefaultCNI: true
  podSubnet: 192.168.0.0/16
nodes:
- role: control-plane
EOF
kind create cluster --name cni-lab --image kindest/node:v1.35.0 --config /root/kind-cni.yaml
kubectl cluster-info --context kind-cni-lab
# NotReady is intentional: installing the CNI is the exercise.
echo "Use context kind-cni-lab. The node will be NotReady until you install a CNI."
