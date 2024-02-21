#!/bin/bash
rootDirectory=$(git rev-parse --show-toplevel)

load "$rootDirectory/test-helper/bats/bats-support/load.bash"
load "$rootDirectory/test-helper/bats/bats-assert/load.bash"

loadScriptUnderTest() {
    load "$(__scriptUnderTest "${BASH_SOURCE[1]}")"
}

__scriptUnderTest() {
    callingTestScript=$1
    scriptUnderTestFromRoot=${callingTestScript#"$rootDirectory/test/"}
    echo "$rootDirectory/$scriptUnderTestFromRoot"
}
