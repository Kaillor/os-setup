#!/bin/bash
source "$(git rev-parse --show-toplevel)/tests/test-utils.sh"

setup() {
  load "./patch-utils.sh"
  cp -r "$rootDirectory/tests/resources/patch-utils" "/tmp"
}

teardown() {
  rm -r "/tmp/patch-utils"
}

@test "applyPatches | file with list of files to patch not provided" {
  run applyPatches
  assert_status 2
  assert_line_log 0 "ERROR" "File with list of files to patch not provided."
}

@test "applyPatches | file with list of files to patch not found" {
  run applyPatches "/non-existing-file"
  assert_status 1
  assert_line_log 0 "ERROR" "File '/non-existing-file' with list of files to patch not found."
}

@test "applyPatches | ignore invalid lines in file with list of files to patch | empty lines" {
  directory="/tmp/patch-utils/apply-patches"
  originalDirectory="$rootDirectory/tests/resources/patch-utils/apply-patches"

  run applyPatches "$directory/invalid-lines_empty"
  assert_success

  assert_line_log 0 "INFO" "Applying patches to files in '$directory/invalid-lines_empty'."
  assert_line_log 1 "INFO" "Backing up file '$directory/files/before-patch/file-0'."
  assert_line --index 2 "patching file $directory/files/before-patch/file-0"
  assert_line_log 3 "INFO" "Backing up file '$directory/files/before-patch/file-1'."
  assert_line --index 4 "patching file $directory/files/before-patch/file-1"

  assert_equal "$(countFiles "$directory/backups")" 2
  assert_exist "$directory/backups/file-0"
  assert_exist "$directory/backups/file-1"
  assert_files_equal "$directory/backups/file-0" "$originalDirectory/files/before-patch/file-0"
  assert_files_equal "$directory/backups/file-1" "$originalDirectory/files/before-patch/file-1"

  assert_files_equal "$directory/files/before-patch/file-0" "$originalDirectory/files/after-patch/file-0"
  assert_files_equal "$directory/files/before-patch/file-1" "$originalDirectory/files/after-patch/file-1"
}

@test "applyPatches | ignore invalid lines in file with list of files to patch | comments" {
  directory="/tmp/patch-utils/apply-patches"
  originalDirectory="$rootDirectory/tests/resources/patch-utils/apply-patches"

  run applyPatches "$directory/invalid-lines_comments"
  assert_success

  assert_line_log 0 "INFO" "Applying patches to files in '$directory/invalid-lines_comments'."
  assert_line_log 1 "INFO" "Backing up file '$directory/files/before-patch/file-0'."
  assert_line --index 2 "patching file $directory/files/before-patch/file-0"
  assert_line_log 3 "INFO" "Backing up file '$directory/files/before-patch/file-1'."
  assert_line --index 4 "patching file $directory/files/before-patch/file-1"

  assert_equal "$(countFiles "$directory/backups")" 2
  assert_exist "$directory/backups/file-0"
  assert_exist "$directory/backups/file-1"
  assert_files_equal "$directory/backups/file-0" "$originalDirectory/files/before-patch/file-0"
  assert_files_equal "$directory/backups/file-1" "$originalDirectory/files/before-patch/file-1"

  assert_files_equal "$directory/files/before-patch/file-0" "$originalDirectory/files/after-patch/file-0"
  assert_files_equal "$directory/files/before-patch/file-1" "$originalDirectory/files/after-patch/file-1"
}

@test "applyPatches | skip missing files | files to patch" {
  directory="/tmp/patch-utils/apply-patches"
  originalDirectory="$rootDirectory/tests/resources/patch-utils/apply-patches"

  run applyPatches "$directory/missing-files_files-to-patch"
  assert_success

  assert_line_log 0 "INFO" "Applying patches to files in '$directory/missing-files_files-to-patch'."
  assert_line_log 1 "INFO" "Backing up file '$directory/files/before-patch/file-0'."
  assert_line --index 2 "patching file $directory/files/before-patch/file-0"
  assert_line_log 3 "WARNING" "File to patch '/non-existing-file-0' not found."
  assert_line_log 4 "WARNING" "File to patch '/non-existing-file-1' not found."
  assert_line_log 5 "INFO" "Backing up file '$directory/files/before-patch/file-1'."
  assert_line --index 6 "patching file $directory/files/before-patch/file-1"

  assert_equal "$(countFiles "$directory/backups")" 2
  assert_exist "$directory/backups/file-0"
  assert_exist "$directory/backups/file-1"
  assert_files_equal "$directory/backups/file-0" "$originalDirectory/files/before-patch/file-0"
  assert_files_equal "$directory/backups/file-1" "$originalDirectory/files/before-patch/file-1"

  assert_files_equal "$directory/files/before-patch/file-0" "$originalDirectory/files/after-patch/file-0"
  assert_files_equal "$directory/files/before-patch/file-1" "$originalDirectory/files/after-patch/file-1"
}

