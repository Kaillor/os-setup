#!/bin/bash
usage() {
  printf "Usage: %s <array_name>\n" "$(basename "${BASH_SOURCE[0]}")"
  printf "  array_name  Name of the array that will be referenced by name and\n"
  printf "              populated with the options selected\n"
}

main() {
  local script_directory
  script_directory="$(dirname "${BASH_SOURCE[0]}")"
  source "$script_directory/../../script/script-utils.sh"

  if [[ ! $# -eq 1 ]]; then
    usage
    return 2
  fi

  local -n system_distribution="$1"

  local distribution
  setup_menu "Distribution" "$script_directory" "distribution"
  system_distribution+=("$distribution")

  # shellcheck source=/dev/null
  source "$script_directory/$distribution/setup.sh" "system_distribution"

  return 0
}

main "$@"
