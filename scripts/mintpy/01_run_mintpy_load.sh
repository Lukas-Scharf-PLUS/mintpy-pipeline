#!/usr/bin/env bash
set -euo pipefail

ISCE_DIR="${1:?Usage: run_mintpy_load.sh <isce_dir> <mintpy_dir>}"
MINTPY_DIR="${2:?Usage: run_mintpy_load.sh <isce_dir> <mintpy_dir>}"
SUBSET_LALO="${3:-}"

# parameters for atmosphric correction
TROPO_METHOD="${4:-no}"

# fixed weather settings
WEATHER_MODEL="ERA5"
WEATHER_DIR="/data/weather"

# minimal temporal coherence
MIN_TEMP_COH="${4:-0.7}"


mkdir -p "${MINTPY_DIR}"
mkdir -p "${MINTPY_DIR}/logs"

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

mintpy.networkInversion.minTempCoh=${MIN_TEMP_COH}

mintpy.troposphericDelay.method=${TROPO_METHOD}

EOF

# add lat long parameter when set as parameter
if [[ -n "${SUBSET_LALO}" ]]; then
    echo "mintpy.subset.lalo=${SUBSET_LALO}" >> "${MINTPY_DIR}/mintpy.cfg"
fi

# add weather model parameters when set
if [[ "${TROPO_METHOD}" == "pyaps" ]]; then
    cat >> "${MINTPY_DIR}/mintpy.cfg" << EOF

mintpy.troposphericDelay.weatherModel=${WEATHER_MODEL}
mintpy.troposphericDelay.weatherDir=${WEATHER_DIR}
EOF
fi

echo "=== MintPy config ==="
cat "${MINTPY_DIR}/mintpy.cfg"


# go this mintpy dir
cd "${MINTPY_DIR}"

# running the data loading step of mintpy
echo "=== Running MintPy load_data ==="

smallbaselineApp.py mintpy.cfg --end load_data \
  2>&1 | tee "${MINTPY_DIR}/logs/mintpy_load.log"
