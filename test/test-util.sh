#!/bin/bash
ROOT_DIRECTORY="$(dirname "${BASH_SOURCE[0]}")/.."
readonly ROOT_DIRECTORY

load "$ROOT_DIRECTORY/test/bats/assert/load.bash"
load "$ROOT_DIRECTORY/test/bats/file/load.bash"
load "$ROOT_DIRECTORY/test/bats/support/load.bash"

load "$ROOT_DIRECTORY/test/util/assert-file.sh"
load "$ROOT_DIRECTORY/test/util/assert.sh"
load "$ROOT_DIRECTORY/test/util/helper.sh"
load "$ROOT_DIRECTORY/test/util/run.sh"
