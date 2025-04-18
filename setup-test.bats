#!/bin/bash
load "./test/test-util.sh"

SCRIPT_UNDER_TEST="$BATS_TEST_DIRNAME/setup.sh"

TEST_RESOURCES="$TEST_RESOURCES_DIRECTORY/setup"

setup() {
  TEST_TEMP_DIR="$(temp_make)"
}

teardown() {
  temp_del "$TEST_TEMP_DIR"
}

@test "setup | no to install" {
  local menu_mock
  menu_mock="$(mock_command_code "menu" "local -n menu_selection=\"\$3\"
menu_selection=\"selectedProfile\"")"
  local setup_mock
  setup_mock="$(mock_command_code "setup" "local -n system_operating_system=\"\$1\"
system_operating_system=(\"selectedOperatingSystem\" \"selectedDistribution\" \"selectedFlavor\")")"

  run_script_with_mocked_commands -s "$SCRIPT_UNDER_TEST" -i $'invalid input\nn' -m "source" -m "require_sudo" -c "$menu_mock" -c "$setup_mock"
  assert_success
  assert_output "MOCK: source \"./script/script-util.sh\"
MOCK: require_sudo
MOCK: menu \"Profile\" \"profiles\" \"profile\"
MOCK: source \"./setup/setup.sh\"
MOCK: setup \"system\"
Profile: selectedProfile
System: selectedOperatingSystem selectedDistribution selectedFlavor
Start install? (y/n)

Profile: selectedProfile
System: selectedOperatingSystem selectedDistribution selectedFlavor
Start install? (y/n)"
}

@test "setup | yes to install" {
  cd "$TEST_TEMP_DIR"
  cp "$SCRIPT_UNDER_TEST" "$TEST_TEMP_DIR"
  cp -r "$TEST_RESOURCES/." "$TEST_TEMP_DIR"

  local menu_mock
  menu_mock="$(mock_command_code "menu" "local -n menu_selection=\"\$3\"
menu_selection=\"selectedProfile\"")"
  local setup_mock
  setup_mock="$(mock_command_code "setup" "local -n system_operating_system=\"\$1\"
system_operating_system=(\"selectedOperatingSystem\" \"selectedDistribution\" \"selectedFlavor\")")"
  local run_and_log_mock
  run_and_log_mock="$(mock_command_code "run_and_log" "local command=\"\$1\"
eval \"\$command\"")"

  run_script_with_mocked_commands \
    -s "$TEST_TEMP_DIR/setup.sh" \
    -m "source" \
    -m "require_sudo" \
    -c "$menu_mock" \
    -c "$setup_mock" \
    -i "y" \
    -c "$run_and_log_mock" \
    -m "info"
  assert_success
  assert_output "MOCK: source \"./script/script-util.sh\"
MOCK: require_sudo
MOCK: menu \"Profile\" \"profiles\" \"profile\"
MOCK: source \"./setup/setup.sh\"
MOCK: setup \"system\"
Profile: selectedProfile
System: selectedOperatingSystem selectedDistribution selectedFlavor
Start install? (y/n)

MOCK: run_and_log \"__install ./setup selectedProfile selectedOperatingSystem selectedDistribution selectedFlavor\"
MOCK: info \"Executing install script './setup/selectedOperatingSystem/install/common/install.sh'.\"
EXECUTE: ./setup/selectedOperatingSystem/install/common/install.sh
MOCK: info \"Executing install script './setup/selectedOperatingSystem/install/selectedProfile/install.sh'.\"
EXECUTE: ./setup/selectedOperatingSystem/install/selectedProfile/install.sh
MOCK: info \"Executing install script './setup/selectedOperatingSystem/selectedDistribution/install/common/install.sh'.\"
EXECUTE: ./setup/selectedOperatingSystem/selectedDistribution/install/common/install.sh
MOCK: info \"Executing install script './setup/selectedOperatingSystem/selectedDistribution/install/selectedProfile/install.sh'.\"
EXECUTE: ./setup/selectedOperatingSystem/selectedDistribution/install/selectedProfile/install.sh
MOCK: info \"Executing install script './setup/selectedOperatingSystem/selectedDistribution/selectedFlavor/install/common/install.sh'.\"
EXECUTE: ./setup/selectedOperatingSystem/selectedDistribution/selectedFlavor/install/common/install.sh
MOCK: info \"Executing install script './setup/selectedOperatingSystem/selectedDistribution/selectedFlavor/install/selectedProfile/install.sh'.\"
EXECUTE: ./setup/selectedOperatingSystem/selectedDistribution/selectedFlavor/install/selectedProfile/install.sh"
}

@test "setup | yes to install | missing install scripts" {
  cd "$TEST_TEMP_DIR"
  cp "$SCRIPT_UNDER_TEST" "$TEST_TEMP_DIR"
  cp -r "$TEST_RESOURCES/." "$TEST_TEMP_DIR"

  local menu_mock
  menu_mock="$(mock_command_code "menu" "local -n menu_selection=\"\$3\"
menu_selection=\"selectedProfile\"")"
  local setup_mock
  setup_mock="$(mock_command_code "setup" "local -n system_operating_system=\"\$1\"
system_operating_system=(\"selectedOperatingSystemWithMissingInstallScripts\" \"selectedDistribution\" \"selectedFlavor\")")"
  local run_and_log_mock
  run_and_log_mock="$(mock_command_code "run_and_log" "local command=\"\$1\"
eval \"\$command\"")"

  run_script_with_mocked_commands \
    -s "$TEST_TEMP_DIR/setup.sh" \
    -m "source" \
    -m "require_sudo" \
    -c "$menu_mock" \
    -c "$setup_mock" \
    -i "y" \
    -c "$run_and_log_mock" \
    -m "error"
  assert_success
  assert_output "MOCK: source \"./script/script-util.sh\"
MOCK: require_sudo
MOCK: menu \"Profile\" \"profiles\" \"profile\"
MOCK: source \"./setup/setup.sh\"
MOCK: setup \"system\"
Profile: selectedProfile
System: selectedOperatingSystemWithMissingInstallScripts selectedDistribution selectedFlavor
Start install? (y/n)

MOCK: run_and_log \"__install ./setup selectedProfile selectedOperatingSystemWithMissingInstallScripts selectedDistribution selectedFlavor\"
MOCK: error \"The following install scripts are missing: './setup/selectedOperatingSystemWithMissingInstallScripts/install/selectedProfile/install.sh \
./setup/selectedOperatingSystemWithMissingInstallScripts/selectedDistribution/install/common/install.sh \
./setup/selectedOperatingSystemWithMissingInstallScripts/selectedDistribution/selectedFlavor/install/common/install.sh \
./setup/selectedOperatingSystemWithMissingInstallScripts/selectedDistribution/selectedFlavor/install/selectedProfile/install.sh'.\""
}
