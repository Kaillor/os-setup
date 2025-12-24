#!/bin/bash
script_directory="$(dirname "${BASH_SOURCE[0]}")"
source "$script_directory/../../script/script-util.sh"

run_tests() {
  local -a options
  setup_child_directories "$directory" "options"
  for i in "${!options[@]}"; do
    option="${options[$i]}"
    if [ -f "$directory/$option/setup.sh" ]; then
      # TODO continue
    else
      local container_name = "os-setup_integration-test_$(IFS=-; echo "${options[*]}")"
      docker "build" -t "$container_name" -f "./test/integration/$(IFS=/; echo "${options[*]}")/Dockerfile" .
      docker "run" --rm "$container_name" bash -c "source ./os-setup/test/integration/test.sh && run_integration_tests ${options[@]}"
    fi
  done
}

run_integration_tests() {
  source "$script_directory/../test.sh"

  local -a options=("$@")

  set -euo pipefail

  ./os-setup/setup.sh <<< $'1\n1\n1\n1\ny'
  run_tests "os-setup/test/integration/$2-$3-$4/integration-test.bats"
}

__run_setup() {
  local -a options=("$@")
  ./os-setup/setup.sh <<< "$(printf '%s\n' "${options[@]}")"
}
