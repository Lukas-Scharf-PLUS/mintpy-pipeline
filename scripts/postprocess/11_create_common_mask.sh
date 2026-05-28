#!/usr/bin/env bash
set -euo pipefail

ASC_DIR="${1:?Usage: create_common_mask.sh <asc_mintpy_dir> <desc_mintpy_dir> [threshold]}"
DESC_DIR="${2:?Usage: create_common_mask.sh <asc_mintpy_dir> <desc_mintpy_dir> [threshold]}"

# optional coherence threshold
THRESHOLD="${3:-0.7}"

ASC_GEO_DIR="${ASC_DIR}/geo_standardized"
DESC_GEO_DIR="${DESC_DIR}/geo_standardized"

ASC_COH="${ASC_GEO_DIR}/geo_temporalCoherence.h5"
DESC_COH="${DESC_GEO_DIR}/geo_temporalCoherence.h5"

COMMON_MASK_DIR="$(dirname "${ASC_DIR}")/common_mask"
COMMON_MASK_FILE="${COMMON_MASK_DIR}/common_mask.h5"

mkdir -p "${COMMON_MASK_DIR}"

echo "=== Creating common ASC/DESC mask ==="

echo "Ascending coherence:"
echo "${ASC_COH}"

echo
echo "Descending coherence:"
echo "${DESC_COH}"

# ---------------------------------------------------------
# validate input files
# ---------------------------------------------------------

if [[ ! -f "${ASC_COH}" ]]; then
    echo
    echo "ERROR: Missing ascending temporal coherence file"
    exit 1
fi

if [[ ! -f "${DESC_COH}" ]]; then
    echo
    echo "ERROR: Missing descending temporal coherence file"
    exit 1
fi

# ---------------------------------------------------------
# create binary masks
# ---------------------------------------------------------

echo
echo "=== Creating ascending mask ==="

generate_mask.py \
    "${ASC_COH}" \
    -m "${THRESHOLD}" \
    -o "${COMMON_MASK_DIR}/asc_mask.h5"

echo
echo "=== Creating descending mask ==="

generate_mask.py \
    "${DESC_COH}" \
    -m "${THRESHOLD}" \
    -o "${COMMON_MASK_DIR}/desc_mask.h5"

# ---------------------------------------------------------
# intersect masks
# ---------------------------------------------------------

echo
echo "=== Creating common intersection mask ==="

python - << EOF
import h5py
import numpy as np

asc_file = "${COMMON_MASK_DIR}/asc_mask.h5"
desc_file = "${COMMON_MASK_DIR}/desc_mask.h5"
out_file = "${COMMON_MASK_FILE}"

# ---------------------------------------------------------
# read ascending mask + attributes
# ---------------------------------------------------------

with h5py.File(asc_file, "r") as f:
    dataset_name = list(f.keys())[0]

    asc = f[dataset_name][:]

    file_attrs = dict(f.attrs)
    dset_attrs = dict(f[dataset_name].attrs)

# ---------------------------------------------------------
# read descending mask
# ---------------------------------------------------------

with h5py.File(desc_file, "r") as f:
    dataset_name_desc = list(f.keys())[0]
    desc = f[dataset_name_desc][:]

# ---------------------------------------------------------
# create common mask
# ---------------------------------------------------------

common = np.logical_and(asc, desc).astype(np.uint8)

# ---------------------------------------------------------
# write proper MintPy-compatible HDF5
# ---------------------------------------------------------

with h5py.File(out_file, "w") as f:

    # preserve global attrs
    for k, v in file_attrs.items():
        f.attrs[k] = v

    dset = f.create_dataset(dataset_name, data=common)

    # preserve dataset attrs
    for k, v in dset_attrs.items():
        dset.attrs[k] = v

print("Common mask written:", out_file)
EOF

echo
echo "=== Common mask created ==="

echo
echo "Output:"
echo "${COMMON_MASK_FILE}"