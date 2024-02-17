#!/bin/bash
backupDirectoryName="backups"
patchDirectoryName="patches"

applyPatches() {
    fileWithListOfFilesToPatch=$1
    if ! __fileExists "$fileWithListOfFilesToPatch"; then
        echo "File with list of files to patch not found: $file"
        return
    fi

    echo "Applying patches to files in $fileWithListOfFilesToPatch"

    workingDirectory=$(dirname "$fileWithListOfFilesToPatch")
    __createBackupDirectory $workingDirectory

    while IFS= read -r line; do
        if __lineIsValidFile "$line"; then
            __applyPatch "$workingDirectory" "$line"
        fi
    done < "$fileWithListOfFilesToPatch"
}

__applyPatch() {
    workingDirectory=$1
    fileToPatch=$2

    echo "Backing up file $fileToPatch"
    cp "$fileToPatch" "$workingDirectory/$backupDirectoryName"

    fileToPatchName=$(basename "$fileToPatch")
    patchFile="$workingDirectory/$patchDirectoryName/$fileToPatchName.patch"

    if ! __fileExists "$patchFile"; then
        echo "Patch file not found: $patchFile"
        return
    fi

    echo "Patching file $fileToPatch"
    sudo patch "$fileToPatch" "$patchFile"
}

revertPatches() {
    fileWithListOfFilesToRevert=$1
    if ! __fileExists "$fileWithListOfFilesToRevert"; then
        echo "File with list of files to revert not found: $file"
        return
    fi

    echo "Reverting patches of files in $fileWithListOfFilesToRevert"

    workingDirectory=$(dirname "$fileWithListOfFilesToRevert")

    while IFS= read -r line; do
        if __lineIsValidFile "$line"; then
            __revertPatch "$workingDirectory" "$line"
        fi
    done < "$fileWithListOfFilesToRevert"
}

__revertPatch() {
    workingDirectory=$1
    fileToRevert=$2

    fileToRevertName=$(basename "$fileToRevert")
    originalFile="$workingDirectory/$backupDirectoryName/$fileToRevertName"

    if ! __fileExists "$originalFile"; then
        echo "Original file not found: $originalFile"
        return
    fi

    echo "Reverting file $fileToRevert"
    cp "$originalFile" "$fileToRevert"
}

__createBackupDirectory() {
    workingDirectory=$1
    mkdir -p "$workingDirectory/$backupDirectoryName"
}

__lineIsValidFile() {
    line=$1
    if ! ( __lineIsEmpty "$line" || __lineIsComment "$line" ); then
        if __fileExists "$line"; then
            return 1
        else
            echo "File not found: $line"
            return 0
        fi
    else
        return 0
    fi
}

__lineIsEmpty() {
    line=$1
    if [[ -n "$line" ]]; then
        return 1
    else
        return 0
    fi
}

__lineIsComment() {
    line=$1
    if [[ "$line" == \#* ]]; then
        return 1
    else
        return 0
    fi
}

__fileExists() {
    file=$1
    if [[ -f "$file" ]]; then
        return 1
    else
        return 0
    fi
}
