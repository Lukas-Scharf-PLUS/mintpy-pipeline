#!/usr/bin/env bash
set -euo pipefail

ISCE_DIR="${1:?Usage: run_mintpy_load.sh <isce_dir> <mintpy_dir>}"
MINTPY_DIR="${2:?Usage: run_mintpy_load.sh <isce_dir> <mintpy_dir>}"
SUBSET_LALO="${3:-}"

# parameter for reference point
REF_LALO="${4:-}"

# minimal temporal coherence
MIN_TEMP_COH="${5:-0.7}"

TROPO_METHOD="${6:-no}"


mkdir -p "${MINTPY_DIR}"
mkdir -p "${MINTPY_DIR}/logs"


STACK_DIR=$(find "${ISCE_DIR}" \
    -maxdepth 1 \
    -type d \
    -name "stack_*" | head -1)

if [[ -z "${STACK_DIR}" ]]; then
    echo "ERROR: No stack_* directory found under ${ISCE_DIR}"
    exit 1
fi

echo "Using stack dir: $STACK_DIR"

echo "=== Generating MintPy config ==="

# set same SNWE as subset lalo
if [[ -n "${SUBSET_LALO}" ]]; then
    SNWE=$(echo "${SUBSET_LALO}" | sed 's/:/,/g')
fi

cat > "${MINTPY_DIR}/mintpy.cfg" << EOF
mintpy.load.processor=isce

mintpy.load.metaFile=${STACK_DIR}/reference/IW*.xml
mintpy.load.baselineDir=${STACK_DIR}/baselines

mintpy.load.unwFile=${STACK_DIR}/merged/interferograms/*/filt_fine.unw
mintpy.load.corFile=${STACK_DIR}/merged/interferograms/*/filt_fine.cor

mintpy.load.demFile=${STACK_DIR}/merged/geom_reference/hgt.rdr
mintpy.load.lookupYFile=${STACK_DIR}/merged/geom_reference/lat.rdr
mintpy.load.lookupXFile=${STACK_DIR}/merged/geom_reference/lon.rdr

mintpy.networkInversion.minTempCoh=${MIN_TEMP_COH}

mintpy.deramp=linear

mintpy.troposphericDelay.method = ${TROPO_METHOD}


mintpy.geocode              = yes
mintpy.geocode.laloStep     = -0.0001,0.0001
mintpy.geocode.interpMethod = nearest
mintpy.geocode.fillValue    = np.nan

EOF

# add common reference point coordinates
if [[ -n "${REF_LALO}" ]]; then
    echo "mintpy.reference.lalo=${REF_LALO}" >> "${MINTPY_DIR}/mintpy.cfg"
fi

# add lat long parameter when set as parameter
if [[ -n "${SUBSET_LALO}" ]]; then
    echo "mintpy.subset.lalo=${SUBSET_LALO}" >> "${MINTPY_DIR}/mintpy.cfg"
fi

# add tropospheric correction parameters 
if [[ "${TROPO_METHOD}" == "pyaps" ]]; then
    cat >> "${MINTPY_DIR}/mintpy.cfg" << EOF

mintpy.troposphericDelay.weatherModel = ERA5
mintpy.troposphericDelay.weatherDir = /data/ERA5
EOF
fi

# add geocode SNWE
if [[ -n "${SUBSET_LALO}" ]]; then
    echo "mintpy.geocode.SNWE=${SNWE}" >> "${MINTPY_DIR}/mintpy.cfg"
fi


echo "=== MintPy config ==="
cat "${MINTPY_DIR}/mintpy.cfg"


# go this mintpy dir
cd "${MINTPY_DIR}"

# running the data loading step of mintpy
echo "=== Running MintPy load_data ==="

smallbaselineApp.py mintpy.cfg --end load_data \
  2>&1 | tee "${MINTPY_DIR}/logs/mintpy_load.log"
