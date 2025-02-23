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

replace_all_in_file() {
  local replace="$1"
  local replacement="$2"
  local file="$3"

  sed -i "s|$replace|$replacement|g" "$file"

  return 0
}
