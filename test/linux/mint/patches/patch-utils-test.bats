#!/bin/bash
source "$(git rev-parse --show-toplevel)/test-helper/test-utils.sh"

setup() {
    load "../patches/patch-utils.sh"
}

@test "File with list of files to patch does not exist." {
    run applyPatches
    assert_output "File not found"
}
