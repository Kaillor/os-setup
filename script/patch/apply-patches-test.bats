#!/bin/bash
load "../../test/test-util.sh"

SCRIPT_UNDER_TEST="$BATS_TEST_DIRNAME/apply-patches.sh"

setup() {
  load "./patch-util.sh"
  TEST_TEMP_DIR="$(temp_make)"
}

teardown() {
  temp_del "$TEST_TEMP_DIR"
}

@test "main | usage" {
  run "$SCRIPT_UNDER_TEST"
  assert_status 2
  assert_output --partial "Usage: apply-patches.sh <path>"
}

@test "main | apply patches" {
  cp -r "$ROOT_DIRECTORY/test/resources/patch/apply-patches/." "$TEST_TEMP_DIR"

  cd "$TEST_TEMP_DIR"
  run "$SCRIPT_UNDER_TEST" "$TEST_TEMP_DIR"
  assert_success

  assert_line_log 0 "INFO" "Searching for files named '$FILES_TO_PATCH_NAME' in '$TEST_TEMP_DIR'."
  assert_line_log 1 "INFO" "Applying patches to files in '$TEST_TEMP_DIR/files-to-patch'."

  assert_file_count "$TEST_TEMP_DIR" 2
  local file
  file="$(find "$TEST_TEMP_DIR" -mindepth 1 -maxdepth 1 -type f -name "*.log")"
  assert_file_log_name "$file" "apply-patches"
}

@test "main | require sudo" {
  cd "$TEST_TEMP_DIR"
  run bash -c "sudo() {
  if [[ \"\$1\" == \"-n\" && \"\$2\" == \"true\" ]]; then
    return 1
  fi
  if [[ \"\$1\" == \"-v\" ]]; then
    return 0
  fi
  printf \"Unexpected arguments for 'sudo': %s\" \"\$*\"
  exit 255
}
source $SCRIPT_UNDER_TEST $TEST_TEMP_DIR"
  assert_success

  assert_line -n 0 "This script requires root privileges. Please authenticate."
  assert_line_log 1 "INFO" "Searching for files named '$FILES_TO_PATCH_NAME' in '$TEST_TEMP_DIR'."
}
