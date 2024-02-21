#!/bin/bash
rootDirectory=$(realpath "$(dirname "${BASH_SOURCE[0]}")/..")

load "$rootDirectory/test-helper/bats/bats-support/load.bash"
load "$rootDirectory/test-helper/bats/bats-assert/load.bash"
