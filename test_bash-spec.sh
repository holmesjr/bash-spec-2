#!/usr/bin/env bash

DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
. "$DIR/bash-spec.sh"

describe "The bash version test" "$(

  context "When using bash (especially on MacOS X)" "$(

    it "Version must be 4+" "$(
     [[ "${BASH_VERSINFO[0]}" > "3" ]]
	 should_succeed
     )"
  )"
)"

describe "Should_succeed" "$(
  context "When testing conditional" "$(
    it "reports success as pass" "$(
      [[ "1" = "1" ]]
      should_succeed
    )"
  )"
  context "When testing condition fails" "$(
    result="$(
      [[ "1" = "2" ]]
      should_succeed
    )"

    it "Reports the actual and expected correctly" "$(
      expect "$result" to_be "**** FAIL - expected: '0(success)' | actual: '1(failed)'"
    )"
  )"
)"

describe "Should_fail" "$(
  context "When testing conditional" "$(
    it "reports fail as pass" "$(
      [[ "1" = "2" ]]
      should_fail
    )"
  )"
  context "When testing condition fails" "$(
    result="$(
      [[ "1" = "1" ]]
      should_fail
    )"

    it "Reports the actual and expected correctly" "$(
      expect "$result" to_be "**** FAIL - expected: 'NOT 0(fail)' | actual: '0(succeeded)'"
    )"
  )"
)"

describe "The equality test" "$(

  context "When a single value is passed" "$(

    it "Reports two scalar values are equal" "$(
      one="1"
      expect $one to_be 1
    )"

  )"

  context "When a single value is passed (by ref)" "$(

    it "Reports two scalar values are equal" "$(
      one="1"
      expect_var one to_be 1
    )"

  )"

  context "When a multi word value is passed" "$(

    it "Reports two scalar values are equal" "$(
      string="This is a string."
      expect "$string" to_be "This is a string."
    )"

  )"

  context "When there is a failure" "$(

    result="$(
      expect "Test text" to_be "Something else"
    )"

    it "Reports the actual and expected correctly" "$(
      expect "$result" to_be "**** FAIL - expected: 'Something else' | actual: 'Test text'"
    )"

  )"

)"

describe "The inequality test" "$(

  it "Reports two scalar values are unequal" "$(
    one="1"
    expect $one not to_be 2
  )"

  context "When there is a failure" "$(

    result="$(
      expect "1" not to_be "1"
    )"

    it "Reports the actual and expected correctly" "$(
      expect "$result" to_be "**** FAIL - expected: NOT '1' | actual: '1'"
    )"

  )"

)"

describe "The regex matcher" "$(

  str="one fine day"

  it "Reports a regex match" "$(
    expect "$str" to_match day$
  )"

  context "When there is a failure" "$(

    result="$(
      expect "$str" to_match wibble$
    )"

    it "Reports the actual and expected correctly" "$(
      expect "$result" to_be "**** FAIL - expected: 'wibble$' | actual: 'one fine day'"
    )"

  )"

)"

describe "The regex non-matcher" "$(

  str="one fine night"

  it "Reports regex mismatch" "$(
    expect "$str" not to_match day$
  )"

  context "When there is a failure" "$(

    result="$(
      expect "$str" not to_match night$
    )"

    it "Reports the actual and expected correctly" "$(
      expect "$result" to_be "**** FAIL - expected: NOT 'night$' | actual: 'one fine night'"
    )"

  )"

)"

describe "The array matcher" "$(

  declare -a arr=(1 2 3 4)

  it "Reports an array contains a given value" "$(
    expect "${arr[@]}" to_contain 3
  )"

  context "When there is a failure" "$(

    result="$(
      expect "${arr[@]}" to_contain 5
    )"

    it "Reports the actual and expected correctly" "$(
      expect "$result" to_be "**** FAIL - expected: '5' | actual: '1 2 3 4'"
    )"

  )"

)"

describe "The array non-matcher" "$(

  declare -a arr=(1 2 3 4)

  it "Reports an array does not contain a given value" "$(
    expect "${arr[@]}" not to_contain 5
  )"

  context "When there is a failure" "$(

    result="$(
      expect "${arr[@]}" not to_contain 4
    )"

    it "Reports the actual and expected correctly" "$(
      expect "$result" to_be "**** FAIL - expected: NOT '4' | actual: '1 2 3 4'"
    )"

  )"

)"

describe "The array (passed by reference) matcher" "$(

  declare -a arr=(1 2 3 4)

  it "Reports an array contains a given value" "$(
    expect_array arr to_contain 3
  )"

  context "When there is a failure" "$(

    result="$(
      expect_array arr to_contain 5
    )"

    it "Reports the actual and expected correctly" "$(
      expect "$result" to_be "**** FAIL - expected: '5' | actual: '1 2 3 4'"
    )"

  )"

)"

