#!/bin/bash
set -e

# This requires jq
# pass all or new as first param, the output directory as second, data directory as third, manuscripts text file as fourth and meca lookup file as fifth
# example run:
# ./scripts/fetch_meca_archives.sh [all_or_new] [output_dir] [data_dir] [manuscripts_txt] [meca_lookup]

SCRIPT_DIR="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
PARENT_DIR="$(dirname "${SCRIPT_DIR}")"

all_or_new="${1-new}" # default new

if [[ "$all_or_new" != "all" && "$all_or_new" != "new" ]]; then
    echo "Error: all_or_new is not 'all' or 'new'"
    exit 1
fi

output_dir="$(realpath ${2-${PARENT_DIR}/incoming})" # default ./incoming
data_dir="$(realpath ${3-${PARENT_DIR}/data})" # default ./data
manuscripts_txt="$(realpath ${4-${PARENT_DIR}/manuscripts.txt})" # default ./manuscripts.txt
meca_lookup="$(realpath ${5-${PARENT_DIR}/meca-lookup.txt})" # default ./meca-lookup.txt

mkdir -p $data_dir

echo "Retrieving ${all_or_new} manuscripts in ${manuscripts_txt}"

while read -r line; do
    if [[ "$all_or_new" = "all" || ! -d "${data_dir}/${line}" ]]; then
        $SCRIPT_DIR/fetch_meca_archive.sh "$line" $output_dir $meca_lookup
    fi
done < "${manuscripts_txt}"
