#! /bin/bash

. ./bash-spec.sh

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