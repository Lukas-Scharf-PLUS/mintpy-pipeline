#!/usr/bin/env bash
set -euo pipefail

# ---------------------------------------------------------
# create CDS API credentials
# ---------------------------------------------------------

export HOME=/home/mambauser

if [[ -n "${CDS_URL:-}" && -n "${CDS_KEY:-}" ]]; then

    mkdir -p "${HOME}"

    cat > "${HOME}/.cdsapirc" << EOF
url: ${CDS_URL}
key: ${CDS_KEY}
EOF

fi


MINTPY_DIR="${1:?Usage: apply_pyaps.sh <mintpy_dir>}"

WEATHER_DIR="${2:-/data/ERA5}"

cd "${MINTPY_DIR}"

echo "=== Generating ERA5 override config ==="

cat > mintpy_era5.cfg << EOF

mintpy.troposphericDelay.method = pyaps
mintpy.troposphericDelay.weatherModel = ERA5
mintpy.troposphericDelay.weatherDir = ${WEATHER_DIR}

EOF

echo
echo "=== ERA5 config ==="

cat mintpy_era5.cfg

# ---------------------------------------------------------
# cleanup potentially corrupted previous outputs
# ---------------------------------------------------------

echo
echo "=== Cleaning previous ERA5 intermediates ==="

rm -f inputs/ERA5.h5

# optional:
# remove incomplete GRIB downloads as well

#rm -rf "${WEATHER_DIR}"

# recreate weather directory

mkdir -p "${WEATHER_DIR}"

# ---------------------------------------------------------
# run correction
# ---------------------------------------------------------

echo
echo "=== Running ERA5 correction ==="

smallbaselineApp.py \
    --dir . \
    --dostep correct_troposphere \
    mintpy_era5.cfg \
    2>&1 | tee logs/mintpy_era5.log

# ---------------------------------------------------------
# recompute velocity
# ---------------------------------------------------------

echo
echo "=== Recomputing velocity from ERA5 corrected timeseries ==="

timeseries2velocity.py \
    timeseries_ERA5.h5 \
    -o velocity_ERA5.h5 \
    2>&1 | tee -a logs/mintpy_era5.log

echo
echo "=== ERA5 correction completed ==="

echo
echo "Generated outputs:"

ls -lh \
    timeseries_ERA5.h5 \
    velocity_ERA5.h5
