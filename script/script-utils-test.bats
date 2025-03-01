#!/bin/bash
load "../test/test-utils.sh"

ORIGINAL_DIRECTORY="$ROOT_DIRECTORY/test/resources/script-utils"
SCRIPT_UNDER_TEST="$BATS_TEST_DIRNAME/script-utils.sh"

declare stderr

setup() {
  load "$SCRIPT_UNDER_TEST"
  TEST_TEMP_DIR="$(temp_make)"
}

teardown() {
  temp_del "$TEST_TEMP_DIR"
}

@test "require_sudo | authenticated" {
  run require_sudo
  assert_success
  assert_output ""
}

@test "require_sudo | not authenticated | success" {
  # shellcheck disable=SC2317
  sudo() {
    if [[ "$1" == "-n" && "$2" == "true" ]]; then
      return 1
    fi
    if [[ "$1" == "-v" ]]; then
      return 0
    fi
    printf "Unexpected arguments for 'sudo': %s" "$*"
    exit 255
  }

  run require_sudo
  assert_success
  assert_output "This script requires root privileges. Please authenticate."
}

@test "require_sudo | not authenticated | fail | output" {
  sudo() {
    if [[ "$1" == "-n" && "$2" == "true" ]]; then
      return 1
    fi
    if [[ "$1" == "-v" ]]; then
      return 1
    fi
    printf "Unexpected arguments for 'sudo': %s" "$*"
    exit 255
  }

  run require_sudo
  assert_status 1
  assert_output "This script requires root privileges. Please authenticate."
}

@test "require_sudo | not authenticated | fail | exit" {
  assert_exit "$SCRIPT_UNDER_TEST" "sudo() {
  if [[ \"\$1\" == \"-n\" && \"\$2\" == \"true\" ]]; then
    return 1
  fi
  if [[ \"\$1\" == \"-v\" ]]; then
    return 1
  fi
  printf \"Unexpected arguments for 'sudo': %s\" \"\$*\"
  exit 255
}
require_sudo" 1
}

@test "info" {
  bats_require_minimum_version 1.5.0
  run --separate-stderr info "info message"
  assert_success
  assert_regex "$output" "$(line_log_regex "INFO" "info message")"
  assert_equal "$stderr" ""
}

@test "warning" {
  bats_require_minimum_version 1.5.0
  run --separate-stderr warning "warning message"
  assert_success
  assert_equal "$output" ""
  assert_regex "$stderr" "$(line_log_regex "WARNING" "warning message")"
}

@test "error" {
  bats_require_minimum_version 1.5.0
  run --separate-stderr error "error message"
  assert_success
  assert_equal "$output" ""
  assert_regex "$stderr" "$(line_log_regex "ERROR" "error message")"
}

@test "run_and_log" {
  cd "$TEST_TEMP_DIR"
  run run_and_log "echo \"message [31m0[0m\"; echo \"message [32m1[0m\" >&2; echo \"message [33m2[0m\""
  assert_output "message [31m0[0m
message [32m1[0m
message [33m2[0m"

  assert_file_count "$TEST_TEMP_DIR" 1
  local file
  file="$(find "$TEST_TEMP_DIR" -mindepth 1 -maxdepth 1 -type f)"
  assert_file_log_name "$file" "test_functions"
  assert_file_contains "$file" "message 0
message 1
message 2"
}

@test "setup_menu | exit" {
  cp -r "$ORIGINAL_DIRECTORY/." "$TEST_TEMP_DIR"

  assert_exit "$SCRIPT_UNDER_TEST" "setup_menu \"Menu label\" \"$TEST_TEMP_DIR/setup-menu\" \"menu_selection\" <<< \"exit\"" 0
}

@test "setup_menu | selection | output" {
  cp -r "$ORIGINAL_DIRECTORY/." "$TEST_TEMP_DIR"

  run setup_menu "Menu label" "$TEST_TEMP_DIR/setup-menu" "menu_selection" <<< "2"
  assert_success
  assert_output "Menu label:
 1. option0
 2. option1
 3. option2
Type 'exit' to quit."
}

@test "setup_menu | selection | variable set" {
  cp -r "$ORIGINAL_DIRECTORY/." "$TEST_TEMP_DIR"

  local menu_selection
  setup_menu "Menu label" "$TEST_TEMP_DIR/setup-menu" "menu_selection" <<< "2"
  assert_equal "$menu_selection" "option1"
}

@test "menu | exit" {
  assert_exit "$SCRIPT_UNDER_TEST" "menu \"Menu label\" \"options\" \"selection\" <<< \"exit\"" 0
}

@test "menu | selection | output" {
  local options=("option0" "option1" "option2")
  run menu "Menu label" "options" "selection" <<< "2"
  assert_success
  assert_output "Menu label:
 1. option0
 2. option1
 3. option2
Type 'exit' to quit."
}

@test "menu | selection | variable set" {
  local options=("option0" "option1" "option2")
  local selection
  menu "Menu label" "options" "selection" <<< "2"
  assert_equal "$selection" "option1"
}

@test "menu | selection | invalid | output" {
  local options=("option0" "option1" "option2")
  run menu "Menu label" "options" "selection" <<< $'a\n0\n4\n2'
  assert_success
  assert_output "Menu label:
 1. option0
 2. option1
 3. option2
Type 'exit' to quit.

Menu label:
 1. option0
 2. option1
 3. option2
Type 'exit' to quit.

Menu label:
 1. option0
 2. option1
 3. option2
Type 'exit' to quit.

Menu label:
 1. option0
 2. option1
 3. option2
Type 'exit' to quit."
}

@test "menu | selection | invalid | variable set" {
  # shellcheck disable=SC2034
  local options=("option0" "option1" "option2")
  local selection
  menu "Menu label" "options" "selection" <<< $'a\n0\n4\n2'
  assert_equal "$selection" "option1"
}
