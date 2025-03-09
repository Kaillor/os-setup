#!/bin/bash
line_log_regex() {
  local level="$1"
  local message="$2"

  printf "^\[[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}\.[0-9]{3}\] \[\[[0-9]{2}m%s\[0m\] %s$" "$level" "$message"

  return 0
}

mock_command() {
  local command="$1"

  eval "$(mock_command_code "$command")"

  return 0
}

mock_command_code() {
  local command="$1"

  printf "%s() {
  printf \"MOCK: %%s\" \"%s\"
  for argument in \"\$@\"; do
    printf \" \\\\\"%%s\\\\\"\" \"\$argument\"
  done
  printf \"\\\\n\"
  return 0
}
" "$command" "$command"

  return 0
}

replace_all_in_file() {
  local replace="$1"
  local replacement="$2"
  local file="$3"

  sed -i "s|$replace|$replacement|g" "$file"

  return 0
}
