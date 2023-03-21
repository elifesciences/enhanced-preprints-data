#!/bin/bash
set -e

# This requires xmllint and macos/bsd sed
# pass the directory of mecas as first param, and output directory as second
# example run:
# ./scripts/extract_mecas.sh incoming/ data/

# Get the directory where the script is located
SCRIPT_DIR="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
PARENT_DIR="$(dirname "${SCRIPT_DIR}")"
INCOMING_DIR=$(realpath ${1})
DATA_DIR=$(realpath ${2})

function pull_docker_image() {
    # Check if the docker_image_flag has expired
    local image_flag="${PARENT_DIR}/.docker-image-flag"
    local expiry_in_hours=24
    local expiry_in_seconds=$((expiry_in_hours * 3600))
    local seconds_since_created=$expiry_in_seconds

    if [ -f "$image_flag" ]; then
        local image_flag_created_epoch=$(date -r "$image_flag" +%s)
        local current_epoch=$(date +%s)
        seconds_since_created=$((current_epoch - image_flag_created_epoch))
        if [ "$seconds_since_created" -gt $expiry_in_seconds ]; then
            echo "Flag is more than ${expiry_in_hours} hour(s) old. Forcing docker pull of latest image..."
        else
            seconds_since_created=0
        fi
    else
        echo "Flag not found. Pulling down latest docker image..."
    fi

    if [ "$seconds_since_created" -ge $expiry_in_seconds ]; then
        docker pull ghcr.io/elifesciences/enhanced-preprints-biorxiv-xslt:latest
        rm -f "${image_flag}"
        touch "${image_flag}"
        echo "Delete flag to force latest docker image to be pulled." > "${image_flag}"
    else
        echo "Recent docker image flag detected!"
    fi
}

for file in $INCOMING_DIR/*; do
    tmpDir=$(mktemp -d)
    echo $tmpDir

    echo "extracting $file..."
    unzip -q $file -d $tmpDir

    echo "getting article XML path from $tmpDir/manifest.xml ..."
    xmlFile=$(cat $tmpDir/manifest.xml | sed 's/xmlns=".*"//g' | xmllint -xpath 'string(/manifest/item[@type="article"]/instance[@media-type="application/xml"]/@href)' -)

    echo -n "getting doi from $tmpDir/$xmlFile ... "
    doi=$(cat $tmpDir/$xmlFile | sed 's/xmlns=".*"//g' | xmllint -xpath 'string(/article/front/article-meta/article-id)' -)
    echo "'$doi'."
    doiPrefix="${doi%%\/*}"
    doiSuffix="${doi#*\/}"

    outputDir="$DATA_DIR/$doi"
    id=$(basename $outputDir)
    uuid=$(basename -s .meca $file)

    echo "creating $outputDir"
    mkdir -p "$outputDir"

    echo "$uuid" >"$outputDir/source.txt"

    if [ "$doiPrefix" = "10.1101" ]; then
        pull_docker_image
        echo "correct some bioRxiv/Encoda XML issues and store $outputDir/$id.xml..."
        cat "$tmpDir/$xmlFile" | docker run --rm -i ghcr.io/elifesciences/enhanced-preprints-biorxiv-xslt:latest > "$outputDir/$id.xml"
        echo "transform.sh successfully run"
    else
        echo "Skipping XML correction for DOI prefix $doiPrefix"
        cp "$tmpDir/$xmlFile" "$outputDir/$id.xml"
    fi

    echo "copy all tif, gif and jpg content to ${outputDir}..."
    cp $tmpDir/content/*.tif "$outputDir/" || true
    cp $tmpDir/content/*.gif "$outputDir/" || true
    cp $tmpDir/content/*.jpg "$outputDir/" || true

    echo "cleaning up..."
    rm -R $tmpDir
done
