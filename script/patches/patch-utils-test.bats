#!/bin/bash
load "../../tests/test-utils.sh"

setup() {
  load "./patch-utils.sh"
  cp -r "$ROOT_DIRECTORY/tests/resources/patches/patch-utils" "/tmp"
}

teardown() {
  rm -r "/tmp/patch-utils"
}

@test "apply_patches | path not found" {
  run apply_patches "/not-found"
  assert_status 1
  assert_line_log 0 "ERROR" "Path '/not-found' does not exist."
}

@test "apply_patches | ignore invalid lines in file with list of files to patch | empty lines" {
  local directory="/tmp/patch-utils/apply-patches"
  local original_directory="$ROOT_DIRECTORY/tests/resources/patches/patch-utils/apply-patches"

  run apply_patches "$directory/invalid-lines_empty"
  assert_success

  assert_line_log 0 "INFO" "Applying patches to files in '$directory/invalid-lines_empty'."
  assert_line_log 1 "INFO" "Backing up file '$directory/files/before-patch/file-0'."
  assert_line --index 2 "patching file $directory/files/before-patch/file-0"
  assert_line_log 3 "INFO" "Backing up file '$directory/files/before-patch/file-1'."
  assert_line --index 4 "patching file $directory/files/before-patch/file-1"

  assert_equal "$(count_files "$directory/$BACKUP_DIRECTORY_NAME")" 2
  assert_exist "$directory/$BACKUP_DIRECTORY_NAME/file-0"
  assert_exist "$directory/$BACKUP_DIRECTORY_NAME/file-1"
  assert_files_equal "$directory/$BACKUP_DIRECTORY_NAME/file-0" "$original_directory/files/before-patch/file-0"
  assert_files_equal "$directory/$BACKUP_DIRECTORY_NAME/file-1" "$original_directory/files/before-patch/file-1"

  assert_files_equal "$directory/files/before-patch/file-0" "$original_directory/files/after-patch/file-0"
  assert_files_equal "$directory/files/before-patch/file-1" "$original_directory/files/after-patch/file-1"
}

@test "apply_patches | ignore invalid lines in file with list of files to patch | comments" {
  local directory="/tmp/patch-utils/apply-patches"
  local original_directory="$ROOT_DIRECTORY/tests/resources/patches/patch-utils/apply-patches"

  run apply_patches "$directory/invalid-lines_comments"
  assert_success

  assert_line_log 0 "INFO" "Applying patches to files in '$directory/invalid-lines_comments'."
  assert_line_log 1 "INFO" "Backing up file '$directory/files/before-patch/file-0'."
  assert_line --index 2 "patching file $directory/files/before-patch/file-0"
  assert_line_log 3 "INFO" "Backing up file '$directory/files/before-patch/file-1'."
  assert_line --index 4 "patching file $directory/files/before-patch/file-1"

  assert_equal "$(count_files "$directory/$BACKUP_DIRECTORY_NAME")" 2
  assert_exist "$directory/$BACKUP_DIRECTORY_NAME/file-0"
  assert_exist "$directory/$BACKUP_DIRECTORY_NAME/file-1"
  assert_files_equal "$directory/$BACKUP_DIRECTORY_NAME/file-0" "$original_directory/files/before-patch/file-0"
  assert_files_equal "$directory/$BACKUP_DIRECTORY_NAME/file-1" "$original_directory/files/before-patch/file-1"

  assert_files_equal "$directory/files/before-patch/file-0" "$original_directory/files/after-patch/file-0"
  assert_files_equal "$directory/files/before-patch/file-1" "$original_directory/files/after-patch/file-1"
}

