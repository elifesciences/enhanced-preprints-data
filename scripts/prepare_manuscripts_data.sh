#!/bin/bash
set -e

# pass the data directory as first and manuscripts text file as second
# example run:
# ./scripts/prepare_manuscripts_data.sh [data_dir] [manuscripts_txt]

SCRIPT_DIR="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
PARENT_DIR="$(dirname "${SCRIPT_DIR}")"

data_dir="$(realpath ${1-${PARENT_DIR}/data})" # default ./data
manuscripts_txt="$(realpath ${2-${PARENT_DIR}/manuscripts.txt})" # default ./manuscripts.txt

echo "Preparing manuscripts/version data structure from $data_dir and ${manuscripts_txt}"

while read -r line; do
    manuscript_id=$(echo $line | cut -d':' -f1)
    dois=($(echo $line | cut -d' ' -f2 | tr ',' ' '))
    for i in "${!dois[@]}"; do
        version=$(( ${i} + 1 ))
        if [[ ( $i -eq 0 || "${dois[$i]}" != "${dois[$((i-1))]}" ) && -d "${data_dir}/${dois[$i]}" && ! -d "${data_dir}/${manuscript_id}/v${version}" ]]; then
            echo "Preparing ${data_dir}/${manuscript_id}/v${version} from ${data_dir}/${dois[$i]}"
            mkdir -p ${data_dir}/${manuscript_id}/v${version}
            cp -rf ${data_dir}/${dois[$i]}/* ${data_dir}/${manuscript_id}/v${version}
            mv ${data_dir}/${manuscript_id}/v${version}/$(basename ${data_dir}/${dois[$i]}).xml ${data_dir}/${manuscript_id}/v${version}/${manuscript_id}-v${version}.xml
            if [ -f "${data_dir}/${manuscript_id}/v${version}/$(basename ${data_dir}/${dois[$i]}).pdf" ]; then
                mv ${data_dir}/${manuscript_id}/v${version}/$(basename ${data_dir}/${dois[$i]}).pdf ${data_dir}/${manuscript_id}/v${version}/${manuscript_id}-v${version}.pdf
            fi
        fi
    done
done < "${manuscripts_txt}"
