#!/bin/bash

setup() {
    load "../patches/patch-utils.sh"
}

@test "File with list of files to patch does not exist." {
    run applyPatches
    assert_output "File not found"
}
