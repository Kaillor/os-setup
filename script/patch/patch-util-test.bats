#!/bin/bash
load "../../test/test-util.sh"

ORIGINAL_DIRECTORY="$TEST_RESOURCES_DIRECTORY/patch/patch-util"

setup() {
  load "./../script-util.sh"
  TEST_TEMP_DIR="$(temp_make)"
  cp -r "$ORIGINAL_DIRECTORY/." "$TEST_TEMP_DIR"
}

teardown() {
  temp_del "$TEST_TEMP_DIR"
}

@test "apply_patches | path not found" {
  run "apply_patches" "$TEST_TEMP_DIR/not-found"
  assert_status 1
  assert_line_log 0 "ERROR" "Path '$TEST_TEMP_DIR/not-found' does not exist."
}

@test "apply_patches | ignore invalid lines in file with list of files to patch | empty lines" {
  replace_all_in_file "\$TEST_TEMP_DIR" "$TEST_TEMP_DIR" "$TEST_TEMP_DIR/apply-patches_invalid-lines_empty"

  run "apply_patches" "$TEST_TEMP_DIR/apply-patches_invalid-lines_empty"
  assert_success

  assert_line_log 0 "INFO" "Applying patches to files in '$TEST_TEMP_DIR/apply-patches_invalid-lines_empty'."
  assert_line_log 1 "INFO" "Patching file '$TEST_TEMP_DIR/files/before-patch/file-0'."
  assert_line_log 2 "INFO" "Patching file '$TEST_TEMP_DIR/files/before-patch/file-1'."

  assert_exist "$TEST_TEMP_DIR/files/before-patch/file-0.orig"
  assert_exist "$TEST_TEMP_DIR/files/before-patch/file-1.orig"

  assert_files_equal "$TEST_TEMP_DIR/files/before-patch/file-0" "$ORIGINAL_DIRECTORY/files/after-patch/file-0"
  assert_files_equal "$TEST_TEMP_DIR/files/before-patch/file-1" "$ORIGINAL_DIRECTORY/files/after-patch/file-1"
}

@test "apply_patches | ignore invalid lines in file with list of files to patch | comments" {
  replace_all_in_file "\$TEST_TEMP_DIR" "$TEST_TEMP_DIR" "$TEST_TEMP_DIR/apply-patches_invalid-lines_comments"

  run "apply_patches" "$TEST_TEMP_DIR/apply-patches_invalid-lines_comments"
  assert_success

  assert_line_log 0 "INFO" "Applying patches to files in '$TEST_TEMP_DIR/apply-patches_invalid-lines_comments'."
  assert_line_log 1 "INFO" "Patching file '$TEST_TEMP_DIR/files/before-patch/file-0'."
  assert_line_log 2 "INFO" "Patching file '$TEST_TEMP_DIR/files/before-patch/file-1'."

  assert_exist "$TEST_TEMP_DIR/files/before-patch/file-0.orig"
  assert_exist "$TEST_TEMP_DIR/files/before-patch/file-1.orig"

  assert_files_equal "$TEST_TEMP_DIR/files/before-patch/file-0" "$ORIGINAL_DIRECTORY/files/after-patch/file-0"
  assert_files_equal "$TEST_TEMP_DIR/files/before-patch/file-1" "$ORIGINAL_DIRECTORY/files/after-patch/file-1"
}

@test "apply_patches | skip missing files | files to patch" {
  replace_all_in_file "\$TEST_TEMP_DIR" "$TEST_TEMP_DIR" "$TEST_TEMP_DIR/apply-patches_missing-files_files-to-patch"

  run "apply_patches" "$TEST_TEMP_DIR/apply-patches_missing-files_files-to-patch"
  assert_success

  assert_line_log 0 "INFO" "Applying patches to files in '$TEST_TEMP_DIR/apply-patches_missing-files_files-to-patch'."
  assert_line_log 1 "INFO" "Patching file '$TEST_TEMP_DIR/files/before-patch/file-0'."
  assert_line_log 2 "WARNING" "File to patch '$TEST_TEMP_DIR/non-existing-file-0' not found."
  assert_line_log 3 "WARNING" "File to patch '$TEST_TEMP_DIR/non-existing-file-1' not found."
  assert_line_log 4 "INFO" "Patching file '$TEST_TEMP_DIR/files/before-patch/file-1'."

  assert_exist "$TEST_TEMP_DIR/files/before-patch/file-0.orig"
  assert_exist "$TEST_TEMP_DIR/files/before-patch/file-1.orig"

  assert_files_equal "$TEST_TEMP_DIR/files/before-patch/file-0" "$ORIGINAL_DIRECTORY/files/after-patch/file-0"
  assert_files_equal "$TEST_TEMP_DIR/files/before-patch/file-1" "$ORIGINAL_DIRECTORY/files/after-patch/file-1"
}

