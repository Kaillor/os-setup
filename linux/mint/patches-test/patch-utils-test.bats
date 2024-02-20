#!/bin/bash

setup() {
    patchUtilsFile=$(realpath "${BASH_SOURCE[0]}/../patches/patch-utils.sh")
    source "$patchUtilsFile"
}

@test "File with list of files to patch does not exist." {
    run applyPatches
    assert_output "File not found"
}