@test "applyPatches | skip missing files | patch files" {
  directory="/tmp/patch-utils/apply-patches"
  originalDirectory="$rootDirectory/tests/resources/patch-utils/apply-patches"

  run applyPatches "$directory/missing-files_patch-files"
  assert_success

  assert_line_log 0 "INFO" "Applying patches to files in '$directory/missing-files_patch-files'."
  assert_line_log 1 "ERROR" "Patch file '$directory/patches/file-2.patch' for file to patch '$directory/files/before-patch/file-2' not found."
  assert_line_log 2 "INFO" "Backing up file '$directory/files/before-patch/file-0'."
  assert_line --index 3 "patching file $directory/files/before-patch/file-0"
  assert_line_log 4 "INFO" "Backing up file '$directory/files/before-patch/file-1'."
  assert_line --index 5 "patching file $directory/files/before-patch/file-1"
  assert_line_log 6 "ERROR" "Patch file '$directory/patches/file-3.patch' for file to patch '$directory/files/before-patch/file-3' not found."

  assert_equal "$(countFiles "$directory/backups")" 2
  assert_exist "$directory/backups/file-0"
  assert_exist "$directory/backups/file-1"
  assert_files_equal "$directory/backups/file-0" "$originalDirectory/files/before-patch/file-0"
  assert_files_equal "$directory/backups/file-1" "$originalDirectory/files/before-patch/file-1"

  assert_files_equal "$directory/files/before-patch/file-0" "$originalDirectory/files/after-patch/file-0"
  assert_files_equal "$directory/files/before-patch/file-1" "$originalDirectory/files/after-patch/file-1"
}

@test "revertPatches | file with list of files to revert not provided" {
  run revertPatches
  assert_status 2
  assert_line_log 0 "ERROR" "File with list of files to revert not provided."
}

@test "revertPatches | file with list of files to revert not found" {
  run revertPatches "/non-existing-file"
  assert_status 1
  assert_line_log 0 "ERROR" "File '/non-existing-file' with list of files to revert not found."
}

@test "revertPatches | ignore invalid lines in file with list of files to revert | empty lines" {
  directory="/tmp/patch-utils/revert-patches"
  originalDirectory="$rootDirectory/tests/resources/patch-utils/revert-patches"

  run revertPatches "$directory/invalid-lines_empty"
  assert_success

  assert_line_log 0 "INFO" "Reverting patches of files in '$directory/invalid-lines_empty'."
  assert_line_log 1 "INFO" "Reverting file '$directory/files/after-patch/file-0'."
  assert_line_log 2 "INFO" "Reverting file '$directory/files/after-patch/file-1'."

  assert_files_equal "$directory/files/after-patch/file-0" "$originalDirectory/backups/file-0"
  assert_files_equal "$directory/files/after-patch/file-1" "$originalDirectory/backups/file-1"
}

@test "revertPatches | ignore invalid lines in file with list of files to revert | comments" {
  directory="/tmp/patch-utils/revert-patches"
  originalDirectory="$rootDirectory/tests/resources/patch-utils/revert-patches"

  run revertPatches "$directory/invalid-lines_comments"
  assert_success

  assert_line_log 0 "INFO" "Reverting patches of files in '$directory/invalid-lines_comments'."
  assert_line_log 1 "INFO" "Reverting file '$directory/files/after-patch/file-0'."
  assert_line_log 2 "INFO" "Reverting file '$directory/files/after-patch/file-1'."

  assert_files_equal "$directory/files/after-patch/file-0" "$originalDirectory/backups/file-0"
  assert_files_equal "$directory/files/after-patch/file-1" "$originalDirectory/backups/file-1"
}

@test "revertPatches | skip missing files | files to revert" {
  directory="/tmp/patch-utils/revert-patches"
  originalDirectory="$rootDirectory/tests/resources/patch-utils/revert-patches"

  run revertPatches "$directory/missing-files_files-to-revert"
  assert_success

  assert_line_log 0 "INFO" "Reverting patches of files in '$directory/missing-files_files-to-revert'."
  assert_line_log 1 "INFO" "Reverting file '$directory/files/after-patch/file-0'."
  assert_line_log 2 "WARNING" "File to revert '/non-existing-file-0' not found."
  assert_line_log 3 "WARNING" "File to revert '/non-existing-file-1' not found."
  assert_line_log 4 "INFO" "Reverting file '$directory/files/after-patch/file-1'."

  assert_files_equal "$directory/files/after-patch/file-0" "$originalDirectory/backups/file-0"
  assert_files_equal "$directory/files/after-patch/file-1" "$originalDirectory/backups/file-1"
}

@test "revertPatches | skip missing files | backup files" {
  directory="/tmp/patch-utils/revert-patches"
  originalDirectory="$rootDirectory/tests/resources/patch-utils/revert-patches"

  run revertPatches "$directory/missing-files_backup-files"
  assert_success

  assert_line_log 0 "INFO" "Reverting patches of files in '$directory/missing-files_backup-files'."
  assert_line_log 1 "ERROR" "Backup file '$directory/backups/file-2' for file to revert '$directory/files/after-patch/file-2' not found."
  assert_line_log 2 "INFO" "Reverting file '$directory/files/after-patch/file-0'."
  assert_line_log 3 "INFO" "Reverting file '$directory/files/after-patch/file-1'."
  assert_line_log 4 "ERROR" "Backup file '$directory/backups/file-3' for file to revert '$directory/files/after-patch/file-3' not found."

  assert_files_equal "$directory/files/after-patch/file-0" "$originalDirectory/backups/file-0"
  assert_files_equal "$directory/files/after-patch/file-1" "$originalDirectory/backups/file-1"
}
