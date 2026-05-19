#!/usr/bin/env bash
set -euo pipefail

ASC_DIR="${1:?Usage: apply_common_reference.sh <asc_mintpy_dir> <desc_mintpy_dir>}"

DESC_DIR="${2:?Usage: apply_common_reference.sh <asc_mintpy_dir> <desc_mintpy_dir>}"

ASC_GEO_DIR="${ASC_DIR}/geo_standardized"
DESC_GEO_DIR="${DESC_DIR}/geo_standardized"

# ---------------------------------------------------------
# input products
# ---------------------------------------------------------

ASC_COH="${ASC_GEO_DIR}/geo_temporalCoherence_commonMask.h5"
DESC_COH="${DESC_GEO_DIR}/geo_temporalCoherence_commonMask.h5"

ASC_VEL="${ASC_GEO_DIR}/geo_velocity_commonMask.h5"
DESC_VEL="${DESC_GEO_DIR}/geo_velocity_commonMask.h5"

# ---------------------------------------------------------
# output products
# ---------------------------------------------------------

ASC_REF="${ASC_GEO_DIR}/geo_velocity_commonMask_ref.h5"
DESC_REF="${DESC_GEO_DIR}/geo_velocity_commonMask_ref.h5"

# ---------------------------------------------------------
# validate files
# ---------------------------------------------------------

FILES=(
    "${ASC_COH}"
    "${DESC_COH}"
    "${ASC_VEL}"
    "${DESC_VEL}"
)

for FILE in "${FILES[@]}"; do

    if [[ ! -f "${FILE}" ]]; then

        echo
        echo "ERROR: Missing file"
        echo "${FILE}"
        exit 1

    fi

done

echo "=== Selecting common reference point ==="

# ---------------------------------------------------------
# determine best common reference pixel
# ---------------------------------------------------------

REF_INFO=$(python - << EOF
import h5py
import numpy as np

asc_file = "${ASC_COH}"
desc_file = "${DESC_COH}"

def read_dataset(path):

    with h5py.File(path, "r") as f:

        dataset_name = list(f.keys())[0]

        data = f[dataset_name][:]

        attrs = dict(f.attrs)

    return data, attrs

asc, asc_attr = read_dataset(asc_file)
desc, desc_attr = read_dataset(desc_file)

# ---------------------------------------------------------
# valid pixels
# ---------------------------------------------------------

valid = (
    np.isfinite(asc) &
    np.isfinite(desc) &
    (asc > 0) &
    (desc > 0)
)

if np.count_nonzero(valid) == 0:
    raise RuntimeError("No common valid pixels found")

# ---------------------------------------------------------
# coherence score
# ---------------------------------------------------------

score = np.minimum(asc, desc)

score[~valid] = -999

# ---------------------------------------------------------
# prefer central pixels
# ---------------------------------------------------------

ys, xs = np.where(valid)

cy = (asc.shape[0] - 1) / 2.0
cx = (asc.shape[1] - 1) / 2.0

dist2 = (ys - cy)**2 + (xs - cx)**2

cand_score = score[ys, xs]

order = np.lexsort((dist2, -cand_score))

y = int(ys[order[0]])
x = int(xs[order[0]])

best_score = float(cand_score[order[0]])

# ---------------------------------------------------------
# convert to lat/lon
# ---------------------------------------------------------

x_first = float(asc_attr["X_FIRST"])
y_first = float(asc_attr["Y_FIRST"])

x_step = float(asc_attr["X_STEP"])
y_step = float(asc_attr["Y_STEP"])

lon = x_first + x * x_step
lat = y_first + y * y_step

print(f"{lat} {lon} {best_score}")
EOF
)

REF_LAT=$(echo "${REF_INFO}" | awk '{print $1}')
REF_LON=$(echo "${REF_INFO}" | awk '{print $2}')
REF_SCORE=$(echo "${REF_INFO}" | awk '{print $3}')

echo
echo "Selected reference point:"
echo "LAT=${REF_LAT}"
echo "LON=${REF_LON}"
echo "SCORE=${REF_SCORE}"

# ---------------------------------------------------------
# apply reference point
# ---------------------------------------------------------

echo
echo "=== Applying common reference point ==="

echo
echo "Referencing ASC velocity"

reference_point.py \
    "${ASC_VEL}" \
    --lat "${REF_LAT}" \
    --lon "${REF_LON}" \
    -o "${ASC_REF}"

echo
echo "Referencing DESC velocity"

reference_point.py \
    "${DESC_VEL}" \
    --lat "${REF_LAT}" \
    --lon "${REF_LON}" \
    -o "${DESC_REF}"

echo
echo "=== Common referencing completed ==="

echo
echo "Outputs:"
echo "${ASC_REF}"
echo "${DESC_REF}"