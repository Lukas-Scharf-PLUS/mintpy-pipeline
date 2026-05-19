#!/usr/bin/env bash
set -euo pipefail

ASC_DIR="${1:?Usage: LOS_decomposition.sh <asc_mintpy_dir> <desc_mintpy_dir>}"
DESC_DIR="${2:?Usage: LOS_decomposition.sh <asc_mintpy_dir> <desc_mintpy_dir>}"

ASC_GEO_DIR="${ASC_DIR}/geo_standardized"
DESC_GEO_DIR="${DESC_DIR}/geo_standardized"

# ---------------------------------------------------------
# input products
# ---------------------------------------------------------

ASC_VEL="${ASC_GEO_DIR}/geo_velocity_commonMask.h5"
DESC_VEL="${DESC_GEO_DIR}/geo_velocity_commonMask.h5"

ASC_GEOM="${ASC_GEO_DIR}/geo_geometryRadar.h5"
DESC_GEOM="${DESC_GEO_DIR}/geo_geometryRadar.h5"

# ---------------------------------------------------------
# output directory
# ---------------------------------------------------------

OUT_DIR="${ASC_DIR}/decomposition"

mkdir -p "${OUT_DIR}"

VERTICAL_OUT="${OUT_DIR}/vertical_velocity.h5"
EW_OUT="${OUT_DIR}/eastwest_velocity.h5"

echo "=== LOS decomposition ==="

echo
echo "Ascending velocity:"
echo "${ASC_VEL}"

echo
echo "Descending velocity:"
echo "${DESC_VEL}"

# ---------------------------------------------------------
# validate files
# ---------------------------------------------------------

FILES=(
    "${ASC_VEL}"
    "${DESC_VEL}"
    "${ASC_GEOM}"
    "${DESC_GEOM}"
)

for FILE in "${FILES[@]}"; do

    if [[ ! -f "${FILE}" ]]; then

        echo
        echo "ERROR: Missing file"
        echo "${FILE}"
        exit 1

    fi

done

# ---------------------------------------------------------
# decomposition
# ---------------------------------------------------------

echo
echo "=== Running asc/desc decomposition ==="

asc_desc2horz_vert.py \
    "${ASC_VEL}" \
    "${DESC_VEL}" \
    -g "${ASC_GEOM}" "${DESC_GEOM}" \
    --az 90 \
    -o "${EW_OUT}" "${VERTICAL_OUT}"

echo
echo "=== LOS decomposition completed ==="

echo
echo "Outputs:"
echo "${EW_OUT}"
echo "${VERTICAL_OUT}"