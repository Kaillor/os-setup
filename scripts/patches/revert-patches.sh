#!/bin/bash
usage() {
  printf "Usage: %s <file>\n" "$(basename "${BASH_SOURCE[0]}")"
  printf "  file        Path that corresponds to a file containing a list of\n"
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
  source "$(dirname "${BASH_SOURCE[0]}")/patch-utils.sh"

  if [[ ! $# -eq 1 ]]; then
    usage
    return 2
  fi

  local list_of_files_to_revert="$1"

  if file_exists "$list_of_files_to_revert"; then
    revert_patches "$(realpath "$list_of_files_to_revert")"
  elif directory_exists "$list_of_files_to_revert"; then
    find "$list_of_files_to_revert" -name "$FILES_TO_PATCH_NAME" -print0 | xargs -0 -I {} revert_patches "$(realpath "{}")"
  else
    error "Path '$list_of_files_to_revert' does not exist."
    return 1
  fi

  return 0
}

main "$@"
