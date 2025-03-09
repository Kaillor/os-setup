#!/bin/bash
load "../../../test/test-util.sh"
load "../../../script/script-util.sh"

setup() {
  load "./setup.sh"
}

@test "mint" {
  local system
  mint "system"
}
