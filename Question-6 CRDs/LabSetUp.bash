#!/bin/bash
set -euo pipefail

echo "🔹 Creating namespace: cert-manager"
kubectl create ns cert-manager --dry-run=client -o yaml | kubectl apply -f -

echo "🔹 Applying cert-manager CRDs..."
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.14.0/cert-manager.crds.yaml

kubectl wait --for=condition=Established crd/certificates.cert-manager.io --timeout=60s
echo "Cert-manager CRDs ready for discovery; no controller is needed for this lab."
