#!/bin/bash
main() {
  local script_directory
  script_directory="$(dirname "${BASH_SOURCE[0]}")"
  source "$script_directory/../../../../../../script/script-util.sh"

  apply_patches "$script_directory/patches"

  return 0
}

main "$@"
