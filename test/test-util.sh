#!/bin/bash
ROOT_DIRECTORY="$(dirname "${BASH_SOURCE[0]}")/.."
readonly ROOT_DIRECTORY
readonly TEST_DIRECTORY="$ROOT_DIRECTORY/test"
readonly TEST_BATS_DIRECTORY="$TEST_DIRECTORY/bats"
readonly TEST_RESOURCES_DIRECTORY="$TEST_DIRECTORY/resources"
readonly TEST_UTIL_DIRECTORY="$TEST_DIRECTORY/util"

load "$TEST_BATS_DIRECTORY/assert/load.bash"
load "$TEST_BATS_DIRECTORY/file/load.bash"
load "$TEST_BATS_DIRECTORY/support/load.bash"

load "$TEST_UTIL_DIRECTORY/assert-file.sh"
load "$TEST_UTIL_DIRECTORY/assert.sh"
load "$TEST_UTIL_DIRECTORY/helper.sh"
load "$TEST_UTIL_DIRECTORY/run.sh"

export TEST_RESOURCES_DIRECTORY
