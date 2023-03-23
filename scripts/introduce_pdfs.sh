#!/bin/bash
set -e

# pass the pdf s3 bucket as first param, and data folder as second
# example run:
# ./scripts/introduce_pdfs.sh [S3_BUCKET] [DATA_FOLDER]

SCRIPT_DIR="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
PARENT_DIR="$(dirname "${SCRIPT_DIR}")"
DATA_FOLDER="$(realpath ${1:-${PARENT_DIR}/data})" # default ./data
DEFAULT_S3_BUCKET="s3://prod-elife-epp-pdf/data"
S3_BUCKET="${2:-${DEFAULT_S3_BUCKET}}" # default s3://prod-elife-epp-pdf/data

aws s3 sync ${S3_BUCKET} ${DATA_FOLDER} --exclude "*" --include "*.pdf" --delete
