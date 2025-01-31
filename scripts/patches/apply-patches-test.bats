#!/bin/bash
load "../../tests/test-utils.sh"

setup() {
  load "./patch-utils.sh"
  cp -r "$ROOT_DIRECTORY/tests/resources/patches/apply-patches" "/tmp"
}

teardown() {
  rm -r "/tmp/apply-patches"
}

@test "main | usage" {
  run "$BATS_TEST_DIRNAME/apply-patches.sh"
  assert_status 2
  assert_output --partial 'Usage: apply-patches.sh <path>'
}

@test "main | apply patches" {
  local directory="/tmp/apply-patches"

  run "$BATS_TEST_DIRNAME/apply-patches.sh" "$directory"
  assert_success

  assert_line_log 0 "INFO" "Searching for files named '$FILES_TO_PATCH_NAME' in '$directory'."
  assert_line_log 1 "INFO" "Applying patches to files in '$directory/files-to-patch'."
}
