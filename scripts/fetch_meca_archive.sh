#!/bin/bash
set -e

# This requires jq
# pass the doi as first param, output directory as second, msid as third, version as fourth and meca lookup file as fifth
# example run:
# ./scripts/fetch_meca_archive.sh doi [output_dir] [msid] [version] [meca_lookup]

SCRIPT_DIR="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
PARENT_DIR="$(dirname "${SCRIPT_DIR}")"

doi=$1
output_dir="$(realpath ${2-${PARENT_DIR}/incoming})" # default ./incoming
msid="${3-unknown}" # default unknown
version="${4-1}" # default 1
meca_lookup="$(realpath ${5-${PARENT_DIR}/meca-lookup.txt})" # default ./meca-lookup.txt

doi_line=$(grep -m 1 "^${doi}=" "${meca_lookup}" || true)
if [[ -n "${doi_line}" ]]; then
    echo "found entry in ${meca_lookup}"
    s3source="${doi_line##*=}"
else
    doi_line=$(grep -m 1 "^${doi}\[${version}\]=" "${meca_lookup}" || true)
    if [[ -n "${doi_line}" ]]; then
        echo "found versioned entry in ${meca_lookup}"
        s3source="${doi_line##*=}"
    else
        results_index=$(( ${version} - 1 ))
        echo "search for entry in bioRxiv"
        s3source="$(curl -s "https://api.biorxiv.org/meca_index/elife/$doi" | jq -r ".results[${results_index}].tdm_path")"
    fi
fi

echo "fetching $doi to $output_dir...";

s3source_filename="${msid}-${version}--$(basename $s3source)"
echo "Found! fetching $s3source to $output_dir/$s3source_filename"
aws s3 cp --request-payer requester $s3source "${output_dir}/${s3source_filename}"
