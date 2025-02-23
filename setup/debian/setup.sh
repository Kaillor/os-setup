#!/bin/bash
debian() {
  local script_directory
  script_directory="$(dirname "${BASH_SOURCE[0]}")"

  local -n system_distribution="$1"

  local distribution
  setup_menu "Distribution" "$script_directory" "distribution"
  system_distribution+=("$distribution")

  # shellcheck source=/dev/null
  source "$script_directory/$distribution/setup.sh"
  "$distribution" "system_distribution"

  return 0
}