@test "apply_patches | skip missing files | patch files" {
  replace_all_in_file "\$TEST_TEMP_DIR" "$TEST_TEMP_DIR" "$TEST_TEMP_DIR/apply-patches_missing-files_patch-files"

  run "apply_patches" "$TEST_TEMP_DIR/apply-patches_missing-files_patch-files"
  assert_success

  assert_line_log 0 "INFO" "Applying patches to files in '$TEST_TEMP_DIR/apply-patches_missing-files_patch-files'."
  assert_line_log 1 "ERROR" "Patch file '$TEST_TEMP_DIR/$PATCH_DIRECTORY_NAME/file-2.patch' for file to patch '$TEST_TEMP_DIR/files/before-patch/file-2' not found."
  assert_line_log 2 "INFO" "Patching file '$TEST_TEMP_DIR/files/before-patch/file-0'."
  assert_line_log 3 "INFO" "Patching file '$TEST_TEMP_DIR/files/before-patch/file-1'."
  assert_line_log 4 "ERROR" "Patch file '$TEST_TEMP_DIR/$PATCH_DIRECTORY_NAME/file-3.patch' for file to patch '$TEST_TEMP_DIR/files/before-patch/file-3' not found."

  assert_exist "$TEST_TEMP_DIR/files/before-patch/file-0.orig"
  assert_exist "$TEST_TEMP_DIR/files/before-patch/file-1.orig"

  assert_files_equal "$TEST_TEMP_DIR/files/before-patch/file-0" "$ORIGINAL_DIRECTORY/files/after-patch/file-0"
  assert_files_equal "$TEST_TEMP_DIR/files/before-patch/file-1" "$ORIGINAL_DIRECTORY/files/after-patch/file-1"
}

@test "apply_patches | failed to patch file" {
  replace_all_in_file "\$TEST_TEMP_DIR" "$TEST_TEMP_DIR" "$TEST_TEMP_DIR/apply-patches_patch-failed"

  run "apply_patches" "$TEST_TEMP_DIR/apply-patches_patch-failed"
  assert_success

  assert_line_log 0 "INFO" "Applying patches to files in '$TEST_TEMP_DIR/apply-patches_patch-failed'."
  assert_line_log 1 "INFO" "Patching file '$TEST_TEMP_DIR/files/before-patch/file-fail-0'."
  assert_line_log 2 "ERROR" "Failed to patch file '$TEST_TEMP_DIR/files/before-patch/file-fail-0': patch: \*\*\*\* Only garbage was found in the patch input."
  assert_line_log 3 "INFO" "Patching file '$TEST_TEMP_DIR/files/before-patch/file-fail-1'."
  assert_line_log 4 "ERROR" "Failed to patch file '$TEST_TEMP_DIR/files/before-patch/file-fail-1': patch: \*\*\*\* Only garbage was found in the patch input."
}

@test "apply_patches | find in directory" {
  run "apply_patches" "$TEST_TEMP_DIR/find-in-directory"
  assert_success

  assert_line_log 0 "INFO" "Searching for files named '$FILES_TO_PATCH_NAME' in '$TEST_TEMP_DIR/find-in-directory'."
  assert_output --partial "Applying patches to files in '$TEST_TEMP_DIR/find-in-directory/files-to-patch'."
  assert_output --partial "Applying patches to files in '$TEST_TEMP_DIR/find-in-directory/deep/files-to-patch'."
}

@test "revert_patches | path not found" {
  run revert_patches "$TEST_TEMP_DIR/not-found"
  assert_status 1
  assert_line_log 0 "ERROR" "Path '$TEST_TEMP_DIR/not-found' does not exist."
}

@test "revert_patches | ignore invalid lines in file with list of files to revert | empty lines" {
  replace_all_in_file "\$TEST_TEMP_DIR" "$TEST_TEMP_DIR" "$TEST_TEMP_DIR/revert-patches_invalid-lines_empty"

  run "revert_patches" "$TEST_TEMP_DIR/revert-patches_invalid-lines_empty"
  assert_success

  assert_line_log 0 "INFO" "Reverting patches of files in '$TEST_TEMP_DIR/revert-patches_invalid-lines_empty'."
  assert_line_log 1 "INFO" "Reverting file '$TEST_TEMP_DIR/files/after-patch/file-0'."
  assert_line_log 2 "INFO" "Reverting file '$TEST_TEMP_DIR/files/after-patch/file-1'."

  assert_files_equal "$TEST_TEMP_DIR/files/after-patch/file-0" "$ORIGINAL_DIRECTORY/files/before-patch/file-0"
  assert_files_equal "$TEST_TEMP_DIR/files/after-patch/file-1" "$ORIGINAL_DIRECTORY/files/before-patch/file-1"
}

@test "revert_patches | ignore invalid lines in file with list of files to revert | comments" {
  replace_all_in_file "\$TEST_TEMP_DIR" "$TEST_TEMP_DIR" "$TEST_TEMP_DIR/revert-patches_invalid-lines_comments"

  run "revert_patches" "$TEST_TEMP_DIR/revert-patches_invalid-lines_comments"
  assert_success

  assert_line_log 0 "INFO" "Reverting patches of files in '$TEST_TEMP_DIR/revert-patches_invalid-lines_comments'."
  assert_line_log 1 "INFO" "Reverting file '$TEST_TEMP_DIR/files/after-patch/file-0'."
  assert_line_log 2 "INFO" "Reverting file '$TEST_TEMP_DIR/files/after-patch/file-1'."

  assert_files_equal "$TEST_TEMP_DIR/files/after-patch/file-0" "$ORIGINAL_DIRECTORY/files/before-patch/file-0"
  assert_files_equal "$TEST_TEMP_DIR/files/after-patch/file-1" "$ORIGINAL_DIRECTORY/files/before-patch/file-1"
}

