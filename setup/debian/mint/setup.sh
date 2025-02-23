#!/bin/bash
mint() {
  local script_directory
  script_directory="$(dirname "${BASH_SOURCE[0]}")"

  local -n system_flavor="$1"

  local flavor
  setup_menu "Flavor" "$script_directory" "flavor"
  system_flavor+=("$flavor")

  return 0
}
