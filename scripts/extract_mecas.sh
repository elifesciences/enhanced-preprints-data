#!/bin/bash
set -e

# This requires xmllint and macos/bsd sed
# pass the directory of mecas as first param, and output directory as second
# example run:
# ./scripts/extract_mecas.sh mecas/ data/

NODE_SCRIPT=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )/fix_biorxiv_xml.js
echo $NODE_SCRIPT

for file in $1/*; do
    tmpDir="/tmp/mecaunzip"
    rm -R $tmpDir || true

    echo $tmpDir

    echo "extracting $file..."
    unzip -q $file -d $tmpDir

    echo "getting article XML path from $tmpDir/manifest.xml ..."
    xmlFile=$(cat $tmpDir/manifest.xml | sed 's/xmlns=".*"//g' | xmllint -xpath 'string(/manifest/item[@type="article"]/instance[@media-type="application/xml"]/@href)' -)


    echo -n "getting doi from $tmpDir/$xmlFile ... "
    doi=$(cat $tmpDir/$xmlFile | sed 's/xmlns=".*"//g' | xmllint -xpath 'string(/article/front/article-meta/article-id)' -)
    echo "'$doi'."

    outputDir="$2/$doi"
    id=$(basename $outputDir)
    uuid=$(basename -s .meca $file)


    echo "creating $outputDir"
    mkdir -p "$outputDir"

    echo "$uuid" > "$outputDir/source.txt"

    echo "cp $tmpDir/$xmlFile to $outputDir/$id.xml..."
    cp "$tmpDir/$xmlFile" "$outputDir/$id.xml"

    echo "and correct some encoda XML issues..."
    # sed -i '' 's|string-name>|name>|g' "$outputDir/$id.xml"  # string-name -> name
    # sed -i '' -E 's|<label>(.*)</label><title>|<title><label>\1</label> |g' "$outputDir/$id.xml" # <label>1</label><title> -> <title><label>1</label>
    # sed -i '' 's|^<label>([[:digit:]\.]*)</label>||g' "$outputDir/$id.xml" # <label>1</label>\n -> *delete it*
    # sed -i '' 's|</table-wrap>|</fig>|g' "$outputDir/$id.xml"  # table-wrap -> figure
    # sed -i '' 's|<table-wrap|<fig|g' "$outputDir/$id.xml"  # table-wrap -> figure
    node $NODE_SCRIPT "$outputDir/$id.xml"

    echo "copy all tiff content to $outputDir..."
    cp $tmpDir/content/*.tif "$outputDir/" || true
    cp $tmpDir/content/*.gif "$outputDir/" || true

    echo "cleaning up..."
    rm -R $tmpDir
done
