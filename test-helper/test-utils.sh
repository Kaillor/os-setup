#!/bin/bash
rootDirectory=$(git rev-parse --show-toplevel)

load "$rootDirectory/test-helper/bats/bats-support/load.bash"
load "$rootDirectory/test-helper/bats/bats-assert/load.bash"

loadScriptUnderTest() {
    callingTestScript=$(__callingTestScript)
    load "$(__scriptUnderTest "$callingTestScript")"
}

__callingTestScript() {
    echo $(realpath "$(echo "$(caller 1)" | cut -d ' ' -f 2)")
}

__scriptUnderTest() {
    callingTestScript=$1
    scriptUnderTestFromRoot=${callingTestScript#"$rootDirectory/test/"}
    echo "$rootDirectory/$scriptUnderTestFromRoot"
}
