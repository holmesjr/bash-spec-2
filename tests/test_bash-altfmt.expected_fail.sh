#!/usr/bin/env bash
# This is run in the directory context of the Makefile.
# Run the inner test. Count the "EXPECTED.*FAIL" markers
# (the failing test now prints EXPECTED before its **** FAIL
# line). If exactly one is present, the inner test failed
# as expected — emit the inner output with the SUMMARY's
# 1 FAILED replaced by 0 FAILED so the runner sees a pass.
# Otherwise emit the original output (regression: the test
# passed when it should have failed).
out="$(./fails/test_bash-spec-altfmt.sh 2>&1)"
count=$(echo "$out" | grep -c "EXPECTED.*FAIL")
if [[ $count -eq 1 ]]; then
  echo "$out" | sed 's/1 FAILED/0 FAILED/'
  exit 0
else
  echo "$out"
  exit 1
fi
