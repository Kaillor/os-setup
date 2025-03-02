#!/bin/bash
usage() {
  printf "Usage: %s <path>\n" "$(basename "${BASH_SOURCE[0]}")"
  printf "  path        Path that corresponds to a file containing a list of\n"
  printf "              absolute file paths that need to be reverted, or a\n"
  printf "              directory. If the path is a directory, all child\n"
  printf "              directories are searched for files named\n"
  printf "              '%s' which must contain a list of absolute\n" "$FILES_TO_PATCH_NAME"
  printf "              file paths that need to be reverted. Corresponding\n"
  printf "              backup files must be placed next to each file processed\n"
  printf "              this way in a directory called '%s' and have the\n" "$BACKUP_DIRECTORY_NAME"
  printf "              same name as the file to be reverted."
}

main() {
  local script_directory
  script_directory="$(dirname "${BASH_SOURCE[0]}")"
  source "$script_directory/../script-utils.sh"
  source "$script_directory/patch-utils.sh"

  if [[ ! $# -eq 1 ]]; then
    usage
    return 2
  fi

  require_sudo

  local path="$1"

  run_and_log "revert_patches $path"

  return 0
}

main "$@"
