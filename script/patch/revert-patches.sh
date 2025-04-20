#!/bin/bash
usage() {
  cat << EOF
Usage: $(basename "${BASH_SOURCE[0]}") <path>
  path        Path that corresponds to a file containing a list of absolute
              file paths that need to be reverted, or a directory. If the path
              is a directory, all child directories are searched for files
              named '$FILES_TO_PATCH_NAME' which must contain a list of absolute file
              paths that need to be reverted. Corresponding patch files that
              must be reverted must be placed next to each file processed this
              way in a directory called '$PATCH_DIRECTORY_NAME' and have the same name as the
              file to be reverted plus the extension '.patch'.
EOF
}

main() {
  source "$(dirname "${BASH_SOURCE[0]}")/../script-util.sh"

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
