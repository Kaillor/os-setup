#!/bin/bash
source "./patch-utils.sh"

usage() {
    echo "Usage: $(basename "$0") <file>"
    echo "  file        File that contains a list of absolute filepaths which"
    echo "              need to be reverted. Corresponding original files need"
    echo "              to be placed next to this file in a directory called"
    echo "              $backupDirectoryName and have the same name as the"
    echo "              file."
    exit 1
}

if [[ ! $# -eq 1 ]]; then
    usage
fi

fileWithListOfFilesToRevert=$(realpath "$1")
revertPatches "$fileWithListOfFilesToRevert"
