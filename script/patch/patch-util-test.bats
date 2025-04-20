#!/bin/bash
load "../../test/test-util.sh"

ORIGINAL_DIRECTORY="$TEST_RESOURCES_DIRECTORY/patch/patch-util"
ORIGINAL_DIRECTORY_APPLY_PATCHES="$ORIGINAL_DIRECTORY/apply-patches"
ORIGINAL_DIRECTORY_REVERT_PATCHES="$ORIGINAL_DIRECTORY/revert-patches"

setup() {
  load "./../script-util.sh"
  TEST_TEMP_DIR="$(temp_make)"
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
  cp -r "$ORIGINAL_DIRECTORY_APPLY_PATCHES/." "$TEST_TEMP_DIR"
  replace_all_in_file "\$TEST_TEMP_DIR" "$TEST_TEMP_DIR" "$TEST_TEMP_DIR/invalid-lines_empty"

  run "apply_patches" "$TEST_TEMP_DIR/invalid-lines_empty"
  assert_success

  assert_line_log 0 "INFO" "Applying patches to files in '$TEST_TEMP_DIR/invalid-lines_empty'."
  assert_line_log 1 "INFO" "Backing up file '$TEST_TEMP_DIR/files/before-patch/file-0'."
  assert_line_log 2 "INFO" "Patching file '$TEST_TEMP_DIR/files/before-patch/file-0'."
  assert_line_log 3 "INFO" "Backing up file '$TEST_TEMP_DIR/files/before-patch/file-1'."
  assert_line_log 4 "INFO" "Patching file '$TEST_TEMP_DIR/files/before-patch/file-1'."

  assert_file_count "$TEST_TEMP_DIR/$BACKUP_DIRECTORY_NAME" 2
  assert_exist "$TEST_TEMP_DIR/$BACKUP_DIRECTORY_NAME/file-0"
  assert_exist "$TEST_TEMP_DIR/$BACKUP_DIRECTORY_NAME/file-1"
  assert_files_equal "$TEST_TEMP_DIR/$BACKUP_DIRECTORY_NAME/file-0" "$ORIGINAL_DIRECTORY_APPLY_PATCHES/files/before-patch/file-0"
  assert_files_equal "$TEST_TEMP_DIR/$BACKUP_DIRECTORY_NAME/file-1" "$ORIGINAL_DIRECTORY_APPLY_PATCHES/files/before-patch/file-1"

  assert_files_equal "$TEST_TEMP_DIR/files/before-patch/file-0" "$ORIGINAL_DIRECTORY_APPLY_PATCHES/files/after-patch/file-0"
  assert_files_equal "$TEST_TEMP_DIR/files/before-patch/file-1" "$ORIGINAL_DIRECTORY_APPLY_PATCHES/files/after-patch/file-1"
}

@test "apply_patches | ignore invalid lines in file with list of files to patch | comments" {
  cp -r "$ORIGINAL_DIRECTORY_APPLY_PATCHES/." "$TEST_TEMP_DIR"
  replace_all_in_file "\$TEST_TEMP_DIR" "$TEST_TEMP_DIR" "$TEST_TEMP_DIR/invalid-lines_comments"

  run "apply_patches" "$TEST_TEMP_DIR/invalid-lines_comments"
  assert_success

  assert_line_log 0 "INFO" "Applying patches to files in '$TEST_TEMP_DIR/invalid-lines_comments'."
  assert_line_log 1 "INFO" "Backing up file '$TEST_TEMP_DIR/files/before-patch/file-0'."
  assert_line_log 2 "INFO" "Patching file '$TEST_TEMP_DIR/files/before-patch/file-0'."
  assert_line_log 3 "INFO" "Backing up file '$TEST_TEMP_DIR/files/before-patch/file-1'."
  assert_line_log 4 "INFO" "Patching file '$TEST_TEMP_DIR/files/before-patch/file-1'."

  assert_file_count "$TEST_TEMP_DIR/$BACKUP_DIRECTORY_NAME" 2
  assert_exist "$TEST_TEMP_DIR/$BACKUP_DIRECTORY_NAME/file-0"
  assert_exist "$TEST_TEMP_DIR/$BACKUP_DIRECTORY_NAME/file-1"
  assert_files_equal "$TEST_TEMP_DIR/$BACKUP_DIRECTORY_NAME/file-0" "$ORIGINAL_DIRECTORY_APPLY_PATCHES/files/before-patch/file-0"
  assert_files_equal "$TEST_TEMP_DIR/$BACKUP_DIRECTORY_NAME/file-1" "$ORIGINAL_DIRECTORY_APPLY_PATCHES/files/before-patch/file-1"

  assert_files_equal "$TEST_TEMP_DIR/files/before-patch/file-0" "$ORIGINAL_DIRECTORY_APPLY_PATCHES/files/after-patch/file-0"
  assert_files_equal "$TEST_TEMP_DIR/files/before-patch/file-1" "$ORIGINAL_DIRECTORY_APPLY_PATCHES/files/after-patch/file-1"
}

