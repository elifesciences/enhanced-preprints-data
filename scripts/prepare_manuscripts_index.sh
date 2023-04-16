#!/bin/bash

# This requires jq
# pass the data directory as first parameter
# example run:
# curl -s https://data-hub-api.elifesciences.org/enhanced-preprints/docmaps/v1/index | ./scripts/prepare_manuscripts_index.sh [DATA_DIR]

if [ -n "$1" ]; then
  DATA_DIR=$(realpath "$1")
fi

# Read in the JSON data from standard input
data=$(cat)

# Parse the JSON data with jq and extract the manuscript ID and DOI for each docmap that has _tdmPath
preprint_manuscript_map=$(echo $data | jq -r '.docmaps[] | {manuscript_id: (.id | split("=")[-1]), doi: .steps["_:b0"].actions[0].outputs[0].doi}' | jq -s 'sort_by(.manuscript_id)[] | "\(.manuscript_id): \(.doi)"' | tr -d '"')

# If no optional parameter is supplied, print out all manuscript IDs and DOIs
if [ -z "$DATA_DIR" ]; then
  echo "$preprint_manuscript_map"
else
  # Loop through the preprint-manuscript map and check if a matching folder exists
  while read -r line; do
    manuscript_id=$(echo $line | cut -d' ' -f1)
    doi=$(echo $line | cut -d' ' -f2)
    if [ -d "$DATA_DIR/$doi" ]; then
      echo "$line"
    fi
  done <<< "$preprint_manuscript_map"
fi
