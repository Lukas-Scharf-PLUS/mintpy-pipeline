#!/usr/bin/env bash
set -euo pipefail

MINTPY_DIR="${1:?Usage: standardized_geocode.sh <mintpy_dir> <subset_lalo>}"

SUBSET_LALO="${2:?Missing subset_lalo}"

# optional output resolution in degree
LAT_STEP="${3:-0.0001}"
LON_STEP="${4:-0.0001}"

OUTDIR="${MINTPY_DIR}/geo_standardized"

mkdir -p \
    "${OUTDIR}/base" \
    "${OUTDIR}/ERA5" \
    "${OUTDIR}/GACOS"

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

# =========================================================
# helper function
# =========================================================

geocode_one() {

    INPUT_FILE="$1"
    OUTPUT_SUBDIR="$2"

    if [[ ! -f "${INPUT_FILE}" ]]; then
        return 0
    fi

    BASENAME=$(basename "${INPUT_FILE}" .h5)

    echo
    echo "=== Geocoding ${INPUT_FILE} ==="

    geocode.py \
        "${INPUT_FILE}" \
        -l "${LOOKUP_FILE}" \
        --bbox "${SOUTH}" "${NORTH}" "${WEST}" "${EAST}" \
        --lalo-step "${LAT_STEP}" "${LON_STEP}" \
        --outdir "${OUTDIR}/${OUTPUT_SUBDIR}" \
        --update
}

# =========================================================
# BASE PRODUCTS
# =========================================================

echo
echo "========================================="
echo "BASE PRODUCTS"
echo "========================================="

geocode_one "velocity.h5"              "base"
geocode_one "timeseries.h5"            "base"
geocode_one "timeseries_demErr.h5"     "base"

geocode_one "temporalCoherence.h5"     "base"
geocode_one "maskTempCoh.h5"           "base"
geocode_one "avgSpatialCoh.h5"         "base"

geocode_one "inputs/geometryRadar.h5"  "base"

# =========================================================
# ERA5 PRODUCTS
# =========================================================

echo
echo "========================================="
echo "ERA5 PRODUCTS"
echo "========================================="

geocode_one "timeseries_ERA5.h5"       "ERA5"
geocode_one "velocity_ERA5.h5"         "ERA5"

# optional shared layers
geocode_one "temporalCoherence.h5"     "ERA5"
geocode_one "maskTempCoh.h5"           "ERA5"

# =========================================================
# GACOS PRODUCTS
# =========================================================

echo
echo "========================================="
echo "GACOS PRODUCTS"
echo "========================================="

geocode_one "timeseries_GACOS.h5"      "GACOS"
geocode_one "velocity_GACOS.h5"        "GACOS"

# optional shared layers
geocode_one "temporalCoherence.h5"     "GACOS"
geocode_one "maskTempCoh.h5"           "GACOS"

echo
echo "=== Geocoding completed ==="

echo
echo "Generated structure:"

find "${OUTDIR}" -maxdepth 2 -type f | sort