@test "apply_patches | skip missing files | files to patch" {
  cp -r "$ORIGINAL_DIRECTORY_APPLY_PATCHES/." "$TEST_TEMP_DIR"
  replace_all_in_file "\$TEST_TEMP_DIR" "$TEST_TEMP_DIR" "$TEST_TEMP_DIR/missing-files_files-to-patch"

  run "apply_patches" "$TEST_TEMP_DIR/missing-files_files-to-patch"
  assert_success

  assert_line_log 0 "INFO" "Applying patches to files in '$TEST_TEMP_DIR/missing-files_files-to-patch'."
  assert_line_log 1 "INFO" "Backing up file '$TEST_TEMP_DIR/files/before-patch/file-0'."
  assert_line_log 2 "INFO" "Patching file '$TEST_TEMP_DIR/files/before-patch/file-0'."
  assert_line_log 3 "WARNING" "File to patch '$TEST_TEMP_DIR/non-existing-file-0' not found."
  assert_line_log 4 "WARNING" "File to patch '$TEST_TEMP_DIR/non-existing-file-1' not found."
  assert_line_log 5 "INFO" "Backing up file '$TEST_TEMP_DIR/files/before-patch/file-1'."
  assert_line_log 6 "INFO" "Patching file '$TEST_TEMP_DIR/files/before-patch/file-1'."

  assert_file_count "$TEST_TEMP_DIR/$BACKUP_DIRECTORY_NAME" 2
  assert_exist "$TEST_TEMP_DIR/$BACKUP_DIRECTORY_NAME/file-0"
  assert_exist "$TEST_TEMP_DIR/$BACKUP_DIRECTORY_NAME/file-1"
  assert_files_equal "$TEST_TEMP_DIR/$BACKUP_DIRECTORY_NAME/file-0" "$ORIGINAL_DIRECTORY_APPLY_PATCHES/files/before-patch/file-0"
  assert_files_equal "$TEST_TEMP_DIR/$BACKUP_DIRECTORY_NAME/file-1" "$ORIGINAL_DIRECTORY_APPLY_PATCHES/files/before-patch/file-1"

  assert_files_equal "$TEST_TEMP_DIR/files/before-patch/file-0" "$ORIGINAL_DIRECTORY_APPLY_PATCHES/files/after-patch/file-0"
  assert_files_equal "$TEST_TEMP_DIR/files/before-patch/file-1" "$ORIGINAL_DIRECTORY_APPLY_PATCHES/files/after-patch/file-1"
}

