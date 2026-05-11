#!/usr/bin/env bash
set -euo pipefail

MINTPY_DIR="${1:?Usage: render_pngs.sh <mintpy_dir>}"

cd "${MINTPY_DIR}"

mkdir -p png

echo "=== Rendering velocity PNG ==="

view.py velocity.h5 velocity \
  --save \
  -o png/velocity.png

echo "=== Rendering temporal coherence PNG ==="

view.py temporalCoherence.h5 temporalCoherence \
  --save \
  -o png/temporalCoherence.png

echo "=== Rendering average spatial coherence PNG ==="

view.py avgSpatialCoh.h5 coherence \
  --save \
  -o png/avgSpatialCoh.png

echo "=== PNG rendering completed ==="