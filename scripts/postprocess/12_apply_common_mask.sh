#!/usr/bin/env bash
set -euo pipefail

ASC_DIR="${1:?Usage: apply_common_mask.sh <asc_mintpy_dir> <desc_mintpy_dir> <common_mask_file>}"
DESC_DIR="${2:?Usage: apply_common_mask.sh <asc_mintpy_dir> <desc_mintpy_dir> <common_mask_file>}"
COMMON_MASK="${3:?Usage: apply_common_mask.sh <asc_mintpy_dir> <desc_mintpy_dir> <common_mask_file>}"

ASC_GEO_DIR="${ASC_DIR}/geo_standardized"
DESC_GEO_DIR="${DESC_DIR}/geo_standardized"

echo "=== Applying common ASC/DESC mask ==="

echo
echo "Common mask:"
echo "${COMMON_MASK}"

# ---------------------------------------------------------
# validate mask
# ---------------------------------------------------------

if [[ ! -f "${COMMON_MASK}" ]]; then
    echo
    echo "ERROR: Common mask not found"
    exit 1
fi

# ---------------------------------------------------------
# helper function
# ---------------------------------------------------------

apply_mask () {

    INPUT_FILE="$1"
    OUTPUT_FILE="$2"

    if [[ -f "${INPUT_FILE}" ]]; then

        echo
        echo "=== Masking ${INPUT_FILE} ==="

        mask.py \
            "${INPUT_FILE}" \
            -m "${COMMON_MASK}" \
            -o "${OUTPUT_FILE}"

    else

        echo
        echo "Skipping ${INPUT_FILE} (not found)"

    fi
}

# =========================================================
# ASCENDING PRODUCTS
# =========================================================

echo
echo "========================================="
echo "ASCENDING PRODUCTS"
echo "========================================="

cd "${ASC_GEO_DIR}"

apply_mask \
    "geo_velocity.h5" \
    "geo_velocity_commonMask.h5"

apply_mask \
    "geo_timeseries.h5" \
    "geo_timeseries_commonMask.h5"

apply_mask \
    "geo_timeseries_demErr.h5" \
    "geo_timeseries_demErr_commonMask.h5"

apply_mask \
    "geo_temporalCoherence.h5" \
    "geo_temporalCoherence_commonMask.h5"

# optional ERA5 products
apply_mask \
    "geo_timeseries_ERA5.h5" \
    "geo_timeseries_ERA5_commonMask.h5"

apply_mask \
    "geo_velocity_ERA5.h5" \
    "geo_velocity_ERA5_commonMask.h5"

apply_mask \
    "geo_avgSpatialCoh.h5" \
    "geo_avgSpatialCoh_commonMask.h5"

# =========================================================
# DESCENDING PRODUCTS
# =========================================================

echo
echo "========================================="
echo "DESCENDING PRODUCTS"
echo "========================================="

cd "${DESC_GEO_DIR}"

apply_mask \
    "geo_velocity.h5" \
    "geo_velocity_commonMask.h5"

apply_mask \
    "geo_timeseries.h5" \
    "geo_timeseries_commonMask.h5"

apply_mask \
    "geo_timeseries_demErr.h5" \
    "geo_timeseries_demErr_commonMask.h5"

apply_mask \
    "geo_temporalCoherence.h5" \
    "geo_temporalCoherence_commonMask.h5"

# optional ERA5 products
apply_mask \
    "geo_timeseries_ERA5.h5" \
    "geo_timeseries_ERA5_commonMask.h5"

apply_mask \
    "geo_velocity_ERA5.h5" \
    "geo_velocity_ERA5_commonMask.h5"

apply_mask \
    "geo_avgSpatialCoh.h5" \
    "geo_avgSpatialCoh_commonMask.h5"

echo
echo "=== Common mask application completed ==="