@test "apply_patches | skip missing files | patch files" {
  cp -r "$ORIGINAL_DIRECTORY_APPLY_PATCHES/." "$TEST_TEMP_DIR"
  replace_all_in_file "\$TEST_TEMP_DIR" "$TEST_TEMP_DIR" "$TEST_TEMP_DIR/missing-files_patch-files"

  run "apply_patches" "$TEST_TEMP_DIR/missing-files_patch-files"
  assert_success

  assert_line_log 0 "INFO" "Applying patches to files in '$TEST_TEMP_DIR/missing-files_patch-files'."
  assert_line_log 1 "ERROR" "Patch file '$TEST_TEMP_DIR/patches/file-2.patch' for file to patch '$TEST_TEMP_DIR/files/before-patch/file-2' not found."
  assert_line_log 2 "INFO" "Backing up file '$TEST_TEMP_DIR/files/before-patch/file-0'."
  assert_line_log 3 "INFO" "Patching file '$TEST_TEMP_DIR/files/before-patch/file-0'."
  assert_line_log 4 "INFO" "Backing up file '$TEST_TEMP_DIR/files/before-patch/file-1'."
  assert_line_log 5 "INFO" "Patching file '$TEST_TEMP_DIR/files/before-patch/file-1'."
  assert_line_log 6 "ERROR" "Patch file '$TEST_TEMP_DIR/patches/file-3.patch' for file to patch '$TEST_TEMP_DIR/files/before-patch/file-3' not found."

  assert_file_count "$TEST_TEMP_DIR/$BACKUP_DIRECTORY_NAME" 2
  assert_exist "$TEST_TEMP_DIR/$BACKUP_DIRECTORY_NAME/file-0"
  assert_exist "$TEST_TEMP_DIR/$BACKUP_DIRECTORY_NAME/file-1"
  assert_files_equal "$TEST_TEMP_DIR/$BACKUP_DIRECTORY_NAME/file-0" "$ORIGINAL_DIRECTORY_APPLY_PATCHES/files/before-patch/file-0"
  assert_files_equal "$TEST_TEMP_DIR/$BACKUP_DIRECTORY_NAME/file-1" "$ORIGINAL_DIRECTORY_APPLY_PATCHES/files/before-patch/file-1"

  assert_files_equal "$TEST_TEMP_DIR/files/before-patch/file-0" "$ORIGINAL_DIRECTORY_APPLY_PATCHES/files/after-patch/file-0"
  assert_files_equal "$TEST_TEMP_DIR/files/before-patch/file-1" "$ORIGINAL_DIRECTORY_APPLY_PATCHES/files/after-patch/file-1"
}

@test "apply_patches | find in directory" {
  cp -r "$ORIGINAL_DIRECTORY_APPLY_PATCHES/find-files-to-patch/." "$TEST_TEMP_DIR"

  run "apply_patches" "$TEST_TEMP_DIR"
  assert_success

  assert_line_log 0 "INFO" "Searching for files named '$FILES_TO_PATCH_NAME' in '$TEST_TEMP_DIR'."
  assert_output --partial "Applying patches to files in '$TEST_TEMP_DIR/files-to-patch'."
  assert_output --partial "Applying patches to files in '$TEST_TEMP_DIR/deep/files-to-patch'."
}

@test "revert_patches | path not found" {
  run revert_patches "$TEST_TEMP_DIR/not-found"
  assert_status 1
  assert_line_log 0 "ERROR" "Path '$TEST_TEMP_DIR/not-found' does not exist."
}

@test "revert_patches | ignore invalid lines in file with list of files to revert | empty lines" {
  cp -r "$ORIGINAL_DIRECTORY_REVERT_PATCHES/." "$TEST_TEMP_DIR"
  replace_all_in_file "\$TEST_TEMP_DIR" "$TEST_TEMP_DIR" "$TEST_TEMP_DIR/invalid-lines_empty"

  run "revert_patches" "$TEST_TEMP_DIR/invalid-lines_empty"
  assert_success

  assert_line_log 0 "INFO" "Reverting patches of files in '$TEST_TEMP_DIR/invalid-lines_empty'."
  assert_line_log 1 "INFO" "Reverting file '$TEST_TEMP_DIR/files/after-patch/file-0'."
  assert_line_log 2 "INFO" "Reverting file '$TEST_TEMP_DIR/files/after-patch/file-1'."

  assert_files_equal "$TEST_TEMP_DIR/files/after-patch/file-0" "$ORIGINAL_DIRECTORY_REVERT_PATCHES/$BACKUP_DIRECTORY_NAME/file-0"
  assert_files_equal "$TEST_TEMP_DIR/files/after-patch/file-1" "$ORIGINAL_DIRECTORY_REVERT_PATCHES/$BACKUP_DIRECTORY_NAME/file-1"
}

@test "revert_patches | ignore invalid lines in file with list of files to revert | comments" {
  cp -r "$ORIGINAL_DIRECTORY_REVERT_PATCHES/." "$TEST_TEMP_DIR"
  replace_all_in_file "\$TEST_TEMP_DIR" "$TEST_TEMP_DIR" "$TEST_TEMP_DIR/invalid-lines_comments"

  run "revert_patches" "$TEST_TEMP_DIR/invalid-lines_comments"
  assert_success

  assert_line_log 0 "INFO" "Reverting patches of files in '$TEST_TEMP_DIR/invalid-lines_comments'."
  assert_line_log 1 "INFO" "Reverting file '$TEST_TEMP_DIR/files/after-patch/file-0'."
  assert_line_log 2 "INFO" "Reverting file '$TEST_TEMP_DIR/files/after-patch/file-1'."

  assert_files_equal "$TEST_TEMP_DIR/files/after-patch/file-0" "$ORIGINAL_DIRECTORY_REVERT_PATCHES/$BACKUP_DIRECTORY_NAME/file-0"
  assert_files_equal "$TEST_TEMP_DIR/files/after-patch/file-1" "$ORIGINAL_DIRECTORY_REVERT_PATCHES/$BACKUP_DIRECTORY_NAME/file-1"
}

