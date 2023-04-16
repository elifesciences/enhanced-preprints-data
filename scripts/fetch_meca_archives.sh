#!/bin/bash
set -e

# This requires jq
# pass all or new as first param, the output directory as second, manuscripts text file as third, and meca lookup file as fourth
# example run:
# ./scripts/fetch_meca_archives.sh [all_or_new] [output_dir] [manuscripts_txt] [meca_lookup]

SCRIPT_DIR="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
PARENT_DIR="$(dirname "${SCRIPT_DIR}")"

all_or_new="${1-new}" # default new

if [[ "$all_or_new" != "all" && "$all_or_new" != "new" ]]; then
    echo "Error: all_or_new is not 'all' or 'new'"
    exit 1
fi

output_dir="$(realpath ${2-${PARENT_DIR}/incoming})" # default ./incoming
manuscripts_txt="$(realpath ${3-${PARENT_DIR}/manuscripts.txt})" # default ./manuscripts.txt
meca_lookup="$(realpath ${4-${PARENT_DIR}/meca-lookup.txt})" # default ./meca-lookup.txt

echo "Retrieving ${all_or_new} manuscripts in ${manuscripts_txt}"

while read -r line; do
    manuscript_id=$(echo $line | cut -d':' -f1)
    dois=($(echo $line | cut -d' ' -f2 | tr ',' ' '))
    for i in "${!dois[@]}"; do
        version=$(( ${i} + 1 ))
        if [[ "$all_or_new" = "all" || ! -d "${PARENT_DIR}/data/${manuscript_id}/v${version}" ]]; then
            $SCRIPT_DIR/fetch_meca_archive.sh "${dois[$i]}" $output_dir $manuscript_id $version $meca_lookup
        fi
    done
done < "${manuscripts_txt}"
