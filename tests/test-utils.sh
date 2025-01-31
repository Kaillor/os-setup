#!/bin/bash
declare status

rootDirectory=$(git rev-parse --show-toplevel)

load "$rootDirectory/tests/bats/assert/load.bash"
load "$rootDirectory/tests/bats/file/load.bash"
load "$rootDirectory/tests/bats/support/load.bash"

assert_line_log() {
  index="$1"
  level="$2"
  message="$3"
  assert_line --index "$index" --regexp "\[[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}\.[0-9]{3}\] \[\[[0-9]{2}m$level\[0m\] $message"
}

assert_status() {
  expectedStatus="$1"
  assert_equal "$status" "$expectedStatus"
}

countFiles() {
  directory="$1"
  find "$directory" -maxdepth 1 -type f | wc -l
}