@test "revert_patches | skip missing files | files to revert" {
  cp -r "$ORIGINAL_DIRECTORY_REVERT_PATCHES/." "$TEST_TEMP_DIR"
  replace_all_in_file "\$TEST_TEMP_DIR" "$TEST_TEMP_DIR" "$TEST_TEMP_DIR/missing-files_files-to-revert"

  run "revert_patches" "$TEST_TEMP_DIR/missing-files_files-to-revert"
  assert_success

  assert_line_log 0 "INFO" "Reverting patches of files in '$TEST_TEMP_DIR/missing-files_files-to-revert'."
  assert_line_log 1 "INFO" "Reverting file '$TEST_TEMP_DIR/files/after-patch/file-0'."
  assert_line_log 2 "WARNING" "File to revert '$TEST_TEMP_DIR/non-existing-file-0' not found."
  assert_line_log 3 "WARNING" "File to revert '$TEST_TEMP_DIR/non-existing-file-1' not found."
  assert_line_log 4 "INFO" "Reverting file '$TEST_TEMP_DIR/files/after-patch/file-1'."

  assert_files_equal "$TEST_TEMP_DIR/files/after-patch/file-0" "$ORIGINAL_DIRECTORY_REVERT_PATCHES/$BACKUP_DIRECTORY_NAME/file-0"
  assert_files_equal "$TEST_TEMP_DIR/files/after-patch/file-1" "$ORIGINAL_DIRECTORY_REVERT_PATCHES/$BACKUP_DIRECTORY_NAME/file-1"
}

@test "revert_patches | skip missing files | backup files" {
  cp -r "$ORIGINAL_DIRECTORY_REVERT_PATCHES/." "$TEST_TEMP_DIR"
  replace_all_in_file "\$TEST_TEMP_DIR" "$TEST_TEMP_DIR" "$TEST_TEMP_DIR/missing-files_backup-files"

  run "revert_patches" "$TEST_TEMP_DIR/missing-files_backup-files"
  assert_success

  assert_line_log 0 "INFO" "Reverting patches of files in '$TEST_TEMP_DIR/missing-files_backup-files'."
  assert_line_log 1 "ERROR" "Backup file '$TEST_TEMP_DIR/$BACKUP_DIRECTORY_NAME/file-2' for file to revert '$TEST_TEMP_DIR/files/after-patch/file-2' not found."
  assert_line_log 2 "INFO" "Reverting file '$TEST_TEMP_DIR/files/after-patch/file-0'."
  assert_line_log 3 "INFO" "Reverting file '$TEST_TEMP_DIR/files/after-patch/file-1'."
  assert_line_log 4 "ERROR" "Backup file '$TEST_TEMP_DIR/$BACKUP_DIRECTORY_NAME/file-3' for file to revert '$TEST_TEMP_DIR/files/after-patch/file-3' not found."

  assert_files_equal "$TEST_TEMP_DIR/files/after-patch/file-0" "$ORIGINAL_DIRECTORY_REVERT_PATCHES/$BACKUP_DIRECTORY_NAME/file-0"
  assert_files_equal "$TEST_TEMP_DIR/files/after-patch/file-1" "$ORIGINAL_DIRECTORY_REVERT_PATCHES/$BACKUP_DIRECTORY_NAME/file-1"
}

@test "revert_patches | find in directory" {
  cp -r "$ORIGINAL_DIRECTORY_REVERT_PATCHES/find-files-to-revert/." "$TEST_TEMP_DIR"

  run "revert_patches" "$TEST_TEMP_DIR"
  assert_success

  assert_line_log 0 "INFO" "Searching for files named '$FILES_TO_PATCH_NAME' in '$TEST_TEMP_DIR'."
  assert_output --partial "Reverting patches of files in '$TEST_TEMP_DIR/files-to-patch'."
  assert_output --partial "Reverting patches of files in '$TEST_TEMP_DIR/deep/files-to-patch'."
}