describe "The array (passed by reference) non-matcher" "$(

  declare -a arr=(1 2 3 4)

  it "Reports an array does not contain a given value" "$(
    expect_array arr not to_contain 5
  )"

  context "When there is a failure" "$(

    result="$(
      expect_array arr not to_contain 4
    )"

    it "Reports the actual and expected correctly" "$(
      expect "$result" to_be "**** FAIL - expected: NOT '4' | actual: '1 2 3 4'"
    )"

  )"

)"


describe "The file existence matcher" "$(

  echo 'test' > tempfile

  it "Reports a file exists" "$(
    expect tempfile to_exist
  )"

  context "When there is a failure" "$(

    rm -f tempfile

    result="$(
      expect tempfile to_exist
    )"

    it "Reports the actual and expected correctly" "$(
      expect "$result" to_be "**** FAIL - expected: 'tempfile EXISTS' | actual: 'File not found'"
    )"

  )"

  rm -f tempfile

)"

describe "The file non-existence matcher" "$(

  it "Reports a file does not exist" "$(
    rm -f tempfile
    expect tempfile not to_exist
  )"

  context "When there is a failure" "$(

    echo 'test' > tempfile

    result="$(
      expect tempfile not to_exist
    )"

    it "Reports the actual and expected correctly" "$(
      expect "$result" to_be "**** FAIL - expected: NOT 'tempfile EXISTS' | actual: 'tempfile'"
    )"

  )"

  rm -f tempfile

)"

describe "The file mode matcher" "$(

  touch tempfile
  chmod u=rw,g=r,o=x tempfile

  it "Reports a file has the given mode" "$(
    expect tempfile to_have_mode -rw-r----x
  )"

  context "When there is a failure" "$(

    result="$(
      expect tempfile to_have_mode -rw-rw-rwx
    )"

    it "Reports the actual and expected correctly" "$(
      expect "$result" to_be "**** FAIL - expected: '-rw-rw-rwx' | actual: '-rw-r----x'"
    )"

  )"

  rm -f tempfile

)"

describe "The file mode non-matcher" "$(

  touch tempfile
  chmod u=rw,g=r,o=x tempfile

  it "Reports a file does not have the given mode" "$(
    expect tempfile not to_have_mode -rw-rw-rwx
  )"

  context "When there is a failure" "$(

    result="$(
      expect tempfile not to_have_mode -rw-r----x
    )"

    it "Reports the actual and expected correctly" "$(
      expect "$result" to_be "**** FAIL - expected: NOT '-rw-r----x' | actual: '-rw-r----x'"
    )"

  )"

  rm -f tempfile

)"

describe "The exit mode matcher" "$(

  function return_boolean {
    if [[ $1 == "true" ]]; then
      return 0
    fi
    return 1
  }

  it "Reports truth when the exit code of the following command is 0" "$(
    expect to_be_true return_boolean true
  )"

  context "When there is a failure" "$(

    result="$(
      expect to_be_true return_boolean false
    )"

    it "Reports the actual and expected correctly" "$(
      expect "$result" to_be "**** FAIL - expected: 'return_boolean false IS TRUE' | actual: 'return_boolean false IS FALSE'"
    )"

  )"

)"

describe "The exit mode non matcher" "$(

  function return_boolean {
    if [[ $1 == "true" ]]; then
      return 0
    fi
    return 1
  }

  it "Reports false when the exit code of the following command is 1" "$(
    expect not to_be_true return_boolean false
  )"

  context "When there is a failure" "$(

    result="$(
      expect not to_be_true return_boolean true
    )"

    it "Reports the actual and expected correctly" "$(
      expect "$result" to_be "**** FAIL - expected: NOT 'return_boolean true IS TRUE' | actual: 'return_boolean true IS TRUE'"
    )"

  )"

)"

describe "Setting variables when nesting" "$(

  test_var="first value"

  it "Pulls a value into an it from the outer level" "$(
    expect "$test_var" to_be "first value"
  )"

  context "When there is a nested context" "$(

    it "Pulls a value into the inner it from the very outer level" "$(
      expect "$test_var" to_be "first value"
    )"

  )"

  context "When the context overwrites the value" "$(

    test_var="second value"

    it "Pulls the value into the inner it from the next level out" "$(
      expect "$test_var" to_be "second value"
    )"

  )"

  it "Does not get affected by values set in inner nesting earlier on" "$(
    expect "$test_var" to_be "first value"
  )"

)"
