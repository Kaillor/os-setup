#!/bin/bash
rootDirectory=$(git rev-parse --show-toplevel)

load "$rootDirectory/test-helper/bats/bats-support/load.bash"
load "$rootDirectory/test-helper/bats/bats-assert/load.bash"

loadScriptUnderTest() {
    callingTestScript=$(__callingTestScript)
    load "$(__pathOfScriptUnderTest "$callingTestScript")"
}

__callingTestScript() {
    echo $(realpath "$(echo "$(caller 0)" | cut -d ' ' -f 2)")
}

__pathOfScriptUnderTest() {
    callingTestScript=$1
    scriptUnderTestFromRoot=${callingTestScript#"$rootDirectory/test/"}
    echo "$rootDirectory/$scriptUnderTestFromRoot"
}