@test "apply_patches | skip missing files | files to patch" {
  local directory="/tmp/patch-utils/apply-patches"
  local original_directory="$ROOT_DIRECTORY/tests/resources/patches/patch-utils/apply-patches"

  run apply_patches "$directory/missing-files_files-to-patch"
  assert_success

  assert_line_log 0 "INFO" "Applying patches to files in '$directory/missing-files_files-to-patch'."
  assert_line_log 1 "INFO" "Backing up file '$directory/files/before-patch/file-0'."
  assert_line --index 2 "patching file $directory/files/before-patch/file-0"
  assert_line_log 3 "WARNING" "File to patch '/non-existing-file-0' not found."
  assert_line_log 4 "WARNING" "File to patch '/non-existing-file-1' not found."
  assert_line_log 5 "INFO" "Backing up file '$directory/files/before-patch/file-1'."
  assert_line --index 6 "patching file $directory/files/before-patch/file-1"

  assert_equal "$(count_files "$directory/$BACKUP_DIRECTORY_NAME")" 2
  assert_exist "$directory/$BACKUP_DIRECTORY_NAME/file-0"
  assert_exist "$directory/$BACKUP_DIRECTORY_NAME/file-1"
  assert_files_equal "$directory/$BACKUP_DIRECTORY_NAME/file-0" "$original_directory/files/before-patch/file-0"
  assert_files_equal "$directory/$BACKUP_DIRECTORY_NAME/file-1" "$original_directory/files/before-patch/file-1"

  assert_files_equal "$directory/files/before-patch/file-0" "$original_directory/files/after-patch/file-0"
  assert_files_equal "$directory/files/before-patch/file-1" "$original_directory/files/after-patch/file-1"
}

@test "apply_patches | skip missing files | patch files" {
  local directory="/tmp/patch-utils/apply-patches"
  local original_directory="$ROOT_DIRECTORY/tests/resources/patches/patch-utils/apply-patches"

  run apply_patches "$directory/missing-files_patch-files"
  assert_success

  assert_line_log 0 "INFO" "Applying patches to files in '$directory/missing-files_patch-files'."
  assert_line_log 1 "ERROR" "Patch file '$directory/patches/file-2.patch' for file to patch '$directory/files/before-patch/file-2' not found."
  assert_line_log 2 "INFO" "Backing up file '$directory/files/before-patch/file-0'."
  assert_line --index 3 "patching file $directory/files/before-patch/file-0"
  assert_line_log 4 "INFO" "Backing up file '$directory/files/before-patch/file-1'."
  assert_line --index 5 "patching file $directory/files/before-patch/file-1"
  assert_line_log 6 "ERROR" "Patch file '$directory/patches/file-3.patch' for file to patch '$directory/files/before-patch/file-3' not found."

  assert_equal "$(count_files "$directory/$BACKUP_DIRECTORY_NAME")" 2
  assert_exist "$directory/$BACKUP_DIRECTORY_NAME/file-0"
  assert_exist "$directory/$BACKUP_DIRECTORY_NAME/file-1"
  assert_files_equal "$directory/$BACKUP_DIRECTORY_NAME/file-0" "$original_directory/files/before-patch/file-0"
  assert_files_equal "$directory/$BACKUP_DIRECTORY_NAME/file-1" "$original_directory/files/before-patch/file-1"

  assert_files_equal "$directory/files/before-patch/file-0" "$original_directory/files/after-patch/file-0"
  assert_files_equal "$directory/files/before-patch/file-1" "$original_directory/files/after-patch/file-1"
}

@test "apply_patches | find in directory" {
  local directory="/tmp/patch-utils/apply-patches"

  run apply_patches "$directory/find-files-to-patch"
  assert_success

  assert_line_log 0 "INFO" "Searching for files named '$FILES_TO_PATCH_NAME' in '$directory/find-files-to-patch'."
  assert_line_log 1 "INFO" "Applying patches to files in '$directory/find-files-to-patch/deep/files-to-patch'."
  assert_line_log 2 "INFO" "Applying patches to files in '$directory/find-files-to-patch/files-to-patch'."
}

@test "revert_patches | path not found" {
  run revert_patches "/not-found"
  assert_status 1
  assert_line_log 0 "ERROR" "Path '/not-found' does not exist."
}

@test "revert_patches | ignore invalid lines in file with list of files to revert | empty lines" {
  local directory="/tmp/patch-utils/revert-patches"
  local original_directory="$ROOT_DIRECTORY/tests/resources/patches/patch-utils/revert-patches"

  run revert_patches "$directory/invalid-lines_empty"
  assert_success

  assert_line_log 0 "INFO" "Reverting patches of files in '$directory/invalid-lines_empty'."
  assert_line_log 1 "INFO" "Reverting file '$directory/files/after-patch/file-0'."
  assert_line_log 2 "INFO" "Reverting file '$directory/files/after-patch/file-1'."

  assert_files_equal "$directory/files/after-patch/file-0" "$original_directory/$BACKUP_DIRECTORY_NAME/file-0"
  assert_files_equal "$directory/files/after-patch/file-1" "$original_directory/$BACKUP_DIRECTORY_NAME/file-1"
}

