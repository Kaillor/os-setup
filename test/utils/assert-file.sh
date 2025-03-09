#!/bin/bash
assert_file_content_equals() {
  local file="$1"
  local expected_content="$2"

  assert_equal "$(cat "$file")" "$expected_content"

  return 0
}

assert_file_count() {
  local directory="$1"
  local expected_count="$2"

  assert_equal "$(find "$directory" -maxdepth 1 -type f | wc -l)" "$expected_count"

  return 0
}

assert_file_empty_script() {
  local file="$1"

  assert_file_content_equals "$file" "#!/bin/bash"

  return 0
}

assert_file_log_name() {
  local file="$1"
  local script_name="$2"

  assert_regex "$(basename "$file")" "^[0-9]{4}-[0-9]{2}-[0-9]{2}_[0-9]{2}:[0-9]{2}:[0-9]{2}_$script_name.log$"

  return 0
}
