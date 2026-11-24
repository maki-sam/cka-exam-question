#!/bin/bash
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
