#!  /bin/bash

. ./bash-spec-ext.sh

describe "The equality test" "$(
  
  context "When a single value is passed" "$(

    it "Reports two scalar values are equal" "$(
      one="1"
      expect $one to_be 1   
    )"

  )"

  context "When a multi word value is passed" "$(

    it "Reports two scalar values are equal" "$(
      string="This is a string."
      expect "$string" to_be "This is a string." 
    )"

  )"

  context "When there is a failure" "$(

    it "Reports the actual and expected correctly" "$(

      result="$( 
        expect "Test text" to_be "Something else"
      )"

      expect "$result" to_be "**** FAIL - expected: Something else | actual: Test text"

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

    expect "$result" to_be "**** FAIL - expected: NOT 1 | actual: 1"

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

    expect "$result" to_be "**** FAIL - expected: wibble$ | actual: one fine day"

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

    expect "$result" to_be "**** FAIL - expected: NOT night$ | actual: one fine night"

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

    expect "$result" to_be "**** FAIL - expected: 5 | actual: 1 2 3 4"

  )"

)"

describe "The array non-matcher" "$(

  it "Reports an array does not contain a given value" "$(
    declare -a arr=(1 2 3 4)
    expect "${arr[@]}" not to_contain 5
  )"

)"

describe "The file existence matcher" "$(
  
  it "Reports a file exists" "$(
    echo 'test' > tempfile
    expect tempfile to_exist
    rm -f tempfile
  )"

)"

describe "The file non-existence matcher" "$(
  
  it "Reports a file does not exist" "$(
    rm -f tempfile
    expect tempfile not to_exist
  )"

)"

describe "The file mode matcher" "$(
  
  it "Reports a file has the given mode" "$(
    touch tempfile
    chmod u=rw,g=r,o=x tempfile
    expect tempfile to_have_mode -rw-r----x
    rm -f tempfile
  )"

)"

describe "The file mode non-matcher" "$(
  it "Reports a file does not have the given mode" "$(
    touch tempfile
    chmod u=rw,g=r,o=x tempfile
    expect tempfile not to_have_mode -rw-rw-rwx
    rm -f tempfile
  )"
)"