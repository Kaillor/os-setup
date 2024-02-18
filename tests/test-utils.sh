#!/bin/bash
rootDirectory=$(git rev-parse --show-toplevel)

load "$rootDirectory/tests/bats/support/load.bash"
load "$rootDirectory/tests/bats/assert/load.bash"

countFiles() {
    echo "$(find "$1" -maxdepth 1 -type f | wc -l)"
}