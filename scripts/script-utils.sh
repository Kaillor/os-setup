#!/bin/bash
info() {
  local message="$1"

  __print_log "\e[34mINFO\e[0m" "$message"

  return 0
}

warning() {
  local message="$1"

  __print_log "\e[33mWARNING\e[0m" "$message"

  return 0
}

error() {
  local message="$1"

  __print_log "\e[31mERROR\e[0m" "$message"

  return 0
}

__print_log() {
  local level="$1"
  local message="$2"

  printf "[%s] [%b] %s\n" "$(date '+%Y-%m-%d %H:%M:%S.%3N')" "$level" "$message"

  return 0
}

setup_menu() {
  local label="$1"
  local directory="$2"
  # shellcheck disable=SC2034
  local -n selection="$3"

  # shellcheck disable=SC2034
  local -a options
  __child_directories "$directory" "options" "install"
  menu "$label" "options" "selection"

  return 0
}

__child_directories() {
  local directory="$1"
  local -n child_directories="$2"
  local filter="$3"

  # shellcheck disable=SC2034
  mapfile -t child_directories < <(find "$directory" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | grep -v "$filter" | sort)

  return 0
}

menu() {
  local label="$1"
  local -n menu_options="$2"
  local -n menu_selection="$3"

  while true; do
    printf "%s:\n" "$label"
    for i in "${!menu_options[@]}"; do
      printf " %d. %s\n" "$((i + 1))" "${menu_options["$i"]}"
    done
    printf "Type 'exit' to quit.\n"

    local choice
    read -r choice
    printf "\n"
    if [[ $choice == "exit" ]]; then
      exit 0
    fi

    if [[ $choice =~ ^[0-9]+$ ]] && [ "$choice" -gt 0 ] && [ "$choice" -le "${#menu_options[@]}" ]; then
      # shellcheck disable=SC2034
      menu_selection="${menu_options[$((choice - 1))]}"
      break
    fi

    continue
  done

  return 0
}
