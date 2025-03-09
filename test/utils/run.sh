#!/bin/bash
run_script_with_mocked_commands() {
  local script="$1"
  local -a commands_to_mock=("${@:2}")

  local run_command=""
  for command in "${commands_to_mock[@]}"; do
    run_command+="$command() {
  printf \"MOCK: %s\" \"$command\"
  for argument in \"\$@\"; do
    printf \" \\\"%s\\\"\" \"\$argument\"
  done
  printf \"\\n\"
  return 0
}
"
  done
  run_command+="eval \"\$(cat \"$script\")\""
  run bash -c "$run_command"

  return 0
}
