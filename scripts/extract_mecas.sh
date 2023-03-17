#!/bin/bash
set -e

# This requires xmllint and macos/bsd sed
# pass the directory of mecas as first param, and output directory as second
# example run:
# ./scripts/extract_mecas.sh incoming/ data/

for file in $1/*; do
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

    outputDir="$2/$doi"
    id=$(basename $outputDir)
    uuid=$(basename -s .meca $file)

    echo "creating $outputDir"
    mkdir -p "$outputDir"

    echo "$uuid" > "$outputDir/source.txt"

    if [ "$doiPrefix" = "10.1101" ]; then
        echo "correct some bioRxiv/Encoda XML issues and store $outputDir/$id.xml..."
        cat "$tmpDir/$xmlFile" | docker run --rm -i ghcr.io/elifesciences/enhanced-preprints-biorxiv-xslt:latest /app/scripts/transform.sh --doi $doiSuffix > "$outputDir/$id.xml"
        echo "transform.sh --doi $doiSuffix successfully run"
    else
        echo "Skipping XML correction for DOI prefix $doiPrefix"
        cp "$tmpDir/$xmlFile" "$outputDir/$id.xml"
    fi

    echo "copy all tiff content to $outputDir..."
    cp $tmpDir/content/*.tif "$outputDir/" || true
    cp $tmpDir/content/*.gif "$outputDir/" || true
    cp $tmpDir/content/*.jpg "$outputDir/" || true

    echo "cleaning up..."
    rm -R $tmpDir
done
