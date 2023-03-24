#!/bin/bash
set -e

# pass the data folder as first param, and pdf s3 bucket as second
# example run:
# ./scripts/preserve_pdfs.sh [DATA_FOLDER] [S3_BUCKET]

SCRIPT_DIR="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
PARENT_DIR="$(dirname "${SCRIPT_DIR}")"
DEFAULT_S3_BUCKET="s3://prod-elife-epp-pdf/data" # default s3://prod-elife-epp-pdf/data
S3_BUCKET="${1:-${DEFAULT_S3_BUCKET}}"
DATA_FOLDER="$(realpath ${2:-${PARENT_DIR}/data})" # default ./data

if [ "$S3_BUCKET" == "$DEFAULT_S3_BUCKET" ]; then
    echo "Performing pre-sync checks before syncing with prod pdf s3"
	${SCRIPT_DIR}/pre_sync_check.sh 2>&1
fi

echo "sync PDFs from ${DATA_FOLDER} to ${S3_BUCKET}"
aws s3 sync ${DATA_FOLDER} ${S3_BUCKET} --exclude "*" --include "*.pdf" --delete
