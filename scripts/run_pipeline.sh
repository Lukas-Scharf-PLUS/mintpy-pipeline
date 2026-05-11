#!/usr/bin/env bash
set -euo pipefail

ISCE_DIR="${1:?Usage: run_pipeline.sh <isce_dir> <mintpy_dir>}"
MINTPY_DIR="${2:?Usage: run_pipeline.sh <isce_dir> <mintpy_dir>}"

# optional parameters
SUBSET_LALO="${3:-}"

# atmospheric correction
TROPO_METHOD="${4:-no}"
WEATHER_MODEL="${5:-ERA5}"
WEATHER_DIR="${6:-/data/weather}"

mkdir -p "${MINTPY_DIR}/logs"

echo "=== Running MintPy load_data ==="
/scripts/run_mintpy_load.sh \
    "$ISCE_DIR" \
    "$MINTPY_DIR" \
    "$SUBSET_LALO" \
    "$TROPO_METHOD" \
    "$WEATHER_MODEL" \
    "$WEATHER_DIR"

echo "=== Running full MintPy workflow ==="
/scripts/run_mintpy_full.sh "${ISCE_DIR}" "${MINTPY_DIR}"

echo "=== Rendering PNG products ==="
/scripts/render_pngs.sh "${MINTPY_DIR}"

echo "=== Validating outputs ==="

test -f "${MINTPY_DIR}/velocity.h5"
test -f "${MINTPY_DIR}/timeseries.h5"
test -f "${MINTPY_DIR}/temporalCoherence.h5"

echo "=== MintPy pipeline completed successfully ==="