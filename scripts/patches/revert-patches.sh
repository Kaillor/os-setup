#!/bin/bash
source "$(dirname "${BASH_SOURCE[0]}")/patch-utils.sh"

usage() {
  printf "Usage: %s <file>\n" "$(basename "$0")"
  printf "  file        File that contains a list of absolute filepaths which\n"
  printf "              need to be reverted. Corresponding original files need\n"
  printf "              to be placed next to this file in a directory called\n"
  printf "              %s and have the same name as the\n" "$backupDirectoryName"
  printf "              file.\n"
}

if [[ ! $# -eq 1 ]]; then
  usage
  exit 2
fi

fileWithListOfFilesToRevert="$(realpath "$1")"
revertPatches "$fileWithListOfFilesToRevert"
exit "$?"
