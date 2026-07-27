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

    echo "CDS credentials configured"

fi


MINTPY_DIR="${1:?Usage: run_mintpy_full.sh <mintpy_dir>}"

cd "${MINTPY_DIR}"

smallbaselineApp.py mintpy.cfg \
  2>&1 | tee "${MINTPY_DIR}/logs/mintpy_full.log"