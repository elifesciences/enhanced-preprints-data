#!/bin/bash
set -e

# This requires jq
# pass the doi as first param, output directory as second and meca lookup file as third
# example run:
# ./scripts/fetch_meca_archive.sh doi [output_dir] [meca_lookup]

SCRIPT_DIR="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
PARENT_DIR="$(dirname "${SCRIPT_DIR}")"

doi=$1
doiPrefix="${doi%%\/*}"
doiSuffix="${doi#*\/}"
output_dir="$(realpath ${2-${PARENT_DIR}/incoming})" # default ./incoming
meca_lookup="$(realpath ${3-${PARENT_DIR}/meca-lookup.txt})" # default ./meca-lookup.txt

doi_line=$(grep -m 1 "^${doi}=" "${meca_lookup}" || true)
if [[ -n "${doi_line}" ]]; then
    echo "found entry in ${meca_lookup}"
    s3source="${doi_line#${doi}=}"
else
    echo "search for entry in bioRxiv"
    s3source="$(curl -s "https://api.biorxiv.org/meca_index/elife/all/$doiSuffix" | jq -r '.results[0].tdm_path')"
fi

echo "fetching $doi to $output_dir...";

echo "Found! fetching $s3source to $output_dir"
aws s3 cp --request-payer requester $s3source $output_dir/
