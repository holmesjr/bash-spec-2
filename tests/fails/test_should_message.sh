#!/usr/bin/env bash

# Tests for the optional-message pattern in should_succeed and
# should_fail. The message is only displayed on the unexpected
# outcome (failure for should_succeed, success for should_fail);
# pass lines stay clean.

DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
. "$DIR/../../bash-spec.sh"

describe "should_succeed / should_fail with optional message" "$(

  context "should_succeed with a passing expression" "$(

    it "does not display the message" "$(
      [[ 1 == 1 ]]
      should_succeed "this should pass with no message"
    )"
  )"

  context "should_succeed with a failing expression" "$(

    it "displays the message in the FAIL line" "$(
      printf EXPECTED
      [[ 1 == 2 ]]
      should_succeed "this should fail with the message"
    )"
  )"

  context "should_fail with a failing expression" "$(

    it "does not display the message" "$(
      [[ 1 == 2 ]]
      should_fail "this should pass with no message"
    )"
  )"

  context "should_fail with a passing expression" "$(

    it "displays the message in the FAIL line" "$(
      printf EXPECTED
      [[ 1 == 1 ]]
      should_fail "this should fail with the message"
    )"
  )"
)"
