#!/usr/bin/env bash

# ./_test_run.sh tests the `_run.sh` test runner against this folder of tests

# The script `_run.sh` runs all of the .sh scripts in a folder
# This can be used by gitlab/travis CI as a test/spec runner.
  
source ../bash-spec.sh
cd  test_run

describe "_run.sh - bulk CI runner" && {
  context "Run Locally" && {

    it "expect_var" && {
      a="testing"
      expect_var a to_be "testing"

      a=$(echo "echoed")
      expect_var a to_be "echoed"
    }

    it "expect_array works" && {
      a=("test1")
      a+=("test2")

      expect_var a to_contain "test1"
      expect_array a to_contain "test1"
      expect_array a to_contain "test2"
      expect_array a not to_contain "test3"
    } 

    it "Succeeds once & Fails once" && {
       capture out <( ./_run.sh 2>&1 )
       should_succeed
       printf '[%s]\n' "${out[@]}"
       expect_array out to_contain 'Fails: 1'
       expect_array out to_contain '>pass.sh'     
    }
  }
}
