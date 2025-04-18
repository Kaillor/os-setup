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
  local -a install_scripts
  for system_part in "${system[@]}"; do
    system_part_directory+="/$system_part"
    install_scripts+=("$system_part_directory/install/common/install.sh")
    install_scripts+=("$system_part_directory/install/$profile/install.sh")
  done

  local -a missing_install_scripts
  for install_script in "${install_scripts[@]}"; do
    if [[ ! -f $install_script ]]; then
      missing_install_scripts+=("$install_script")
    fi
  done
  if [[ "${#missing_install_scripts[@]}" -gt 0 ]]; then
    error "The following install scripts are missing: '${missing_install_scripts[*]}'."
    return 1
  fi

  for install_script in "${install_scripts[@]}"; do
    info "Executing install script '$install_script'."
    bash "$install_script"
  done

  return 0
}

main "$@"
