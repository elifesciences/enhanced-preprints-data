#!/bin/bash
set -e

# pass the pdf s3 bucket as first param, and data folder as second
# example run:
# ./scripts/introduce_pdfs.sh [PROD_OR_STAGING] [DATA_FOLDER]

SCRIPT_DIR="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
PARENT_DIR="$(dirname "${SCRIPT_DIR}")"
DATA_FOLDER="$(realpath ${1:-${PARENT_DIR}/data})" # default ./data
PROD_OR_STAGING="${1:-prod}" # default prod
S3_BUCKET="s3://${PROD_OR_STAGING}-elife-epp-pdf/data"

aws s3 sync ${S3_BUCKET} ${DATA_FOLDER} --exclude "*" --include "*.pdf" --delete
