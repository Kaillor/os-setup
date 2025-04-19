#!/bin/bash
load "../../test/test-util.sh"

declare stderr

setup() {
  load "./log-util.sh"
  TEST_TEMP_DIR="$(temp_make)"
}

teardown() {
  temp_del "$TEST_TEMP_DIR"
}

@test "info" {
  bats_require_minimum_version 1.5.0
  run --separate-stderr "info" "info message"
  assert_success
  assert_regex "$output" "$(line_log_regex "INFO" "info message")"
  assert_equal "$stderr" ""
}

@test "warning" {
  bats_require_minimum_version 1.5.0
  run --separate-stderr "warning" "warning message"
  assert_success
  assert_equal "$output" ""
  assert_regex "$stderr" "$(line_log_regex "WARNING" "warning message")"
}

@test "error" {
  bats_require_minimum_version 1.5.0
  run --separate-stderr "error" "error message"
  assert_success
  assert_equal "$output" ""
  assert_regex "$stderr" "$(line_log_regex "ERROR" "error message")"
}

@test "run_and_log | success" {
  cd "$TEST_TEMP_DIR"
  run run_and_log "echo \"message [31m0[0m\"; echo \"message [33m1[0m\" >&2; echo \"message [34m2[0m\""
  assert_output "message [31m0[0m
message [33m1[0m
message [34m2[0m
[32mScript executed successfully.[0m"

  assert_file_count "$TEST_TEMP_DIR" 1
  local file
  file="$(find "$TEST_TEMP_DIR" -mindepth 1 -maxdepth 1 -type f)"
  assert_file_log_name "$file" "test_functions"
  assert_file_contains "$file" "message 0
message 1
message 2"
}

@test "run_and_log | warning" {
  cd "$TEST_TEMP_DIR"
  run run_and_log "echo \"message [31m0[0m\"; echo \"message [33m[WARNING][0m\" >&2; echo \"message [34m2[0m\""
  assert_output "message [31m0[0m
message [33m[WARNING][0m
message [34m2[0m
[33mWarnings occurred during the execution of the script.[0m"

  assert_file_count "$TEST_TEMP_DIR" 1
  local file
  file="$(find "$TEST_TEMP_DIR" -mindepth 1 -maxdepth 1 -type f)"
  assert_file_log_name "$file" "test_functions"
  assert_file_contains "$file" "message 0
message [WARNING]
message 2"
}

@test "run_and_log | error" {
  cd "$TEST_TEMP_DIR"
  run run_and_log "echo \"message [31m[ERROR][0m\"; echo \"message [33m1[0m\" >&2; echo \"message [34m2[0m\""
  assert_output "message [31m[ERROR][0m
message [33m1[0m
message [34m2[0m
[31mErrors occurred during the execution of the script.[0m"

  assert_file_count "$TEST_TEMP_DIR" 1
  local file
  file="$(find "$TEST_TEMP_DIR" -mindepth 1 -maxdepth 1 -type f)"
  assert_file_log_name "$file" "test_functions"
  assert_file_contains "$file" "message [ERROR]
message 1
message 2"
}

@test "run_and_log | warning and error" {
  cd "$TEST_TEMP_DIR"
  run run_and_log "echo \"message [31m[ERROR][0m\"; echo \"message [33m[WARNING][0m\" >&2; echo \"message [34m2[0m\""
  assert_output "message [31m[ERROR][0m
message [33m[WARNING][0m
message [34m2[0m
[33mWarnings occurred during the execution of the script.[0m
[31mErrors occurred during the execution of the script.[0m"

  assert_file_count "$TEST_TEMP_DIR" 1
  local file
  file="$(find "$TEST_TEMP_DIR" -mindepth 1 -maxdepth 1 -type f)"
  assert_file_log_name "$file" "test_functions"
  assert_file_contains "$file" "message [ERROR]
message [WARNING]
message 2"
}
