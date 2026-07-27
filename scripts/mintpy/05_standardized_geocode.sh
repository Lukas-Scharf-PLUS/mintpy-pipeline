#!/usr/bin/env bash
set -euo pipefail

MINTPY_DIR="${1:?Usage: standardized_geocode.sh <mintpy_dir> <subset_lalo>}"
SUBSET_LALO="${2:?Missing subset_lalo}"

LAT_STEP="${3:-0.0001}"
LON_STEP="${4:-0.0001}"

OUTDIR="${MINTPY_DIR}/geo_standardized"
mkdir -p "${OUTDIR}"

cd "${MINTPY_DIR}"

LOOKUP_FILE="inputs/geometryRadar.h5"

# ---------------------------------------------------------
# convert subset_lalo -> SNWE
# ---------------------------------------------------------

LAT_PART=$(echo "${SUBSET_LALO}" | cut -d',' -f1)
LON_PART=$(echo "${SUBSET_LALO}" | cut -d',' -f2)

SOUTH=$(echo "${LAT_PART}" | cut -d':' -f1)
NORTH=$(echo "${LAT_PART}" | cut -d':' -f2)

WEST=$(echo "${LON_PART}" | cut -d':' -f1)
EAST=$(echo "${LON_PART}" | cut -d':' -f2)

echo "Using bbox:"
echo "SOUTH=${SOUTH}"
echo "NORTH=${NORTH}"
echo "WEST=${WEST}"
echo "EAST=${EAST}"

# ---------------------------------------------------------
# helper
# ---------------------------------------------------------

geocode_one() {

    local INPUT_FILE="$1"

    if [[ ! -f "${INPUT_FILE}" ]]; then
        return 0
    fi

    echo
    echo "=== Geocoding ${INPUT_FILE} ==="

    geocode.py \
        "${INPUT_FILE}" \
        -l "${LOOKUP_FILE}" \
        --bbox "${SOUTH}" "${NORTH}" "${WEST}" "${EAST}" \
        --lalo-step "${LAT_STEP}" "${LON_STEP}" \
        --outdir "${OUTDIR}" \
        --update
}

# ---------------------------------------------------------
# standard MintPy outputs
# ---------------------------------------------------------

geocode_one "velocity.h5"
geocode_one "timeseries.h5"
geocode_one "timeseries_demErr.h5"

geocode_one "temporalCoherence.h5"
geocode_one "maskTempCoh.h5"
geocode_one "avgSpatialCoh.h5"

# ---------------------------------------------------------
# optional atmospheric correction outputs
# ---------------------------------------------------------

geocode_one "velocityERA5.h5"
geocode_one "timeseries_ERA5.h5"
geocode_one "timeseries_ERA5_demErr.h5"



# ---------------------------------------------------------
# geometry
# ---------------------------------------------------------

geocode_one "inputs/geometryRadar.h5"

echo
echo "=== Geocoding completed ==="

find "${OUTDIR}" -maxdepth 1 -type f | sort