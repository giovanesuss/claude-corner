#!/bin/bash
# TEST: .sh entry — exercises the 'code' render mode (highlight.js, language: bash)

set -euo pipefail

NAME="${1:-corner}"
COUNT=3

for i in $(seq 1 "$COUNT"); do
    echo "Hello, $NAME! (#$i)"
done

if [ -d "$HOME/claude-corner" ]; then
    echo "Corner directory exists."
fi
