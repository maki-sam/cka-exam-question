#!/usr/bin/env python3
"""Offline validation; never executes cluster setup or touches kubeconfig."""
import json
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

def validate():
    subprocess.run([sys.executable, str(ROOT/'scripts/build-killercoda.py'), '--check'], check=True)
    indexes = sorted((ROOT/'scenarios').glob('*/index.json'))
    assert len(indexes) == 17, 'Expected 17 scenarios'
    supported = {'ubuntu', 'ubuntu-4GB', 'kubernetes-kubeadm-2nodes'}
    for index in indexes:
        config = json.loads(index.read_text())
        assert config['title'] and config['backend']['imageid'] in supported, index
        details = config['details']
        assert details['steps'], index
        for section in [details['intro'], *details['steps'], details['finish']]:
            for key in ('text', 'background', 'foreground', 'verify'):
                if key in section:
                    referenced = index.parent/section[key]
                    assert referenced.is_file() and referenced.stat().st_size, referenced
        for asset in details['assets']['host01']:
            assert (index.parent/'assets'/asset['file']).is_file(), asset
            assert asset['target'].startswith('/'), asset
    scripts = list((ROOT/'scenarios').rglob('*.sh'))
    scripts += list(ROOT.glob('Question-*/LabSetUp.bash'))
    scripts += list(ROOT.glob('Question-*/SolutionNotes.bash'))
    scripts += list((ROOT/'scripts').glob('*.sh'))
    for script in scripts:
        subprocess.run(['bash', '-n', str(script)], check=True)
    subprocess.run(['git', 'diff', '--check'], cwd=ROOT, check=True)
    print(f'PASS: {len(indexes)} scenario configs, referenced assets/pages, {len(scripts)} shell scripts, and generated-file freshness.')
    print('Live setup and solution checks must still be run on Killercoda.')

if __name__ == '__main__':
    validate()
