#!/bin/bash
load "../../test/test-util.sh"
load "../../script/script-util.sh"

setup() {
  load "./setup.sh"
}

@test "debian | output" {
  run "debian" "system" <<< "exit"
  assert_success
  assert_output "Distribution:
 1. mint
Type 'exit' to quit."
}

@test "debian | distribution added" {
  local -a system=("operating_system")
  debian "system" <<< "1"
  assert_equal "${system[*]}" "operating_system mint"
}
