#!/usr/bin/env bash
set -euo pipefail

MINTPY_DIR="${1:?Usage: geocode.sh <mintpy_dir> <south> <north> <west> <east>}"

SOUTH="${2:?Missing south}"
NORTH="${3:?Missing north}"
WEST="${4:?Missing west}"
EAST="${5:?Missing east}"


# optional output resolution in degree
LAT_STEP="${6:-0.0001}"
LON_STEP="${7:-0.0001}"

mkdir -p "${MINTPY_DIR}/geo_web"

echo "=== Geocoding MintPy products ==="

cd "${MINTPY_DIR}"

LOOKUP_FILE="${MINTPY_DIR}/inputs/geometryRadar.h5"

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

# optional ERA5 products
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
        --outdir "${MINTPY_DIR}/geo_web" \
        --update

done

echo
echo "=== Geocoding completed ==="