#!/bin/bash
# Exercise release validation using a disposable copy, never changing source metadata.
# Arguments: none. Returns: zero only when valid pairs pass and invalid pairs fail.
set -eu
fixture_dir=$(mktemp -d)
trap 'rm -rf "$fixture_dir"' EXIT
fixture_plist="$fixture_dir/Info.plist"
cp Resources/Info.plist "$fixture_plist"
checks=0

# Arguments: marketing version, build, expected result (pass/fail).
# Returns: zero on the expected validation result; otherwise stops the test.
check_pair() {
    /usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $1" "$fixture_plist"
    /usr/libexec/PlistBuddy -c "Set :CFBundleVersion $2" "$fixture_plist"
    checks=$((checks + 1))
    # The expectation stays last so its status is the function's, keeping set -e able to stop the run.
    if /bin/bash Scripts/check-version.sh "$fixture_plist" >/dev/null 2>&1; then
        [[ "$3" == pass ]]
    else
        [[ "$3" == fail ]]
    fi
}

check_pair 2.6 26 pass
check_pair 2.9 29 pass
check_pair 3.0 30 pass
check_pair 0.9 9 pass
check_pair 2.5 16 fail
check_pair 2.10 30 fail
check_pair 2.6 026 fail
check_pair 02.6 26 fail
check_pair 2.6.1 26 fail
check_pair 0.0 0 pass
check_pair 922337203685477580.8 9223372036854775808 pass
check_pair 922337203685477580.8 -9223372036854775808 fail
echo "Version checks passed: $checks"
