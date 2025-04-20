#!/bin/bash
usage() {
  printf "Usage: %s <path>\n" "$(basename "${BASH_SOURCE[0]}")"
  printf "  path        Path that corresponds to a file containing a list of\n"
  printf "              absolute file paths that need to be patched, or a\n"
  printf "              directory. If the path is a directory, all child\n"
  printf "              directories are searched for files named\n"
  printf "              '%s' which must contain a list of absolute\n" "$FILES_TO_PATCH_NAME"
  printf "              file paths that need to be patched. Corresponding patch\n"
  printf "              files must be placed next to each file processed this\n"
  printf "              way in a directory called '%s' and have the same\n" "$PATCH_DIRECTORY_NAME"
  printf "              name as the file to be patched plus the extension\n"
  printf "              '.patch'. The original files will be backed up in the\n"
  printf "              original directory with the extension '.orig'.\n"
}

main() {
  source "$(dirname "${BASH_SOURCE[0]}")/../script-util.sh"

  if [[ ! $# -eq 1 ]]; then
    usage
    return 2
  fi

  require_sudo

  local path="$1"

  run_and_log "apply_patches $path"

  return 0
}

main "$@"
