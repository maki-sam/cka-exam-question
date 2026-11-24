#!/bin/bash
set -euo pipefail
STATE=/tmp/cka-setup
mkdir -p "$STATE"
rm -f "$STATE/ready" "$STATE/failed"
trap 'touch "$STATE/failed"' ERR
exec > >(tee "$STATE/setup.log") 2>&1
# Wait for assets separately from cluster readiness.
for attempt in {1..60}; do
  [[ -f /root/cka/setup.sh ]] && break
  sleep 2
done
test -f /root/cka/setup.sh

cd /root
# Prevent a stalled download or rollout from blocking the terminal indefinitely.
timeout 720 bash /root/cka/setup.sh
touch "$STATE/ready"
