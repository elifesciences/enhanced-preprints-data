#!/bin/bash
set -e

# This requires git
# pass the remote url (organisation/repo) as first param
# example run:
# ./scripts/pre_sync_check.sh [GITHUB_ORG_AND_REPO]

SCRIPT_DIR="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
PARENT_DIR="$(dirname "${SCRIPT_DIR}")"
cd $PARENT_DIR

GITHUB_ORG_AND_REPO="${1:-elifesciences/enhanced-preprints-data}" # default elifesciences/enhanced-preprints-data

# Retrieve the remote alias and URL from the fetch detail using git remote -v
REMOTE_ALIAS=$(git remote -v | awk '{print $1}' | uniq)

# Check if the remote URL matches either of the expected values
REMOTE_URL=$(git config --get remote.$REMOTE_ALIAS.url)
if [[ "$REMOTE_URL" != "git@github.com:${GITHUB_ORG_AND_REPO}.git" && "$REMOTE_URL" != "https://github.com/${GITHUB_ORG_AND_REPO}.git" ]]; then
    echo "Error: Remote repository URL does not match expected value."
    exit 1
fi

git fetch $REMOTE_ALIAS master

# Check if there are any differences between the local data folder and the remote master branch data folder
if [ "$(git diff --name-only $REMOTE_ALIAS/master data/)" ]; then
  echo "Error: Differences found between local and remote data folder."
  exit 1
else
  echo "Success: Local data folder matches remote master branch data folder."
fi
