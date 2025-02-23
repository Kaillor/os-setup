#!/bin/bash
setup() {
  local script_directory
  script_directory="$(dirname "${BASH_SOURCE[0]}")"

  local -n system_operating_system="$1"

  local operating_system
  setup_menu "Operating system" "$script_directory" "operating_system"
  system_operating_system+=("$operating_system")

  # shellcheck source=/dev/null
  source "$script_directory/$operating_system/setup.sh"
  "$operating_system" "system_operating_system"

  return 0
}
