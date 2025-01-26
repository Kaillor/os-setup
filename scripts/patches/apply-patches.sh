#!/bin/bash
source "$(dirname "${BASH_SOURCE[0]}")/patch-utils.sh"

usage() {
  printf "Usage: %s <file>\n" "$(basename "$0")"
  printf "  file        File that contains a list of absolute filepaths which\n"
  printf "              need to be patched. Corresponding patch files need to\n"
  printf "              be placed next to this file in a directory called\n"
  printf "              %s and have the same name as the file\n" "$patchDirectoryName"
  printf "              plus the extension '.patch'. Original files will be\n"
  printf "              backed up in a directory called %s\n" "$backupDirectoryName"
  printf "              next to this file.\n"
}

if [[ ! $# -eq 1 ]]; then
  usage
  exit 2
fi

fileWithListOfFilesToPatch="$(realpath "$1")"
applyPatches "$fileWithListOfFilesToPatch"
exit "$?"
