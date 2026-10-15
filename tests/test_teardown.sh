#!/usr/bin/env bash

# Tests for the optional tearDown hook added to bash-spec.
#
# The hook lets a spec declare a function named `tearDown` which
# bash-spec invokes on EXIT before printing the summary. This
# avoids the common LLM mistake of redeclaring the EXIT trap and
# thereby clobbering output_results.

DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
. "$DIR/../bash-spec.sh"

# Helper: run a small spec body in a subshell and echo its stdout.
# The subshell starts a fresh bash-spec runtime, so the tearDown
# hook fires within that subshell's EXIT trap.
run_spec() {
  bash -c '
    . "'"$DIR"'/../bash-spec.sh"
    '"$1"'
  '
}

describe "tearDown hook" "$(

  context "When the spec defines a tearDown function" "$(

    it "is invoked before output_results" "$(
      # tearDown sets a flag in a marker file. After the spec
      # exits, the marker file should exist (i.e. tearDown ran)
      # AND the summary should be present.
      marker="$DIR/.teardown_ran_$$"
      result="$(run_spec '
        function tearDown { touch "'"$marker"'"; }
        describe "x" "$( it "y" "$( expect "a" to_be "a" )" )"
      ')"
      # tearDown fired
      [[ -f "$marker" ]]
      should_succeed
      # summary still printed
      echo "$result" | grep -q "SUMMARY"
      should_succeed
      # summary line says 1 passed
      echo "$result" | grep -q "1 PASSED"
      should_succeed
      rm -f "$marker"
    )"
  )"

  context "When tearDown returns non-zero" "$(

    it "does not suppress the SUMMARY line" "$(
      result="$(run_spec '
        function tearDown { return 1; }
        describe "x" "$( it "y" "$( expect "a" to_be "a" )" )"
      ')"
      # Even with a failing teardown, the SUMMARY line must print.
      echo "$result" | grep -q "SUMMARY"
      should_succeed
      echo "$result" | grep -q "1 PASSED"
      should_succeed
    )"
  )"

  context "When tearDown is not defined" "$(

    it "is a no-op and the summary still prints" "$(
      result="$(run_spec '
        describe "x" "$( it "y" "$( expect "a" to_be "a" )" )"
      ')"
      echo "$result" | grep -q "SUMMARY"
      should_succeed
      echo "$result" | grep -q "1 PASSED"
      should_succeed
    )"
  )"

  context "When tearDown overrides the trap" "$(

    it "still runs output_results because the hook wraps it" "$(
      # The hook re-declares the trap with output_results included.
      # If the hook didn't, redeclaring EXIT here would clobber
      # output_results. With the hook, the SUMMARY line still prints.
      result="$(run_spec '
        function tearDown { :; }
        describe "x" "$( it "y" "$( expect "a" to_be "a" )" )"
      ')"
      echo "$result" | grep -q "1 PASSED"
      should_succeed
    )"
  )"
)"
