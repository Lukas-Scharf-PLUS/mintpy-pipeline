#!/usr/bin/env bash
set -euo pipefail

ISCE_DIR="${1:?Usage: run_mintpy_load.sh <isce_dir> <mintpy_dir>}"
MINTPY_DIR="${2:?Usage: run_mintpy_load.sh <isce_dir> <mintpy_dir>}"

mkdir -p "${MINTPY_DIR}"

echo "=== Generating MintPy config ==="

cat > "${MINTPY_DIR}/mintpy.cfg" << EOF
mintpy.load.processor=isce

mintpy.load.metaFile=${ISCE_DIR}/reference/IW*.xml
mintpy.load.baselineDir=${ISCE_DIR}/baselines

mintpy.load.unwFile=${ISCE_DIR}/merged/interferograms/*/filt_fine.unw
mintpy.load.corFile=${ISCE_DIR}/merged/interferograms/*/filt_fine.cor

mintpy.load.demFile=${ISCE_DIR}/merged/geom_reference/hgt.rdr
mintpy.load.lookupYFile=${ISCE_DIR}/merged/geom_reference/lat.rdr
mintpy.load.lookupXFile=${ISCE_DIR}/merged/geom_reference/lon.rdr

mintpy.subset.lalo=48.17:48.23,16.34:16.38

mintpy.troposphericDelay.method=no
EOF

echo "=== MintPy config ==="
cat "${MINTPY_DIR}/mintpy.cfg"

cd "${MINTPY_DIR}"

echo "=== Running MintPy load_data ==="

smallbaselineApp.py mintpy.cfg --end load_data \
  2>&1 | tee "${MINTPY_DIR}/logs/mintpy_load.log"
