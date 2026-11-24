#!/bin/bash
set -euo pipefail
ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
if [[ $# -ne 1 ]]; then
  echo 'Usage: bash scripts/run-question.sh "Question-1 MariaDB-Persistent volume"' >&2
  exit 1
fi
QUESTION_DIR="$ROOT/$1"
[[ -f "$QUESTION_DIR/LabSetUp.bash" && -f "$QUESTION_DIR/Questions.bash" ]] || {
  echo "Question not found: $1" >&2
  exit 1
}
echo "==> Running lab setup for $1 (use a disposable Linux lab)"
cd "$HOME"
bash "$QUESTION_DIR/LabSetUp.bash"
printf '\n==> Question\n'
cat "$QUESTION_DIR/Questions.bash"
printf '\nHints: %s\n' "$QUESTION_DIR/SolutionNotes.bash"
