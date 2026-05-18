#!/usr/bin/env bash
set -euo pipefail

echo "=== Creating CDS API credentials ==="

if [[ -n "${CDSAPI_KEY:-}" ]]; then
    cat > /home/mambauser/.cdsapirc << EOF
url: ${CDSAPI_URL}
key: ${CDSAPI_KEY}
EOF
fi

ISCE_DIR="${1:?Usage: run_pipeline.sh <isce_dir> <mintpy_dir>}"
MINTPY_DIR="${2:?Usage: run_pipeline.sh <isce_dir> <mintpy_dir>}"

# global AOI definition
SOUTH="48.17"
NORTH="48.23"
WEST="16.34"
EAST="16.38"

# default MintPy subset format
DEFAULT_SUBSET_LALO="${SOUTH}:${NORTH},${WEST}:${EAST}"

# allow override from input parameter
SUBSET_LALO="${3:-$DEFAULT_SUBSET_LALO}"

# Geocoding bbox format
SNWE_ARGS="${SOUTH} ${NORTH} ${WEST} ${EAST}"

# atmospheric correction
TROPO_METHOD="${4:-no}"
WEATHER_MODEL="ERA5"
WEATHER_DIR="/data/weather"

# minimal temporal coherence
MIN_TEMP_COH="${5:-0.7}"

mkdir -p "${MINTPY_DIR}/logs"


# create a log file for the parameters
PARAMETERS_LOG_FILE="${MINTPY_DIR}/logs/parameters_log.txt"

cat > "${PARAMETERS_LOG_FILE}" << EOF
RUN_TIMESTAMP=$(date)

ISCE_DIR=${ISCE_DIR}
MINTPY_DIR=${MINTPY_DIR}


SOUTH=${SOUTH}
NORTH=${NORTH}
WEST=${WEST}
EAST=${EAST}

SUBSET_LALO=${SUBSET_LALO}
SNWE_ARGS=${SNWE_ARGS}

MIN_TEMP_COH=${MIN_TEMP_COH}

TROPO_METHOD=${TROPO_METHOD}
WEATHER_MODEL=${WEATHER_MODEL}
WEATHER_DIR=${WEATHER_DIR}

CDSAPI_URL=${CDSAPI_URL:-not_set}
EOF

echo "=== Parameters written to ${PARAMETERS_LOG_FILE} ==="

echo "=== Running MintPy load_data ==="
/scripts/mintpy/01_run_mintpy_load.sh \
    "$ISCE_DIR" \
    "$MINTPY_DIR" \
    "$SUBSET_LALO" \
    "$TROPO_METHOD" \
    "$MIN_TEMP_COH"

echo "=== Running full MintPy workflow ==="
/scripts/mintpy/02_run_mintpy_full.sh "${ISCE_DIR}" "${MINTPY_DIR}"

echo "=== Rendering PNG products ==="
/scripts/mintpy/03_render_pngs.sh "${MINTPY_DIR}"

echo "=== Validating outputs ==="

test -f "${MINTPY_DIR}/velocity.h5"
test -f "${MINTPY_DIR}/timeseries.h5"
test -f "${MINTPY_DIR}/temporalCoherence.h5"

echo "=== MintPy pipeline completed successfully ==="


echo "=== Geocoding standardized products ==="
/scripts/mintpy/04_standardized_geocode.sh \
    "${MINTPY_DIR}" \
    "${SNWE_ARGS}"
