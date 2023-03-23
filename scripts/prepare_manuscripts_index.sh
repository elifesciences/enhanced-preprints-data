#!/bin/bash

# pass the data folder as first param, and manuscripts text file as second
# example run:
# ./scripts/prepare_manuscripts_index.sh [DATA_FOLDER] [MANUSCRIPTS_TXT]

SCRIPT_DIR="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
PARENT_DIR="$(dirname "${SCRIPT_DIR}")"
DATA_FOLDER="$(realpath ${1:-${PARENT_DIR}/data})" # default ./data
MANUSCRIPTS_TXT="$(realpath ${2:-${PARENT_DIR}/manuscripts.txt})" # default ./manuscripts.txt

echo -n "" > "${MANUSCRIPTS_TXT}"

for filename in $(find $(realpath $DATA_FOLDER) -type f -name '*.xml' | sort); do
    dir_path=$(dirname $filename)
    echo ${dir_path#$DATA_FOLDER/} >> "${MANUSCRIPTS_TXT}"
done
