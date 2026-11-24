#!/bin/bash
set -euo pipefail
systemctl enable --now docker
modprobe br_netfilter
modprobe nf_conntrack
curl -fL --retry 3 https://github.com/Mirantis/cri-dockerd/releases/download/v0.3.20/cri-dockerd_0.3.20.3-0.ubuntu-jammy_amd64.deb -o /root/cri-dockerd.deb
echo "28e7d4be9775bc0f822d597702eec48bd17995a6b3e6fb4afac980bc4267e258  /root/cri-dockerd.deb" | sha256sum -c -
dpkg-deb --info /root/cri-dockerd.deb >/dev/null
echo "Docker ready; install /root/cri-dockerd.deb to complete the task."
