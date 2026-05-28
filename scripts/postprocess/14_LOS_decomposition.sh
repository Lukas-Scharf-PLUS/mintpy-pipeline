#!/usr/bin/env bash
set -euo pipefail

ASC_DIR="${1:?Usage: LOS_decomposition.sh <asc_mintpy_dir> <desc_mintpy_dir>}"

DESC_DIR="${2:?Usage: LOS_decomposition.sh <asc_mintpy_dir> <desc_mintpy_dir>}"

ASC_GEO_DIR="${ASC_DIR}/geo_standardized"
DESC_GEO_DIR="${DESC_DIR}/geo_standardized"

# ---------------------------------------------------------
# input products
# ---------------------------------------------------------

ASC_VEL="${ASC_GEO_DIR}/geo_velocity_commonMask_ref.h5"
DESC_VEL="${DESC_GEO_DIR}/geo_velocity_commonMask_ref.h5"

# standardized geometry products
ASC_GEOM="${ASC_GEO_DIR}/geo_geometryRadar.h5"
DESC_GEOM="${DESC_GEO_DIR}/geo_geometryRadar.h5"

# ---------------------------------------------------------
# output directory
# ---------------------------------------------------------

OUT_DIR="$(dirname "${ASC_DIR}")/decomposition"

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
# ensure azimuthAngle exists
# ---------------------------------------------------------

echo
echo "=== Checking geometry files ==="

ASC_GEOM_TMP="${OUT_DIR}/asc_geometry_ready.h5"
DESC_GEOM_TMP="${OUT_DIR}/desc_geometry_ready.h5"

cp "${ASC_GEOM}" "${ASC_GEOM_TMP}"
cp "${DESC_GEOM}" "${DESC_GEOM_TMP}"

python - << EOF
import h5py
import numpy as np

files = [
    "${ASC_GEOM_TMP}",
    "${DESC_GEOM_TMP}",
]

for fname in files:

    with h5py.File(fname, "a") as f:

        # -------------------------------------------------
        # already exists
        # -------------------------------------------------

        if "azimuthAngle" in f:

            print(f"azimuthAngle already exists in: {fname}")
            continue

        # -------------------------------------------------
        # create from HEADING metadata
        # -------------------------------------------------

        if "HEADING" not in f.attrs:
            raise RuntimeError(
                f"Missing HEADING attribute in: {fname}"
            )

        heading = float(f.attrs["HEADING"])

        shape = f["incidenceAngle"].shape

        az = np.full(shape, heading, dtype=np.float32)

        f.create_dataset("azimuthAngle", data=az)

        f["azimuthAngle"].attrs["UNIT"] = "degree"

        print(
            f"Created azimuthAngle from HEADING={heading} "
            f"for: {fname}"
        )
EOF

# ---------------------------------------------------------
# decomposition
# ---------------------------------------------------------

echo
echo "=== Running ASC/DESC decomposition ==="

asc_desc2horz_vert.py \
    "${ASC_VEL}" \
    "${DESC_VEL}" \
    -g "${ASC_GEOM_TMP}" "${DESC_GEOM_TMP}" \
    --az -90 \
    -o "${EW_OUT}" "${VERTICAL_OUT}"

echo
echo "=== LOS decomposition completed ==="

echo
echo "Outputs:"
echo "${EW_OUT}"
echo "${VERTICAL_OUT}"