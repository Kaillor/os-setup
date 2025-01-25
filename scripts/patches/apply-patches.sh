#!/bin/bash
source "./patch-utils.sh"

usage() {
    echo "Usage: $(basename "$0") <file>"
    echo "  file        File that contains a list of absolute filepaths which"
    echo "              need to be patched. Corresponding patch files need to"
    echo "              be placed next to this file in a directory called"
    echo "              $patchDirectoryName and have the same name as the file"
    echo "              plus the extension '.patch'. Original files will be"
    echo "              backed up in a directory called $backupDirectoryName"
    echo "              next to this file."
    exit 1
}

if [[ ! "$#" -eq 1 ]]; then
    usage
fi

fileWithListOfFilesToPatch="$(realpath "$1")"
applyPatches "$fileWithListOfFilesToPatch"
