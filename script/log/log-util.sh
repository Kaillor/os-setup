#!/bin/bash
readonly SUCCESS_COLOR="\e[32m"
readonly INFO_COLOR="\e[34m"
readonly WARNING_COLOR="\e[33m"
readonly ERROR_COLOR="\e[31m"
readonly RESET_COLOR="\e[0m"

info() {
  local message="$1"

  __print_log "${INFO_COLOR}INFO$RESET_COLOR" "$message"

  return 0
}

warning() {
  local message="$1"

  __print_log "${WARNING_COLOR}WARNING$RESET_COLOR" "$message" >&2

  return 0
}

error() {
  local message="$1"

  __print_log "${ERROR_COLOR}ERROR$RESET_COLOR" "$message" >&2

  return 0
}

__print_log() {
  local level="$1"
  local message="$2"

  printf "[%s] [%b] %s\n" "$(date "+%Y-%m-%d %H:%M:%S.%3N")" "$level" "$message"

  return 0
}

run_and_log() {
  local command="$1"

  local running_script
  running_script="$(basename "${BASH_SOURCE[1]}" | sed "s/\.[^.]*$//")"
  local log_file
  log_file="$(date "+%Y-%m-%d_%H:%M:%S")_$running_script.log"

  eval "$command" 2>&1 | tee >(sed 's/\x1b\[[0-9;]*m//g' > "$log_file")

  local -i warnings_occured=0
  if grep -q "\[WARNING\]" "$log_file"; then
    warnings_occured=1
  fi
  local -i errors_occured=0
  if grep -q "\[ERROR\]" "$log_file"; then
    errors_occured=1
  fi

  if [[ $warnings_occured -eq 1 ]]; then
    printf "%bWarnings occurred during the execution of the script.%b\n" "$WARNING_COLOR" "$RESET_COLOR"
  fi
  if [[ $errors_occured -eq 1 ]]; then
    printf "%bErrors occurred during the execution of the script.%b\n" "$ERROR_COLOR" "$RESET_COLOR"
  fi
  if [[ $warnings_occured -eq 0 && $errors_occured -eq 0 ]]; then
    printf "%bScript executed successfully.%b\n" "$SUCCESS_COLOR" "$RESET_COLOR"
  fi

  return 0
}
