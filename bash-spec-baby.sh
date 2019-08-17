#!/usr/bin/env bash
#==================================================================================
## Minimal testing framework for bash scripts. 
## usage:
##
## [[ some_expression ]]
## should_succeed
## [[ some_expression ]]
## should_fail
##
## bash-spec Author: Dave Nicolette
## Date: 29 Jul 2014
## Modified by REA Group 2014
## bash-spec-baby by keithy@consultant.com 03/2019
#==================================================================================

# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -uo pipefail
IFS=$'\n\t'
shopt -s nullglob # make sure globs are empty arrays if nothing is found

result_file=$(mktemp)

_passed_=0
_failed_=0

exec 6<&1
exec > "$result_file"

function show_help {
    exec 1>&6 6>&-
    rm -f -- "$result_file"
    grep "^##"  $BASH_SOURCE | sed 's/^##//'
}

function output_results {
  exec 1>&6 6>&-
  local results="$(<$result_file)"
  rm -f -- "$result_file"
  local passes=$(printf '%s' "$results" | grep -F PASS | wc -l)
  local fails=$(printf '%s' "$results" | grep -F '**** FAIL' | wc -l )
  printf '%s\n--SUMMARY\n%d PASSED\n%d FAILED\n' "$results" "$passes" "$fails"
  [[ ${fails:-1} -eq 0 ]]
  exit $?
}

function pass {
  echo "     PASS"
}

function fail {
  echo "**** FAIL - expected:$( if [[ "$_negation_" == true ]]; then echo ' NOT'; fi; ) '$_expected_' | actual: '${_actual_[@]}'"
}

function should_succeed {
  _actual_=$?
  _expected_=0
  _negation_=false
  _pass_=false
  [[ $_actual_ == $_expected_ ]] && _pass_=true
  _expected_="0(success)"
  _actual_="$_actual_(failed)"
  _negation_check_
}

function should_fail {
  _actual_=$?
  _expected_=0
  _negation_=false
  _pass_=true
  [[ $_actual_ == $_expected_ ]] && _pass_=false
  _expected_="NOT 0(fail)"
  _actual_="0(succeeded)"
  _negation_check_
}

# pattern - user supplied return variable name
function capture {
	mapfile -t "${!#}" < "$1"
}
 
#kph asks why?
TEMP="$(getopt -o h --long help \
             -n 'javawrap' -- $@)"

if [ $? != 0 ] ; then echo "Terminating..." >&2 ; exit 1 ; fi

eval set -- "$TEMP"

while true; do
  case "$1" in
    h | help ) show_help; exit 0 ;;
    -- ) shift  ;;
    * ) shift; break ;;
  esac
done

trap output_results EXIT
