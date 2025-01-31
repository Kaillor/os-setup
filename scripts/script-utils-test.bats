#!/bin/bash
load "../tests/test-utils.sh"

setup() {
  load "./script-utils.sh"
  cp -r "$TESTS_DIRECTORY/resources/script-utils" "/tmp"
}

teardown() {
  rm -r "/tmp/script-utils"
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

@test "setup_menu | invalid input" {
  local menu_selection
  run setup_menu "Menu label" "/tmp/script-utils/setup-menu" "menu_selection"
  # TODO: Simulate user input
  assert_success

  assert_line --index 0 "Menu label:"
}
