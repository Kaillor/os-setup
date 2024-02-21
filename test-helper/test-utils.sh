#!/bin/bash
rootDirectory=$(git rev-parse --show-toplevel)

load "$rootDirectory/test-helper/bats/bats-support/load.bash"
load "$rootDirectory/test-helper/bats/bats-assert/load.bash"

loadScriptUnderTest() {
    callingScript=$(__callingScript)
}

__callingScript() {
    echo $(realpath "$(echo "$(caller 0)" | cut -d ' ' -f 2)")
}
