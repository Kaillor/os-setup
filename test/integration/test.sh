#!/bin/bash
script_directory="$(dirname "${BASH_SOURCE[0]}")"
source "$script_directory/../../script/script-util.sh"

run_tests() {
  local directory="$script_directory/../../setup"
  # shellcheck disable=SC2034
  local -a options_to_select
  # shellcheck disable=SC2034
  local -a option_indices_to_select

  __walk_setup_tree "$directory" "options_to_select" "option_indices_to_select"
}

__walk_setup_tree() {
  local current_directory="$1"
  local -n current_options_to_select="$2"
  local -n current_option_indices_to_select="$3"

  if [[ ! -f "$current_directory/setup.sh" ]]; then
    __run_tests_of "current_options_to_select" "current_option_indices_to_select"
    return 0
  fi

  local -a next_options
  setup_child_directories "$current_directory" "next_options"

  for i in "${!next_options[@]}"; do
    local next_option="${next_options[$i]}"
    local next_directory="$current_directory/$next_option"

    # shellcheck disable=SC2034
    local -a next_options_to_select=("${current_options_to_select[@]}" "$next_option")
    # shellcheck disable=SC2034
    local -a next_option_indices_to_select=("${current_option_indices_to_select[@]}" "$((i + 1))")

    __walk_setup_tree "$next_directory" "next_options_to_select" "next_option_indices_to_select"
  done
}

__run_tests_of() {
  local -n options_to_select="$1"
  local -n option_indices_to_select="$2"

  local slug
  slug="$(IFS=-; echo "${options_to_select[*]}")"

  local project_root="$script_directory/../.."
  local integration_dir="$project_root/test/integration/$slug"
  local dockerfile="$integration_dir/Dockerfile"
  local bats_file="$integration_dir/integration-test.bats"

  if [[ ! -f $dockerfile ]]; then
    printf "Skipping '%s': missing Dockerfile at %s\n" "$slug" "$dockerfile" >&2
    return 0
  fi

  if [[ ! -f $bats_file ]]; then
    printf "Skipping '%s': missing integration test at %s\n" "$slug" "$bats_file" >&2
    return 0
  fi

  local container_name="os-setup_integration-test_${slug}"
  ## TODO run integration tests for each profile
  local -a selections=("1" "${option_indices_to_select[@]}")

  local run_args
  printf -v run_args '%q ' "${selections[@]}" -- "${options_to_select[@]}"

  docker build -t "$container_name" -f "$dockerfile" "$project_root"
  docker run --rm "$container_name" bash -c "source /os-setup/test/integration/test.sh && run_integration_tests ${run_args}"
}

run_integration_tests() {
  source "$script_directory/../test.sh"

  local -a selections=()
  local -a path_names=()

  while [[ $# -gt 0 ]]; do
    if [[ $1 == "--" ]]; then
      shift
      path_names=("$@")
      break
    fi
    selections+=("$1")
    shift
  done

  set -euo pipefail

  __run_setup "${selections[@]}"

  local slug
  slug="$(IFS=-; echo "${path_names[*]}")"

  run_tests "os-setup/test/integration/${slug}/integration-test.bats"
}

__run_setup() {
  local -a selections=("$@")

  selections+=("y")

  ./os-setup/setup.sh <<< "$(printf '%s\n' "${selections[@]}")"
}
