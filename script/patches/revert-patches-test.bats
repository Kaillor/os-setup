#!/bin/bash
load "../../tests/test-utils.sh"

setup() {
  load "./patch-utils.sh"
  cp -r "$ROOT_DIRECTORY/tests/resources/patches/revert-patches" "/tmp"
}

teardown() {
  rm -r "/tmp/revert-patches"
}

@test "main | usage" {
  run "$BATS_TEST_DIRNAME/revert-patches.sh"
  assert_status 2
  assert_output --partial 'Usage: revert-patches.sh <path>'
}

@test "main | revert patches" {
  local directory="/tmp/revert-patches"

  run "$BATS_TEST_DIRNAME/revert-patches.sh" "$directory"
  assert_success

  assert_line_log 0 "INFO" "Searching for files named '$FILES_TO_PATCH_NAME' in '$directory'."
  assert_line_log 1 "INFO" "Reverting patches of files in '$directory/files-to-patch'."
}
