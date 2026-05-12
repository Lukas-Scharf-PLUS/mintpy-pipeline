#!/usr/bin/env bash
set -euo pipefail

ISCE_DIR="${1:?Usage: run_mintpy_full.sh <isce_dir> <mintpy_dir>}"
MINTPY_DIR="${2:?Usage: run_mintpy_full.sh <isce_dir> <mintpy_dir>}"

cd "${MINTPY_DIR}"

smallbaselineApp.py mintpy.cfg \
  2>&1 | tee "${MINTPY_DIR}/logs/mintpy_full.log"