#!/bin/bash
load "../../../../../test/test-util.sh"

@test "install" {
  assert_file_empty_script "$BATS_TEST_DIRNAME/install.sh"
}
