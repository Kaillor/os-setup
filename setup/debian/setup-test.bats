#!/bin/bash
load "../../test/test-util.sh"
load "../../script/script-util.sh"

setup() {
  load "./setup.sh"
}

@test "debian | output and continue with distribution" {
  mock_command "source"
  mock_command "mint"

  run "debian" "system" <<< "1"
  assert_success
  assert_output "Distribution:
 1. mint
Type 'exit' to quit.

MOCK: source \"$BATS_TEST_DIRNAME/./mint/setup.sh\"
MOCK: mint \"system_distribution\""
}

@test "debian | distribution added" {
  mock_command "source"
  mock_command "mint"

  local -a system=("operating_system")
  debian "system" <<< "1"
  assert_equal "${system[*]}" "operating_system mint"
}
