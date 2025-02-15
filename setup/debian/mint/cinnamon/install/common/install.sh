#!/bin/bash
main() {
  local script_directory
  script_directory="$(dirname "${BASH_SOURCE[0]}")"

  bash "$script_directory/../../../../../../script/apply-patches.sh" "$script_directory/patches"

  return 0
}

main "$@"
