#!/usr/bin/env bash
set -euo pipefail

MINTPY_DIR="${1:?Usage: apply_gacos.sh <mintpy_dir>}"

GACOS_DIR="${2:-/data/gacos}"

cd "${MINTPY_DIR}"

echo "=== Generating GACOS override config ==="

cat > mintpy_gacos.cfg << EOF

mintpy.troposphericDelay.method = gacos
mintpy.troposphericDelay.weatherDir = ${GACOS_DIR}

EOF

echo
echo "=== GACOS config ==="

cat mintpy_gacos.cfg

# ---------------------------------------------------------
# cleanup previous outputs
# ---------------------------------------------------------

echo
echo "=== Cleaning previous GACOS intermediates ==="

rm -f inputs/GACOS.h5

rm -f timeseries_GACOS.h5
rm -f velocity_GACOS.h5

# ---------------------------------------------------------
# run correction
# ---------------------------------------------------------

echo
echo "=== Running GACOS correction ==="

smallbaselineApp.py \
    --dir . \
    --dostep correct_troposphere \
    mintpy_gacos.cfg \
    2>&1 | tee logs/mintpy_gacos.log

# ---------------------------------------------------------
# recompute velocity
# ---------------------------------------------------------

echo
echo "=== Recomputing velocity from GACOS corrected timeseries ==="

timeseries2velocity.py \
    timeseries_GACOS.h5 \
    -o velocity_GACOS.h5 \
    2>&1 | tee -a logs/mintpy_gacos.log

echo
echo "=== GACOS correction completed ==="

echo
echo "Generated outputs:"

ls -lh \
    timeseries_GACOS.h5 \
    velocity_GACOS.h5