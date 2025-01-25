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
    assert_output "File with list of files to patch not provided."
}

@test "applyPatches | file with list of files to patch not found" {
    run applyPatches "/non-existing-file"
    assert_output "File '/non-existing-file' with list of files to patch not found."
}

@test "applyPatches | ignore invalid lines in file with list of files to patch | empty lines" {
    directory="/tmp/patch-utils/apply-patches"
    originalDirectory="$rootDirectory/tests/resources/patch-utils/apply-patches"

    run applyPatches "$directory/invalid-lines_empty"

    assert_output "Applying patches to files in '$directory/invalid-lines_empty'.
Backing up file '$directory/files/before-patch/file-0'.
patching file $directory/files/before-patch/file-0
Backing up file '$directory/files/before-patch/file-1'.
patching file $directory/files/before-patch/file-1"

    # assert backups
    assert_equal "$(countFiles "$directory/backups")" 2
    [ -f "$directory/backups/file-0" ]
    [ -f "$directory/backups/file-1" ]
    diff -q "$directory/backups/file-0" "$originalDirectory/files/before-patch/file-0"
    diff -q "$directory/backups/file-1" "$originalDirectory/files/before-patch/file-1"

    # assert patches
    diff -q "$directory/files/before-patch/file-0" "$originalDirectory/files/after-patch/file-0"
    diff -q "$directory/files/before-patch/file-1" "$originalDirectory/files/after-patch/file-1"
}

@test "applyPatches | ignore invalid lines in file with list of files to patch | comments" {
    directory="/tmp/patch-utils/apply-patches"
    originalDirectory="$rootDirectory/tests/resources/patch-utils/apply-patches"

    run applyPatches "$directory/invalid-lines_comments"

    assert_output "Applying patches to files in '$directory/invalid-lines_comments'.
Backing up file '$directory/files/before-patch/file-0'.
patching file $directory/files/before-patch/file-0
Backing up file '$directory/files/before-patch/file-1'.
patching file $directory/files/before-patch/file-1"

    # assert backups
    assert_equal "$(countFiles "$directory/backups")" 2
    [ -f "$directory/backups/file-0" ]
    [ -f "$directory/backups/file-1" ]
    diff -q "$directory/backups/file-0" "$originalDirectory/files/before-patch/file-0"
    diff -q "$directory/backups/file-1" "$originalDirectory/files/before-patch/file-1"

    # assert patches
    diff -q "$directory/files/before-patch/file-0" "$originalDirectory/files/after-patch/file-0"
    diff -q "$directory/files/before-patch/file-1" "$originalDirectory/files/after-patch/file-1"
}

@test "applyPatches | skip missing files | files to patch" {
    directory="/tmp/patch-utils/apply-patches"
    originalDirectory="$rootDirectory/tests/resources/patch-utils/apply-patches"

    run applyPatches "$directory/missing-files_files-to-patch"

    assert_output "Applying patches to files in '$directory/missing-files_files-to-patch'.
Backing up file '$directory/files/before-patch/file-0'.
patching file $directory/files/before-patch/file-0
File to patch '/non-existing-file-0' not found.
File to patch '/non-existing-file-1' not found.
Backing up file '$directory/files/before-patch/file-1'.
patching file $directory/files/before-patch/file-1"

    # assert backups
    assert_equal "$(countFiles "$directory/backups")" 2
    [ -f "$directory/backups/file-0" ]
    [ -f "$directory/backups/file-1" ]
    diff -q "$directory/backups/file-0" "$originalDirectory/files/before-patch/file-0"
    diff -q "$directory/backups/file-1" "$originalDirectory/files/before-patch/file-1"

    # assert patches
    diff -q "$directory/files/before-patch/file-0" "$originalDirectory/files/after-patch/file-0"
    diff -q "$directory/files/before-patch/file-1" "$originalDirectory/files/after-patch/file-1"
}

