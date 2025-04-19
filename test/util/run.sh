#!/bin/bash
run_script_with_mocked_commands() {
  local script
  local -a script_arguments
  local -a commands_to_mock
  local -a custom_code
  local user_input

  while getopts ":a:c:i:m:s:" "opt"; do
    case "$opt" in
      a) script_arguments+=("$OPTARG") ;;
      c) custom_code+=("$OPTARG") ;;
      i) user_input="$OPTARG" ;;
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
  for code in "${custom_code[@]}"; do
    run_command+="$code
"
  done
  run_command+="eval \"\$(cat \"$script\")\""
  run bash -c "$run_command" "$script" "${script_arguments[@]}" <<< "$user_input"

  return 0
}