@test "revert_patches | ignore invalid lines in file with list of files to revert | comments" {
  local directory="/tmp/patch-utils/revert-patches"
  local original_directory="$ROOT_DIRECTORY/tests/resources/patches/patch-utils/revert-patches"

  run revert_patches "$directory/invalid-lines_comments"
  assert_success

  assert_line_log 0 "INFO" "Reverting patches of files in '$directory/invalid-lines_comments'."
  assert_line_log 1 "INFO" "Reverting file '$directory/files/after-patch/file-0'."
  assert_line_log 2 "INFO" "Reverting file '$directory/files/after-patch/file-1'."

  assert_files_equal "$directory/files/after-patch/file-0" "$original_directory/$BACKUP_DIRECTORY_NAME/file-0"
  assert_files_equal "$directory/files/after-patch/file-1" "$original_directory/$BACKUP_DIRECTORY_NAME/file-1"
}

@test "revert_patches | skip missing files | files to revert" {
  local directory="/tmp/patch-utils/revert-patches"
  local original_directory="$ROOT_DIRECTORY/tests/resources/patches/patch-utils/revert-patches"

  run revert_patches "$directory/missing-files_files-to-revert"
  assert_success

  assert_line_log 0 "INFO" "Reverting patches of files in '$directory/missing-files_files-to-revert'."
  assert_line_log 1 "INFO" "Reverting file '$directory/files/after-patch/file-0'."
  assert_line_log 2 "WARNING" "File to revert '/non-existing-file-0' not found."
  assert_line_log 3 "WARNING" "File to revert '/non-existing-file-1' not found."
  assert_line_log 4 "INFO" "Reverting file '$directory/files/after-patch/file-1'."

  assert_files_equal "$directory/files/after-patch/file-0" "$original_directory/$BACKUP_DIRECTORY_NAME/file-0"
  assert_files_equal "$directory/files/after-patch/file-1" "$original_directory/$BACKUP_DIRECTORY_NAME/file-1"
}

@test "revert_patches | skip missing files | backup files" {
  local directory="/tmp/patch-utils/revert-patches"
  local original_directory="$ROOT_DIRECTORY/tests/resources/patches/patch-utils/revert-patches"

  run revert_patches "$directory/missing-files_backup-files"
  assert_success

  assert_line_log 0 "INFO" "Reverting patches of files in '$directory/missing-files_backup-files'."
  assert_line_log 1 "ERROR" "Backup file '$directory/$BACKUP_DIRECTORY_NAME/file-2' for file to revert '$directory/files/after-patch/file-2' not found."
  assert_line_log 2 "INFO" "Reverting file '$directory/files/after-patch/file-0'."
  assert_line_log 3 "INFO" "Reverting file '$directory/files/after-patch/file-1'."
  assert_line_log 4 "ERROR" "Backup file '$directory/$BACKUP_DIRECTORY_NAME/file-3' for file to revert '$directory/files/after-patch/file-3' not found."

  assert_files_equal "$directory/files/after-patch/file-0" "$original_directory/$BACKUP_DIRECTORY_NAME/file-0"
  assert_files_equal "$directory/files/after-patch/file-1" "$original_directory/$BACKUP_DIRECTORY_NAME/file-1"
}

@test "revert_patches | find in directory" {
  local directory="/tmp/patch-utils/revert-patches"

  run revert_patches "$directory/find-files-to-revert"
  assert_success

  assert_line_log 0 "INFO" "Searching for files named '$FILES_TO_PATCH_NAME' in '$directory/find-files-to-revert'."
  assert_line_log 1 "INFO" "Reverting patches of files in '$directory/find-files-to-revert/deep/files-to-patch'."
  assert_line_log 2 "INFO" "Reverting patches of files in '$directory/find-files-to-revert/files-to-patch'."
}