@test "applyPatches | skip missing files | patch files" {
    directory="/tmp/patch-utils/apply-patches"
    originalDirectory="$rootDirectory/tests/resources/patch-utils/apply-patches"

    run applyPatches "$directory/missing-files_patch-files"

    assert_output "Applying patches to files in '$directory/missing-files_patch-files'.
Patch file '$directory/patches/file-2.patch' for file to patch '$directory/files/before-patch/file-2' not found.
Backing up file '$directory/files/before-patch/file-0'.
patching file $directory/files/before-patch/file-0
Backing up file '$directory/files/before-patch/file-1'.
patching file $directory/files/before-patch/file-1
Patch file '$directory/patches/file-3.patch' for file to patch '$directory/files/before-patch/file-3' not found."

    # assert backups
    assert_equal "$(countFiles "$directory/backups")" 2
    [ -f "$directory/backups/file-0" ]
    [ -f "$directory/backups/file-1" ]
    diff -q "$directory/backups/file-0" "$originalDirectory/files/before-patch/file-0"
    diff -q "$directory/backups/file-1" "$originalDirectory/files/before-patch/file-1"

    # assert patches
    diff -q "$directory/files/before-patch/file-0" "$originalDirectory/files/after-patch/file-0"
    diff -q "$directory/files/before-patch/file-1" "$originalDirectory/files/after-patch/file-1"
}

@test "revertPatches | file with list of files to revert not provided" {
    run revertPatches
    assert_output "File with list of files to revert not provided."
}

@test "revertPatches | file with list of files to revert not found" {
    run revertPatches "/non-existing-file"
    assert_output "File '/non-existing-file' with list of files to revert not found."
}

@test "revertPatches | ignore invalid lines in file with list of files to revert | empty lines" {
    directory="/tmp/patch-utils/revert-patches"
    originalDirectory="$rootDirectory/tests/resources/patch-utils/revert-patches"

    run revertPatches "$directory/invalid-lines_empty"

    assert_output "Reverting patches of files in '$directory/invalid-lines_empty'.
Reverting file '$directory/files/after-patch/file-0'.
Reverting file '$directory/files/after-patch/file-1'."

    # assert reversion
    diff -q "$directory/files/after-patch/file-0" "$originalDirectory/backups/file-0"
    diff -q "$directory/files/after-patch/file-1" "$originalDirectory/backups/file-1"
}

@test "revertPatches | ignore invalid lines in file with list of files to revert | comments" {
    directory="/tmp/patch-utils/revert-patches"
    originalDirectory="$rootDirectory/tests/resources/patch-utils/revert-patches"

    run revertPatches "$directory/invalid-lines_comments"

    assert_output "Reverting patches of files in '$directory/invalid-lines_comments'.
Reverting file '$directory/files/after-patch/file-0'.
Reverting file '$directory/files/after-patch/file-1'."

    # assert reversion
    diff -q "$directory/files/after-patch/file-0" "$originalDirectory/backups/file-0"
    diff -q "$directory/files/after-patch/file-1" "$originalDirectory/backups/file-1"
}

@test "revertPatches | skip missing files | files to revert" {
    directory="/tmp/patch-utils/revert-patches"
    originalDirectory="$rootDirectory/tests/resources/patch-utils/revert-patches"

    run revertPatches "$directory/missing-files_files-to-revert"

    assert_output "Reverting patches of files in '$directory/missing-files_files-to-revert'.
Reverting file '$directory/files/after-patch/file-0'.
File to revert '/non-existing-file-0' not found.
File to revert '/non-existing-file-1' not found.
Reverting file '$directory/files/after-patch/file-1'."

    # assert reversion
    diff -q "$directory/files/after-patch/file-0" "$originalDirectory/backups/file-0"
    diff -q "$directory/files/after-patch/file-1" "$originalDirectory/backups/file-1"
}

@test "revertPatches | skip missing files | backup files" {
    directory="/tmp/patch-utils/revert-patches"
    originalDirectory="$rootDirectory/tests/resources/patch-utils/revert-patches"

    run revertPatches "$directory/missing-files_backup-files"

    assert_output "Reverting patches of files in '$directory/missing-files_backup-files'.
Backup file '$directory/backups/file-2' not found.
Reverting file '$directory/files/after-patch/file-0'.
Reverting file '$directory/files/after-patch/file-1'.
Backup file '$directory/backups/file-3' not found."

    # assert reversion
    diff -q "$directory/files/after-patch/file-0" "$originalDirectory/backups/file-0"
    diff -q "$directory/files/after-patch/file-1" "$originalDirectory/backups/file-1"
}
