#!/bin/bash
set -e

# pass the data directory as first and manuscripts text file as second
# example run:
# ./scripts/prepare_doi_data.sh [data_dir] [manuscripts_txt]

SCRIPT_DIR="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
PARENT_DIR="$(dirname "${SCRIPT_DIR}")"

data_dir="$(realpath ${1-${PARENT_DIR}/data})" # default ./data
manuscripts_txt="$(realpath ${2-${PARENT_DIR}/manuscripts.txt})" # default ./manuscripts.txt

echo "Preparing doi data structure from $data_dir and ${manuscripts_txt}"

while read -r line; do
    manuscript_id=$(echo $line | cut -d':' -f1)
    dois=($(echo $line | cut -d' ' -f2 | tr ',' ' '))
    for i in "${!dois[@]}"; do
        version=$(( ${i} + 1 ))
        if [[ -d "${data_dir}/${manuscript_id}/v${version}" && ! -d "${data_dir}/${dois[$i]}" ]]; then
            echo "Preparing ${data_dir}/${dois[$i]} from ${data_dir}/${manuscript_id}/v${version}"
            mkdir -p ${data_dir}/${dois[$i]}
            cp -rf ${data_dir}/${manuscript_id}/v${version}/* ${data_dir}/${dois[$i]}
            mv ${data_dir}/${dois[$i]}/${manuscript_id}-v${version}.xml ${data_dir}/${dois[$i]}/$(basename ${data_dir}/${dois[$i]}).xml
            if [ -f "${data_dir}/${dois[$i]}/${manuscript_id}-v${version}.pdf" ]; then
                mv ${data_dir}/${dois[$i]}/${manuscript_id}-v${version}.pdf ${data_dir}/${dois[$i]}/$(basename ${data_dir}/${dois[$i]}).pdf
            fi
        fi
    done
done < "${manuscripts_txt}"
