#!/usr/bin/env bash
set -euo pipefail

ASC_DIR="${1:?Usage: run_multitrack_postprocess.sh <asc_mintpy_dir> <desc_mintpy_dir>}"
DESC_DIR="${2:?Usage: run_multitrack_postprocess.sh <asc_mintpy_dir> <desc_mintpy_dir>}"

# optional common coherence threshold
COMMON_COH_THRESHOLD="${3:-0.7}"

echo "========================================================="
echo "Running multi-track postprocessing"
echo "========================================================="

echo
echo "Ascending MintPy directory:"
echo "${ASC_DIR}"

echo
echo "Descending MintPy directory:"
echo "${DESC_DIR}"

echo
echo "Common coherence threshold:"
echo "${COMMON_COH_THRESHOLD}"

# =========================================================
# create common mask
# =========================================================

echo
echo "========================================================="
echo "STEP 1 - Create common mask"
echo "========================================================="

/scripts/postprocess/05_create_common_mask.sh \
    "${ASC_DIR}" \
    "${DESC_DIR}" \
    "${COMMON_COH_THRESHOLD}"

# =========================================================
# apply common mask
# =========================================================

COMMON_MASK="${ASC_DIR}/common_mask/common_mask.h5"

echo
echo "========================================================="
echo "STEP 2 - Apply common mask"
echo "========================================================="

/scripts/postprocess/06_apply_common_mask.sh \
    "${ASC_DIR}" \
    "${DESC_DIR}" \
    "${COMMON_MASK}"

# =========================================================
# LOS decomposition
# =========================================================

echo
echo "========================================================="
echo "STEP 3 - LOS decomposition"
echo "========================================================="

/scripts/postprocess/07_LOS_decomposition.sh \
    "${ASC_DIR}" \
    "${DESC_DIR}"

echo
echo "========================================================="
echo "Multi-track processing completed successfully"
echo "========================================================="