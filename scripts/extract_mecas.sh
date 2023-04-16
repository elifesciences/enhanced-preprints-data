#!/bin/bash
set -e

# This requires xmllint and macos/bsd sed
# pass the directory of mecas as first param, output directory as second and PDF s3 bucket and third
# example run:
# ./scripts/extract_mecas.sh [INCOMING_DIR] [DATA_DIR] [PDF_S3_BUCKET]

# Get the directory where the script is located
SCRIPT_DIR="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
PARENT_DIR="$(dirname "${SCRIPT_DIR}")"
INCOMING_DIR=$(realpath ${1:-${PARENT_DIR}/incoming}) # default ./incoming
DATA_DIR=$(realpath ${2:-${PARENT_DIR}/data}) # default ./data
DEFAULT_PDF_S3_BUCKET="s3://prod-elife-epp-pdf/data"
PDF_S3_BUCKET="${3:-${DEFAULT_PDF_S3_BUCKET}}" # default s3://prod-elife-epp-pdf/data

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
    manifestFile="${tmpDir}/manifest.xml"
    xmlFile=$(cat ${manifestFile} | sed 's/xmlns=".*"//g' | xmllint -xpath 'string(/manifest/item[@type="article"]/instance[@media-type="application/xml"]/@href)' -)
    xmlFileDir=$(dirname ${xmlFile})

    echo -n "getting doi from $tmpDir/$xmlFile ... "
    doi=$(cat $tmpDir/$xmlFile | sed 's/xmlns=".*"//g' | xmllint -xpath 'string(/article/front/article-meta/article-id[@pub-id-type="doi"])' -)
    echo "'$doi'."

    outputDir="$DATA_DIR/$doi"
    # id is used for the filename of the xml file in the outputDir. Will be the portion of the doi after the last forward slash
    id=$(basename $outputDir)
    uuid=$(basename -s .meca $file)

    echo "creating $outputDir"
    mkdir -p "$outputDir"

    echo "$uuid" >"$outputDir/source.txt"

    pull_docker_image
    echo "correct some bioRxiv/Encoda XML issues and store $outputDir/$id.xml..."
    cat "$tmpDir/$xmlFile" | docker run --rm -i ghcr.io/elifesciences/enhanced-preprints-biorxiv-xslt:latest > "$outputDir/$id.xml"
    echo "transform.sh successfully run"

    echo "getting image paths from ${manifestFile} ..."
    images=$(cat ${manifestFile} | sed 's/xmlns=".*"//g' | xmllint -xpath '//instance[starts-with(@media-type,"image/")]/@href' - | sed 's/href="\([^"]*\)"/\1/g')
    for image in $images; do
        imageDir="$(dirname ${image})"
        mkdir -p "${outputDir}${imageDir#${xmlFileDir}}"
        cp $tmpDir/$image "${outputDir}/${image#${xmlFileDir}/}"
    done

    echo "Introduce PDF, if available"
    aws s3 sync ${PDF_S3_BUCKET}/${doi} ${outputDir}

    echo "cleaning up..."
    rm -R $tmpDir
done
