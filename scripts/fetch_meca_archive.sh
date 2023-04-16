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

# if s3source has a format dd_mmm_yy in then extract it to a variable s3source_date in format dd-mmm-yy otherwise set s3source_date to date-unknown s3://transfers-elife/biorxiv_Current_Content/May_2022/30_May_22_Batch_1267/06908fc3-73df-1014-bb56-a21daa237ef0.meca

# Extract date from s3source
if [[ $s3source =~ ([0-9]{2})_([A-Za-z]{3})_([0-9]{2}) ]]; then
  day=${BASH_REMATCH[1]}
  month=${BASH_REMATCH[2]}
  year=${BASH_REMATCH[3]}
  s3source_date=$(date -d "${day} ${month} ${year}" "+%d-%b-%y")
else
  s3source_date="00-Unk-00"
fi

s3source_filename="${msid}-${version}--${s3source_date}--$(basename $s3source)"
echo "Found! fetching $s3source to $output_dir/$s3source_filename"
aws s3 cp --request-payer requester $s3source "${output_dir}/${s3source_filename}"
