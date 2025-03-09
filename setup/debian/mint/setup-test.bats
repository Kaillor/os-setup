#!/bin/bash
load "../../../test/test-util.sh"
load "../../../script/script-util.sh"

setup() {
  load "./setup.sh"
}

@test "mint | output" {
  run "mint" "system" <<< "exit"
  assert_success
  assert_output "Flavor:
 1. cinnamon
Type 'exit' to quit."
}

@test "mint | flavor added" {
  local -a system=("operating_system" "distribution")
  mint "system" <<< "1"
  assert_equal "${system[*]}" "operating_system distribution cinnamon"
}
