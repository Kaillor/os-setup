#!/bin/bash
load "../test/test-utils.sh"

setup() {
  load "./script-utils.sh"
  TEST_TEMP_DIR="$(temp_make)"
  cp -r "$ROOT_DIRECTORY/test/resources/script-utils" "$TEST_TEMP_DIR"
}

teardown() {
  temp_del "$TEST_TEMP_DIR"
}

@test "info" {
  run info "info message"
  assert_success
  assert_line_log 0 "INFO" "info message"
}

@test "warning" {
  run warning "warning message"
  assert_success
  assert_line_log 0 "WARNING" "warning message"
}

@test "error" {
  run error "error message"
  assert_success
  assert_line_log 0 "ERROR" "error message"
}

@test "setup_menu | exit" {
  assert_exit "$ROOT_DIRECTORY/script/script-utils.sh" "setup_menu \"Menu label\" \"$TEST_TEMP_DIR/script-utils/setup-menu\" \"menu_selection\" <<< \"exit\"" 0
}

@test "setup_menu | selection | output" {
  run setup_menu "Menu label" "$TEST_TEMP_DIR/script-utils/setup-menu" "menu_selection" <<< "2"
  assert_success
  assert_output "Menu label:
 1. option0
 2. option1
 3. option2
Type 'exit' to quit."
}

@test "setup_menu | selection | variable set" {
  local menu_selection
  setup_menu "Menu label" "$TEST_TEMP_DIR/script-utils/setup-menu" "menu_selection" <<< "2"
  assert_equal "$menu_selection" "option1"
}

@test "menu | exit" {
  assert_exit "$ROOT_DIRECTORY/script/script-utils.sh" "menu \"Menu label\" \"options\" \"selection\" <<< \"exit\"" 0
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
