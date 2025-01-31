#!/bin/bash
main() {
  local script_directory
  script_directory="$(dirname "${BASH_SOURCE[0]}")"
  source "$script_directory/scripts/script-utils.sh"

  local -a profiles=("personal" "axon-ivy")
  local profile
  menu "Profile" "profiles" "profile"

  local os_directory="$script_directory/os"
  local -a system
  source "$os_directory/setup.sh" "system"

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

  local system_part_directory="$os_directory"
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
