#! /bin/bash
. ./bash-spec.sh

describe "A simple test" "$(
  
  it "Passes with this" "$(
    expect "hello" to_be "hello"
  )"

  it "And with this" "$(
    expect "hi" to_be "hi"
  )"

  it "Fails with this" "$(
    expect "1" to_be "2"
  )"

)"

