#!/bin/bash
load "../../../../../../test/test-util.sh"

@test "install" {
  run_script_with_mocked_commands -s "$BATS_TEST_DIRNAME/install.sh" -m "source" -m "apply_patches"
  assert_success

  assert_output "MOCK: source \"./../../../../../../script/script-util.sh\"
MOCK: apply_patches \"./patches\""
}
