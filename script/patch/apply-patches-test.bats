#!/bin/bash
load "../../test/test-util.sh"

SCRIPT_UNDER_TEST="$BATS_TEST_DIRNAME/apply-patches.sh"

@test "main | usage" {
  run "$SCRIPT_UNDER_TEST"
  assert_status 2
  assert_output --partial "Usage: apply-patches.sh <path>"
}

@test "main | apply patches" {
  run_script_with_mocked_commands -s "$SCRIPT_UNDER_TEST" -a "path" -m "source" -m "require_sudo" -m "run_and_log"
  assert_success

  assert_output "MOCK: source \"./../script-util.sh\"
MOCK: require_sudo
MOCK: run_and_log \"apply_patches path\""
}
