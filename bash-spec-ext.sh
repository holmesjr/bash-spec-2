#! /bin/bash

DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
. "$DIR/bash-spec.sh"

result_file=$RANDOM

exec 6<&1
exec > "$result_file"

function output_results {
  exec 1>&6 6>&-
  local results=$( cat "$result_file" )
  rm "$result_file"
  local passes=$( echo "$results" | grep "PASS" | wc -l )
  local fails=$( echo "$results" | grep "\*\*\*\* FAIL" | wc -l )
  echo "$results"
  echo "--SUMMARY--"
  echo "$passes PASSED"
  echo "$fails FAILED"
  if [[ $fails -gt 0 ]]; then
    exit 1
  else
    exit 0
  fi
}

function it {
  echo "  $1"
  echo "    $2"
}

function describe {
  echo "$1"
  echo "$2"
}

function context {
  echo "$1"
  echo "$2"
}

function pass {
  echo "     PASS"
}

function fail {
  echo "**** FAIL - expected:$( if [[ "$_negation_" == true ]]; then echo " NOT"; fi; ) $_expected_ | actual: ${_actual_[@]}"
}

trap output_results EXIT
