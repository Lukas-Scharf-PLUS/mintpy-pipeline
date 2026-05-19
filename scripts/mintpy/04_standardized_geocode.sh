#!/usr/bin/env bash
set -euo pipefail

MINTPY_DIR="${1:?Usage: standardized_geocode.sh <mintpy_dir> <subset_lalo>}"

SUBSET_LALO="${2:?Missing subset_lalo}"

# optional output resolution in degree
LAT_STEP="${3:-0.0001}"
LON_STEP="${4:-0.0001}"

mkdir -p "${MINTPY_DIR}/geo_standardized"

echo "=== Geocoding MintPy products ==="

cd "${MINTPY_DIR}"

LOOKUP_FILE="${MINTPY_DIR}/inputs/geometryRadar.h5"

# ---------------------------------------------------------
# convert MintPy subset format to SNWE
# format:
# 48.17:48.23,16.34:16.38
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
# choose products dynamically
# ---------------------------------------------------------

PRODUCTS=()

[[ -f velocity.h5 ]] && PRODUCTS+=("velocity.h5")
[[ -f temporalCoherence.h5 ]] && PRODUCTS+=("temporalCoherence.h5")
[[ -f maskTempCoh.h5 ]] && PRODUCTS+=("maskTempCoh.h5")
[[ -f avgSpatialCoh.h5 ]] && PRODUCTS+=("avgSpatialCoh.h5")
[[ -f inputs/geometryRadar.h5 ]] && PRODUCTS+=("inputs/geometryRadar.h5")

[[ -f timeseries.h5 ]] && PRODUCTS+=("timeseries.h5")
[[ -f timeseries_demErr.h5 ]] && PRODUCTS+=("timeseries_demErr.h5")

[[ -f timeseries_ERA5.h5 ]] && PRODUCTS+=("timeseries_ERA5.h5")
[[ -f velocity_ERA5.h5 ]] && PRODUCTS+=("velocity_ERA5.h5")

echo "Products to geocode:"
printf '  %s\n' "${PRODUCTS[@]}"

# ---------------------------------------------------------
# geocode
# ---------------------------------------------------------

for FILE in "${PRODUCTS[@]}"; do

    BASENAME=$(basename "${FILE}" .h5)

    echo
    echo "=== Geocoding ${FILE} ==="

    geocode.py \
        "${FILE}" \
        -l "${LOOKUP_FILE}" \
        --bbox "${SOUTH}" "${NORTH}" "${WEST}" "${EAST}" \
        --lalo-step "${LAT_STEP}" "${LON_STEP}" \
        --outdir "${MINTPY_DIR}/geo_standardized" \
        --update

done

echo
echo "=== Geocoding completed ==="