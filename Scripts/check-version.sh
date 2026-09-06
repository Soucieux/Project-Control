#!/bin/bash
# Validate the repository's major.minor -> major*10+minor rule before packaging.
# Argument 1: source plist path, defaulting to this project's release metadata.
# Returns: zero only for a canonical version and its matching integer build.
set -eu
plist_path="${1:-Resources/Info.plist}"
version_value=$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$plist_path")
build_value=$(/usr/libexec/PlistBuddy -c 'Print :CFBundleVersion' "$plist_path")
if [[ ! "$version_value" =~ ^(0|[1-9][0-9]*)\.([0-9])$ ]]; then
    echo 'Invalid marketing version: use major.minor with one minor digit.' >&2
    exit 1
fi
# Decimal concatenation preserves the policy without fixed-width arithmetic overflow.
expected_build="${BASH_REMATCH[1]}${BASH_REMATCH[2]}"
expected_build="${expected_build#0}"
if [[ "$build_value" != "$expected_build" ]]; then
    echo "Version/build mismatch: v$version_value requires build $expected_build, not $build_value." >&2
    exit 1
fi
