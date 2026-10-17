#!/usr/bin/env bash

# Test the glob-match variants of `expect ... to_contain`,
# advertised in the bash-spec help block as:
#
#   ## expect array [not] to_contain "*bash\ spec*"   Look for a value in an array (glob match)
#   ## expect_var variablename [not] to_contain "*value*"  Look for a value in a variable (glob match)
#
# The help text includes the `*pattern*` form so LLMs (and humans)
# see that to_contain is a glob match, not a literal equality.
# This spec verifies that contract on both the array and
# variable variants.

DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
. "$DIR/../bash-spec.sh"

describe "expect ... to_contain glob match" "$(

  context "expect (positional array form) supports a glob" "$(

    it "matches when an element fits the *pattern*" "$(
      arr=( "bash spec is fun" "another entry" "third" )
      expect "${arr[@]}" to_contain "*bash*spec*"
    )"

    it "does not match when no element fits the pattern" "$(
      arr=( "alpha" "beta" "gamma" )
      result="$(expect "${arr[@]}" to_contain "*missing*")"
      # result is the failure message; check it mentions FAIL.
      echo "$result" | grep -q "FAIL"
    )"
  )"

  context "expect_var (variable form) supports a glob" "$(

    it "matches when the variable's value fits the pattern" "$(
      var="this is a bash spec value"
      expect_var var to_contain "*bash*spec*"
    )"
  )"

  context "the help block advertises the glob form" "$(

    it "appears as a ## comment in the bash-spec.sh header" "$(
      grep -q '^## expect array \[not\] to_contain "\*' "$DIR/../bash-spec.sh"
      should_succeed
    )"

    it "the expect_var line in the help block shows a *pattern* example" "$(
      grep -q '^## expect_var.*"\*value\*"' "$DIR/../bash-spec.sh"
      should_succeed
    )"
  )"
)"
