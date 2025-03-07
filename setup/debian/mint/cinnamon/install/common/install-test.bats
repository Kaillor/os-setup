#!/bin/bash
load "../../../../../../test/test-utils.sh"

@test "install" {
  run_script_with_mocked_commands "$BATS_TEST_DIRNAME/install.sh" "source" "apply_patches"
  assert_success

  assert_output "MOCK: source \"./../../../../../../script/patch/patch-utils.sh\"
MOCK: apply_patches \"./patches\""
}
