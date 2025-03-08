#!/bin/bash
load "../../../../../test/test-utils.sh"

@test "install" {
  assert_file_empty_script "$BATS_TEST_DIRNAME/install.sh"
}
