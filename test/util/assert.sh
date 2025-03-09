#!/bin/bash
declare status

assert_exit() {
  local script="$1"
  local command="$2"
  local -i expected_status="$3"

  run bash -c "source $script; $command; exit $((expected_status + 1))"
  assert_status "$expected_status"

  return 0
}

assert_line_log() {
  local -i index="$1"
  local level="$2"
  local message="$3"

  assert_line -n "$index" --regexp "$(line_log_regex "$level" "$message")"

  return 0
}

assert_status() {
  local -i expected_status="$1"

  assert_equal "$status" "$expected_status"

  return 0
}
