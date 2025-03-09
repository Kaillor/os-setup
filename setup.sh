#!/bin/bash
main() {
  local script_directory
  script_directory="$(dirname "${BASH_SOURCE[0]}")"
  source "$script_directory/script/script-util.sh"

  require_sudo

  local -a profiles=("personal" "axon-ivy")
  local profile
  menu "Profile" "profiles" "profile"

  local setup_directory="$script_directory/setup"
  local -a system
  source "$setup_directory/setup.sh"
  setup "system"

  while true; do
    printf "Profile: %s\n" "$profile"
    printf "System: %s\n" "${system[*]}"
    printf "Start install? (y/n)\n"
    local start_install
    read -r start_install
    printf "\n"
    if [[ $start_install == "y" ]]; then
      break
    elif [[ $start_install == "n" ]]; then
      return 0
    fi
  done

  run_and_log "__install $setup_directory $profile ${system[*]}"

  return 0
}

# shellcheck disable=SC2317
__install() {
  local setup_directory="$1"
  local profile="$2"
  local -a system=("${@:3}")

  local system_part_directory="$setup_directory"
  for system_part in "${system[@]}"; do
    system_part_directory+="/$system_part"

    local system_part_directory_install_common="$system_part_directory/install/common/install.sh"
    if [[ -f $system_part_directory_install_common ]]; then
      info "Executing install script '$system_part_directory_install_common'."
      bash "$system_part_directory_install_common"
    else
      error "Install script '$system_part_directory_install_common' not found."
      return 1
    fi

    local system_part_directory_install_profile="$system_part_directory/install/$profile/install.sh"
    if [[ -f $system_part_directory_install_profile ]]; then
      info "Executing install script '$system_part_directory_install_profile'."
      bash "$system_part_directory_install_profile"
    else
      error "Install script '$system_part_directory_install_profile' not found."
      return 1
    fi
  done

  return 0
}

main "$@"
