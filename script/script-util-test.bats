#!/bin/bash
load "../test/test-util.sh"

ORIGINAL_DIRECTORY="$TEST_RESOURCES_DIRECTORY/script-util"
SCRIPT_UNDER_TEST="$BATS_TEST_DIRNAME/script-util.sh"

setup() {
  load "./script-util.sh"
  TEST_TEMP_DIR="$(temp_make)"
}

teardown() {
  temp_del "$TEST_TEMP_DIR"
}

@test "require_sudo | authenticated" {
  run "require_sudo"
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

  run "require_sudo"
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

  run "require_sudo"
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

@test "setup_menu | exit" {
  cp -r "$ORIGINAL_DIRECTORY/." "$TEST_TEMP_DIR"

  assert_exit "$SCRIPT_UNDER_TEST" "setup_menu \"Menu label\" \"$TEST_TEMP_DIR/setup-menu\" \"menu_selection\" <<< \"exit\"" 0
}

@test "setup_menu | selection | output" {
  cp -r "$ORIGINAL_DIRECTORY/." "$TEST_TEMP_DIR"

  run "setup_menu" "Menu label" "$TEST_TEMP_DIR/setup-menu" "menu_selection" <<< "2"
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
  run "menu" "Menu label" "options" "selection" <<< "2"
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
  run "menu" "Menu label" "options" "selection" <<< $'a\n0\n4\n2'
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
