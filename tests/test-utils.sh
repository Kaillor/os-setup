#!/bin/bash
TESTS_DIRECTORY="$(dirname "${BASH_SOURCE[0]}")"
readonly TESTS_DIRECTORY

load "$TESTS_DIRECTORY/bats/assert/load.bash"
load "$TESTS_DIRECTORY/bats/file/load.bash"
load "$TESTS_DIRECTORY/bats/support/load.bash"

declare status

assert_line_log() {
  local -i index="$1"
  local level="$2"
  local message="$3"

  assert_line --index "$index" --regexp "\[[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}\.[0-9]{3}\] \[\[[0-9]{2}m$level\[0m\] $message"

  return 0
}

assert_status() {
  local -i expected_status="$1"

  assert_equal "$status" "$expected_status"

  return 0
}

count_files() {
  local directory="$1"

  find "$directory" -maxdepth 1 -type f | wc -l

  return 0
}
