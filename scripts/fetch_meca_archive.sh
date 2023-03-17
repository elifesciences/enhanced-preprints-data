#!/bin/bash
set -e
# This requires jq
# pass the id part of a biorxiv doi as first param, and output directory as second
# example run:
# ./scripts/fetch_meca_archive.sh 2022.07.22.501195 incoming/

id=$1
output_dir=$2

echo "fetching $id to $output_dir...";

s3source="$(curl -s "https://api.biorxiv.org/meca_index/elife/all/$id" | jq -r '.results[].tdm_path')"

echo "Found! fetching $s3source to $output_dir"
aws s3 cp --profile=biorxiv --request-payer requester $s3source $output_dir/
