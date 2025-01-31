#!/bin/bash
source "$(dirname "${BASH_SOURCE[0]}")/../script-utils.sh"

backupDirectoryName="backups"
patchDirectoryName="patches"

applyPatches() {
  if [ "$#" -eq 0 ]; then
    error "File with list of files to patch not provided."
    return 2
  fi

  fileWithListOfFilesToPatch="$1"
  if ! __fileExists "$fileWithListOfFilesToPatch"; then
    error "File '$file' with list of files to patch not found."
    return 1
  fi

  info "Applying patches to files in '$fileWithListOfFilesToPatch'."

  workingDirectory="$(dirname "$fileWithListOfFilesToPatch")"
  mkdir -p "$workingDirectory/$backupDirectoryName"

  while IFS= read -r "line"; do
    if __lineIsValid "$line"; then
      if __fileExists "$line"; then
        __applyPatch "$workingDirectory" "$line"
      else
        warning "File to patch '$line' not found."
      fi
    fi
  done < "$fileWithListOfFilesToPatch"
}

__applyPatch() {
  workingDirectory="$1"
  fileToPatch="$2"

  fileToPatchName="$(basename "$fileToPatch")"
  patchFile="$workingDirectory/$patchDirectoryName/$fileToPatchName.patch"

  if ! __fileExists "$patchFile"; then
    error "Patch file '$patchFile' for file to patch '$fileToPatch' not found."
    return
  fi

  info "Backing up file '$fileToPatch'."
  cp "$fileToPatch" "$workingDirectory/$backupDirectoryName"

  sudo patch "$fileToPatch" "$patchFile"
}

revertPatches() {
  if [ "$#" -eq 0 ]; then
    error "File with list of files to revert not provided."
    return 2
  fi

  fileWithListOfFilesToRevert="$1"
  if ! __fileExists "$fileWithListOfFilesToRevert"; then
    error "File '$file' with list of files to revert not found."
    return 1
  fi

  info "Reverting patches of files in '$fileWithListOfFilesToRevert'."

  workingDirectory="$(dirname "$fileWithListOfFilesToRevert")"

  while IFS= read -r "line"; do
    if __lineIsValid "$line"; then
      if __fileExists "$line"; then
        __revertPatch "$workingDirectory" "$line"
      else
        warning "File to revert '$line' not found."
      fi
    fi
  done < "$fileWithListOfFilesToRevert"
}

__revertPatch() {
  workingDirectory="$1"
  fileToRevert="$2"

  fileToRevertName="$(basename "$fileToRevert")"
  backupFile="$workingDirectory/$backupDirectoryName/$fileToRevertName"

  if ! __fileExists "$backupFile"; then
    error "Backup file '$backupFile' for file to revert '$fileToRevert' not found."
    return
  fi

  info "Reverting file '$fileToRevert'."
  cp "$backupFile" "$fileToRevert"
}

__lineIsValid() {
  line="$1"
  if ! (__lineIsEmpty "$line" || __lineIsComment "$line"); then
    return 0
  else
    return 1
  fi
}

__lineIsEmpty() {
  line="$1"
  if [[ -n $line ]]; then
    return 1
  else
    return 0
  fi
}

__lineIsComment() {
  line="$1"
  if [[ $line == \#* ]]; then
    return 0
  else
    return 1
  fi
}

__fileExists() {
  file="$1"
  if [[ -f $file ]]; then
    return 0
  else
    return 1
  fi
}
