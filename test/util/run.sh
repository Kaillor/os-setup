#!/bin/bash
run_script_with_mocked_commands() {
  local script
  local -a script_arguments
  local -a commands_to_mock

  while getopts ":a:m:s:" "opt"; do
    case "$opt" in
      a) script_arguments+=("$OPTARG") ;;
      m) commands_to_mock+=("$OPTARG") ;;
      s) script="$OPTARG" ;;
      *)
        printf "Invalid option '-%s' for command '%s'" "$OPTARG" "run_script_with_mocked_commands" >&2
        exit 2
        ;;
    esac
  done

  local run_command=""
  for command in "${commands_to_mock[@]}"; do
    run_command+="$(mock_command_code "$command")
"
  done
  run_command+="eval \"\$(cat \"$script\")\""
  run bash -c "$run_command" "$script" "${script_arguments[@]}"

  return 0
}
