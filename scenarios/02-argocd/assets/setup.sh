#!/bin/bash
set -euo pipefail
for crd in applications applicationsets appprojects; do
  kubectl apply --server-side -f "https://raw.githubusercontent.com/argoproj/argo-cd/v2.13.0/manifests/crds/${crd}-crd.yaml"
done
kubectl wait --for=condition=Established crd/applications.argoproj.io --timeout=60s
