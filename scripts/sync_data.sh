#!/bin/bash
set -e

# pass the env (prod or staging) as first param, and data folder as second
# example run:
# ./scripts/sync_data.sh [PROD_OR_STAGING] [DATA_FOLDER]

SCRIPT_DIR="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
PARENT_DIR="$(dirname "${SCRIPT_DIR}")"
PROD_OR_STAGING="${1:-prod}" # default prod
S3_BUCKET="s3://${PROD_OR_STAGING}-elife-epp-data/data"
DATA_FOLDER="$(realpath ${2:-${PARENT_DIR}/data})" # default ./data

aws s3 sync ${DATA_FOLDER} ${S3_BUCKET} --delete
