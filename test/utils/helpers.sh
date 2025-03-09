#!/bin/bash
line_log_regex() {
  local level="$1"
  local message="$2"

  printf "^\[[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}\.[0-9]{3}\] \[\[[0-9]{2}m%s\[0m\] %s$" "$level" "$message"

  return 0
}

replace_all_in_file() {
  local replace="$1"
  local replacement="$2"
  local file="$3"

  sed -i "s|$replace|$replacement|g" "$file"

  return 0
}