@test "revert_patches | skip missing files | files to revert" {
  replace_all_in_file "\$TEST_TEMP_DIR" "$TEST_TEMP_DIR" "$TEST_TEMP_DIR/revert-patches_missing-files_files-to-patch"

  run "revert_patches" "$TEST_TEMP_DIR/revert-patches_missing-files_files-to-patch"
  assert_success

  assert_line_log 0 "INFO" "Reverting patches of files in '$TEST_TEMP_DIR/revert-patches_missing-files_files-to-patch'."
  assert_line_log 1 "INFO" "Reverting file '$TEST_TEMP_DIR/files/after-patch/file-0'."
  assert_line_log 2 "WARNING" "File to revert '$TEST_TEMP_DIR/non-existing-file-0' not found."
  assert_line_log 3 "WARNING" "File to revert '$TEST_TEMP_DIR/non-existing-file-1' not found."
  assert_line_log 4 "INFO" "Reverting file '$TEST_TEMP_DIR/files/after-patch/file-1'."

  assert_files_equal "$TEST_TEMP_DIR/files/after-patch/file-0" "$ORIGINAL_DIRECTORY/files/before-patch/file-0"
  assert_files_equal "$TEST_TEMP_DIR/files/after-patch/file-1" "$ORIGINAL_DIRECTORY/files/before-patch/file-1"
}

@test "revert_patches | skip missing files | patch files" {
  replace_all_in_file "\$TEST_TEMP_DIR" "$TEST_TEMP_DIR" "$TEST_TEMP_DIR/revert-patches_missing-files_patch-files"

  run "revert_patches" "$TEST_TEMP_DIR/revert-patches_missing-files_patch-files"
  assert_success

  assert_line_log 0 "INFO" "Reverting patches of files in '$TEST_TEMP_DIR/revert-patches_missing-files_patch-files'."
  assert_line_log 1 "ERROR" "Patch file '$TEST_TEMP_DIR/$PATCH_DIRECTORY_NAME/file-2.patch' for file to revert '$TEST_TEMP_DIR/files/after-patch/file-2' not found."
  assert_line_log 2 "INFO" "Reverting file '$TEST_TEMP_DIR/files/after-patch/file-0'."
  assert_line_log 3 "INFO" "Reverting file '$TEST_TEMP_DIR/files/after-patch/file-1'."
  assert_line_log 4 "ERROR" "Patch file '$TEST_TEMP_DIR/$PATCH_DIRECTORY_NAME/file-3.patch' for file to revert '$TEST_TEMP_DIR/files/after-patch/file-3' not found."

  assert_files_equal "$TEST_TEMP_DIR/files/after-patch/file-0" "$ORIGINAL_DIRECTORY/files/before-patch/file-0"
  assert_files_equal "$TEST_TEMP_DIR/files/after-patch/file-1" "$ORIGINAL_DIRECTORY/files/before-patch/file-1"
}

@test "revert_patches | failed to patch file" {
  replace_all_in_file "\$TEST_TEMP_DIR" "$TEST_TEMP_DIR" "$TEST_TEMP_DIR/revert-patches_patch-failed"

  run "revert_patches" "$TEST_TEMP_DIR/revert-patches_patch-failed"
  assert_success

  assert_line_log 0 "INFO" "Reverting patches of files in '$TEST_TEMP_DIR/revert-patches_patch-failed'."
  assert_line_log 1 "INFO" "Reverting file '$TEST_TEMP_DIR/files/after-patch/file-fail-0'."
  assert_line_log 2 "ERROR" "Failed to revert file '$TEST_TEMP_DIR/files/after-patch/file-fail-0': patch: \*\*\*\* Only garbage was found in the patch input."
  assert_line_log 3 "INFO" "Reverting file '$TEST_TEMP_DIR/files/after-patch/file-fail-1'."
  assert_line_log 4 "ERROR" "Failed to revert file '$TEST_TEMP_DIR/files/after-patch/file-fail-1': patch: \*\*\*\* Only garbage was found in the patch input."
}

@test "revert_patches | find in directory" {
  run "revert_patches" "$TEST_TEMP_DIR/find-in-directory"
  assert_success

  assert_line_log 0 "INFO" "Searching for files named '$FILES_TO_PATCH_NAME' in '$TEST_TEMP_DIR/find-in-directory'."
  assert_output --partial "Reverting patches of files in '$TEST_TEMP_DIR/find-in-directory/files-to-patch'."
  assert_output --partial "Reverting patches of files in '$TEST_TEMP_DIR/find-in-directory/deep/files-to-patch'."
}
