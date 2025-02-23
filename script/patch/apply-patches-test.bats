#!/bin/bash
load "../../test/test-utils.sh"

setup() {
  load "./patch-utils.sh"
  TEST_TEMP_DIR="$(temp_make)"
}

teardown() {
  temp_del "$TEST_TEMP_DIR"
}

@test "main | usage" {
  run "$BATS_TEST_DIRNAME/apply-patches.sh"
  assert_status 2
  assert_output --partial "Usage: apply-patches.sh <path>"
}

@test "main | apply patches" {
  cp -r "$ROOT_DIRECTORY/test/resources/patch/apply-patches/." "$TEST_TEMP_DIR"

  run "$BATS_TEST_DIRNAME/apply-patches.sh" "$TEST_TEMP_DIR"
  assert_success

  assert_line_log 0 "INFO" "Searching for files named '$FILES_TO_PATCH_NAME' in '$TEST_TEMP_DIR'."
  assert_line_log 1 "INFO" "Applying patches to files in '$TEST_TEMP_DIR/files-to-patch'."
}
