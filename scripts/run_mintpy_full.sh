#!/usr/bin/env bash
set -euo pipefail

STACK_DIR="${1:?Usage: run_mintpy_full.sh <stack_dir>}"

cd "${STACK_DIR}"

smallbaselineApp.py mintpy.cfg