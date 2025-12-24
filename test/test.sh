#!/bin/bash
run_tests() {
  local path="$1"

  sudo -v
  if [ -n "$path" ]; then \
    "$(dirname "${BASH_SOURCE[0]}")/bats/core/bin/bats" "$path";
  else
    local -a test_files
    mapfile -t test_files < <(find . -name "*.bats" -not -path "./test/bats/*" -not -path "./test/integration/*");
    "$(dirname "${BASH_SOURCE[0]}")/bats/core/bin/bats" "${test_files[@]}";
  fi
}
