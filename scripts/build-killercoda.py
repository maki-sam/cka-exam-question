#!/usr/bin/env python3
"""Build self-contained Killercoda scenarios from the original question folders."""
import argparse
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SLUGS = ['mariadb-storage', 'argocd', 'sidecar', 'resource-allocation', 'hpa',
         'crds', 'priorityclass', 'cni-network-policy', 'cri-dockerd',
         'taints-tolerations', 'gateway-api', 'ingress', 'network-policy',
         'storage-class', 'etcd-fix', 'nodeport', 'tls-config']
BACKGROUND = '''#!/bin/bash
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
__PREREQUISITES__
cd /root
# Prevent a stalled download or rollout from blocking the terminal indefinitely.
timeout 720 bash /root/cka/setup.sh
touch "$STATE/ready"
'''
CLUSTER = '''for attempt in {1..90}; do
  kubectl --request-timeout=5s get nodes >/dev/null 2>&1 && break
  sleep 2
done
kubectl --request-timeout=10s get nodes
kubectl wait --for=condition=Ready nodes --all --timeout=180s
# The single-node tasks and retained hostPath volume can run on controlplane.
kubectl taint nodes controlplane node-role.kubernetes.io/control-plane:NoSchedule- 2>/dev/null || true
'''
HELM = '''if ! command -v helm >/dev/null; then
  curl -fL --retry 3 https://get.helm.sh/helm-v3.17.3-linux-amd64.tar.gz -o /tmp/helm.tgz
  tar -xzf /tmp/helm.tgz -C /tmp
  install /tmp/linux-amd64/helm /usr/local/bin/helm
fi
'''
FOREGROUND = '''#!/bin/bash
# Foreground scripts are sourced by some terminal integrations: use a subshell.
(
  echo "Preparing the lab. This can take several minutes..."
  for attempt in {1..600}; do
    if [[ -f /tmp/cka-setup/failed ]]; then
      echo "Setup failed. Inspect /tmp/cka-setup/setup.log and reload after fixing the cause."
      tail -n 30 /tmp/cka-setup/setup.log
      exit 1
    fi
    if [[ -f /tmp/cka-setup/ready ]]; then
      echo "Lab ready. Open the task instructions to begin."
      exit 0
    fi
    sleep 2
  done
  echo "Setup timed out. Inspect /tmp/cka-setup/setup.log."
  exit 1
)
'''

def question_markdown(text):
    lines = []
    for line in text.splitlines():
        if line.startswith('#'):
            line = re.sub(r'^#\s?', '', line)
        elif line.strip():
            line = '`' + line.strip() + '`'
        lines.append(line.rstrip())
    return '\n\n'.join(lines).strip() + '\n'


def outputs():
    result = {}
    folders = sorted(ROOT.glob('Question-* *'), key=lambda p: int(p.name.split()[0].split('-')[1]))
    assert len(folders) == len(SLUGS), 'Expected all 17 source labs'
    for folder in folders:
        number = int(folder.name.split()[0].split('-')[1])
        base = Path('scenarios') / f'{number:02d}-{SLUGS[number-1]}'
        title = f'{number:02d}: {folder.name.split(" ", 1)[1]}'
        image = 'ubuntu-4GB' if number == 8 else 'ubuntu' if number == 9 else 'kubernetes-kubeadm-2nodes'
        config = {
            'title': title, 'description': f'CKA practice: {folder.name.split(" ", 1)[1]}',
            'details': {
                'intro': {'text': 'intro.md', 'background': 'background.sh', 'foreground': 'foreground.sh'},
                'steps': [{'title': 'Your task', 'text': 'task.md'},
                          {'title': 'Solution and review', 'text': 'solution.md'}],
                'finish': {'text': 'finish.md'},
                'assets': {'host01': [{'file': 'setup.sh', 'target': '/root/cka/', 'chmod': '+x'}]},
            },
            'backend': {'imageid': image},
        }
        result[base/'index.json'] = json.dumps(config, indent=2) + '\n'
        result[base/'intro.md'] = f'# {title}\n\nWait for **Lab ready** in the terminal before starting. Each scenario uses a fresh, disposable environment.\n\nSetup logs: `/tmp/cka-setup/setup.log`.\n'
        result[base/'task.md'] = question_markdown((folder/'Questions.bash').read_text()) + '\nContinue to **Solution and review** when you want hints. Completion is self-assessed; there is no automatic grading.\n'
        result[base/'solution.md'] = '# Solution and review\n\nRun commands selectively and inspect the results. Replace example values where instructed.\n\n```bash\n' + (folder/'SolutionNotes.bash').read_text().rstrip() + '\n```\n'
        result[base/'finish.md'] = '# Practice complete\n\nReview the resulting resources against every requirement in the task. Restart the scenario for a fresh attempt.\n'
        prerequisites = '' if number in (8, 9) else CLUSTER
        if number in (2, 11):
            prerequisites += HELM
        result[base/'background.sh'] = BACKGROUND.replace('__PREREQUISITES__', prerequisites)
        result[base/'foreground.sh'] = FOREGROUND
        result[base/'assets/setup.sh'] = (folder/'LabSetUp.bash').read_text()
    return result


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--check', action='store_true', help='fail if generated scenarios are stale')
    args = parser.parse_args()
    stale = []
    for relative, content in outputs().items():
        path = ROOT/relative
        if args.check:
            if not path.exists() or path.read_text() != content:
                stale.append(str(relative))
        else:
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_text(content)
            if path.suffix == '.sh':
                path.chmod(0o755)
    if stale:
        parser.exit(1, 'Rebuild scenarios with python3 scripts/build-killercoda.py:\n' + '\n'.join(stale) + '\n')
    print('Checked 17 scenarios.' if args.check else 'Built 17 scenarios in scenarios/.')

if __name__ == '__main__':
    main()
