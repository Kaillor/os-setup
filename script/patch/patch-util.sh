#!/bin/bash
export FILES_TO_PATCH_NAME="files-to-patch"
export PATCH_DIRECTORY_NAME="patches"

readonly FILES_TO_PATCH_NAME
readonly PATCH_DIRECTORY_NAME

apply_patches() {
  local path="$1"

  if [[ -f $path ]]; then
    __apply_patches "$(realpath "$path")"
  elif [[ -d $path ]]; then
    info "Searching for files named '$FILES_TO_PATCH_NAME' in '$path'."
    find "$path" -name "$FILES_TO_PATCH_NAME" -print0 | while IFS= read -r -d '' file; do
      __apply_patches "$(realpath "$file")"
    done
  else
    error "Path '$path' does not exist."
    return 1
  fi

  return 0
}

__apply_patches() {
  local file_with_list_of_files_to_patch="$1"

  info "Applying patches to files in '$file_with_list_of_files_to_patch'."

  local working_directory
  working_directory="$(dirname "$file_with_list_of_files_to_patch")"

  while IFS= read -r "line"; do
    if __line_is_valid "$line"; then
      if [[ -f $line ]]; then
        __apply_patch "$working_directory" "$line"
      else
        warning "File to patch '$line' not found."
      fi
    fi
  done < "$file_with_list_of_files_to_patch"

  return 0
}

__apply_patch() {
  local working_directory="$1"
  local file_to_patch="$2"

  local patch_file
  patch_file="$working_directory/$PATCH_DIRECTORY_NAME/$(basename "$file_to_patch").patch"

  if [[ ! -f $patch_file ]]; then
    error "Patch file '$patch_file' for file to patch '$file_to_patch' not found."
    return 1
  fi

  info "Patching file '$file_to_patch'."
  local patch_output
  if ! patch_output="$(sudo patch -s -b -N "$file_to_patch" "$patch_file" 2>&1)"; then
    error "Failed to patch file '$file_to_patch': $patch_output"
    return 1
  fi

  return 0
}

revert_patches() {
  local path="$1"

  if [[ -f $path ]]; then
    __revert_patches "$(realpath "$path")"
  elif [[ -d $path ]]; then
    info "Searching for files named '$FILES_TO_PATCH_NAME' in '$path'."
    find "$path" -name "$FILES_TO_PATCH_NAME" -print0 | while IFS= read -r -d '' file; do
      __revert_patches "$(realpath "$file")"
    done
  else
    error "Path '$path' does not exist."
    return 1
  fi
}

__revert_patches() {
  local file_with_list_of_files_to_revert="$1"

  info "Reverting patches of files in '$file_with_list_of_files_to_revert'."

  local working_directory
  working_directory="$(dirname "$file_with_list_of_files_to_revert")"

  while IFS= read -r "line"; do
    if __line_is_valid "$line"; then
      if [[ -f $line ]]; then
        __revert_patch "$working_directory" "$line"
      else
        warning "File to revert '$line' not found."
      fi
    fi
  done < "$file_with_list_of_files_to_revert"

  return 0
}

__revert_patch() {
  local working_directory="$1"
  local file_to_revert="$2"

  local patch_file
  patch_file="$working_directory/$PATCH_DIRECTORY_NAME/$(basename "$file_to_revert").patch"

  if [[ ! -f $patch_file ]]; then
    error "Patch file '$patch_file' for file to revert '$file_to_revert' not found."
    return 1
  fi

  info "Reverting file '$file_to_revert'."
  local patch_output
  if ! patch_output="$(sudo patch -s -R "$file_to_revert" "$patch_file" 2>&1)"; then
    error "Failed to revert file '$file_to_revert': $patch_output"
    return 1
  fi

  return 0
}

__line_is_valid() {
  local line="$1"

  if [[ -z "$line" ]] || [[ "$line" == \#* ]]; then
    return 1
  fi

  return 0
}
