#!/bin/bash
ROOT_DIRECTORY="$(dirname "${BASH_SOURCE[0]}")/.."
readonly ROOT_DIRECTORY

load "$ROOT_DIRECTORY/test/bats/assert/load.bash"
load "$ROOT_DIRECTORY/test/bats/file/load.bash"
load "$ROOT_DIRECTORY/test/bats/support/load.bash"

declare status

assert_exit() {
  local script="$1"
  local command="$2"
  local -i expected_status="$3"

  run bash -c "source $script; $command; exit $((expected_status + 1))"
  assert_status "$expected_status"

  return 0
}

assert_file_count() {
  local directory="$1"
  local expected_count="$2"

  assert_equal "$(find "$directory" -maxdepth 1 -type f | wc -l)" "$expected_count"

  return 0
}

assert_file_log_name() {
  local file="$1"
  local script_name="$2"

  assert_regex "$(basename "$file")" "^[0-9]{4}-[0-9]{2}-[0-9]{2}_[0-9]{2}:[0-9]{2}:[0-9]{2}_$script_name.log$"

  return 0
}

assert_line_log() {
  local -i index="$1"
  local level="$2"
  local message="$3"

  assert_line -n "$index" --regexp "$(line_log_regex "$level" "$message")"

  return 0
}

line_log_regex() {
  local level="$1"
  local message="$2"

  printf "^\[[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}\.[0-9]{3}\] \[\[[0-9]{2}m%s\[0m\] %s$" "$level" "$message"

  return 0
}

assert_status() {
  local -i expected_status="$1"

  assert_equal "$status" "$expected_status"

  return 0
}

replace_all_in_file() {
  local replace="$1"
  local replacement="$2"
  local file="$3"

  sed -i "s|$replace|$replacement|g" "$file"

  return 0
}
