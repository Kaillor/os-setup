#!/bin/bash
load "../test/test-util.sh"
load "../script/script-util.sh"

setup() {
  load "./setup.sh"
}

@test "setup | output and continue with operating system" {
  mock_command "source"
  mock_command "debian"

  run "setup" "system" <<< "1"
  assert_success
  assert_output "Operating system:
 1. debian
Type 'exit' to quit.

MOCK: source \"$BATS_TEST_DIRNAME/./debian/setup.sh\"
MOCK: debian \"system_operating_system\""
}

@test "setup | operating system added" {
  mock_command "source"
  mock_command "debian"

  local -a system=()
  setup "system" <<< "1"
  assert_equal "${system[*]}" "debian"
}
