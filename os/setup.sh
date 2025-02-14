#!/bin/bash
usage() {
  printf "Usage: %s <array_name>\n" "$(basename "${BASH_SOURCE[0]}")"
  printf "  array_name  Name of the array that will be referenced by name and\n"
  printf "              populated with the options selected\n"
}

main() {
  local script_directory
  script_directory="$(dirname "${BASH_SOURCE[0]}")"
  source "$script_directory/../scripts/script-utils.sh"

  if [[ ! $# -eq 1 ]]; then
    usage
    return 2
  fi

  local -n system_operating_system="$1"

  local operating_system
  setup_menu "Operating system" "$script_directory" "operating_system"
  system_operating_system+=("$operating_system")

  # shellcheck source=/dev/null
  source "$script_directory/$operating_system/setup.sh" "system_operating_system"

  return 0
}

main "$@"
