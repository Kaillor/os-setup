#!/bin/bash
load "../../test-util.sh"

@test "setup runs successfully" {
  local -a log_files=( /*_setup.log )
  assert_equal "${#log_files[@]}" 1

  local log_file="${log_files[0]}"
  assert_file_not_contains "$log_file" "\[WARNING\]"
  assert_file_not_contains "$log_file" "\[ERROR\]"
}

# TODO add more tests
