#!/bin/bash
#==================================================================================
# BDD-style testing framework for bash scripts.
#
# print_header "name"                             Echoes title line with 'name'
# print_trailer                                   Echoes # of examples, passed, failed
# it "description"                                Description of example
# expect variable [not] to_be value               Compare scalar values for equality
# expect variable [not] to_match regex            Regex match
# expect array [not] to_contain value             Look for a value in an array
# expect filename [not] to_exist                  Verify file existence
# expect filename [not] to_have_mode modestring   Verify file mode (permissions)
#
# Author: Dave Nicolette
# Date: 29 Jul 2014
#==================================================================================
_count_=0
_passed_=0
_failed_=0

function show_help {
    echo
    echo 'bash_spec usage: Call these functions from your test script'
    echo 'print_header "name"                             Echoes title line with "name"'
    echo 'print_trailer                                   Echoes # of examples, passed, failed'
    echo 'it "description"                                Description of example'
    echo 'expect variable [not] to_be value               Compare scalar values for equality'
    echo 'expect variable [not] to_match regex            Regex match'
    echo 'expect array [not] to_contain value             Look for a value in an array'
    echo 'expect filename [not] to_exist                  Verify file existence'
    echo 'expect filename [not] to_have_mode modestring   Verify file mode (can pass regex)'
    echo
}



function print_header {
    echo '============================================================================='
    echo "Examples for $1"
    echo
}

function print_trailer {
    echo
    echo "$_count_ examples were run"
    echo "$_passed_ passed"
    echo "$_failed_ failed"
    echo '============================================================================='
}

function _incr_count_ {
    (( _count_+=1 )) 
}

function _array_contains_ {
  _found_=false
  for elem in "${_actual_[@]}"; do
      if [[ "$elem" == "$_expected_" ]]; then
          _found_=true
          break
      fi
  done
}

function _negation_check_ {
    if [[ "$_negation_" == true ]]; then
        if [[ "$_pass_" == true ]]; then
            _pass_=false
        else
            _pass_=true
        fi      
    fi  
    if [[ "$_pass_" == true ]]; then
        (( _passed_+=1 ))
        pass
    else
        (( _failed_+=1 ))
        fail
    fi
}

function pass {
  echo "     PASS: it $_it_"
}

function fail {
  echo "**** FAIL: it $_it_ | $expected: ${_expected_[@]} | actual: $_actual_"
}

function it {
  _it_="$1"
    _incr_count_
}

function expect {
  _expected_=
    _negation_=false
    declare -a _actual_
    until [[ "$1" == to_* || "$1" == not || -z "$1" ]]; do
        _actual_+=("$1")
        shift
    done
  "$@"
}

function not {
  _negation_=true
  "$@"
}

function to_be {
    _expected_="$1"
    if [[ "${_actual_[0]}" == "$_expected_" ]]; then 
        _pass_=true
    else
        _pass_=false
    fi
    _negation_check_
}

function to_match {
    _expected_="$1"
    if [[ "${_actual_[0]}" =~ $_expected_ ]]; then 
        _pass_=true
    else
        _pass_=false
    fi
    _negation_check_
}

function to_contain {
    _expected_="$1"
    _array_contains_ "$_expected_" "$_actual_"
    if [ "$_found_" = true ]; then 
        _pass_=true
    else
        _pass_=false
    fi
    _negation_check_
}

function to_exist {
  if [[ -e "${_actual_[0]}" ]]; then
        _pass_=true
    else
        _pass_=false
    fi
    _negation_check_
}

function to_have_mode { 
    _filename_="${_actual_[0]}"
    _expected_="$1"
    if [[ -e "$_filename_" ]]; then
      _fullname_="$_filename_"
    else
      _fullname_="$(which $_filename_)"
    fi  
    if [[ -e "$_fullname_" ]]; then
      _os_=$(uname -a | cut -f 1 -d ' ')
      if [[ $_os_ == Linux ]]; then
        _actual_="$(stat -c %A $_fullname_)"
      else
        _actual_="$(stat $_fullname_ | cut -f 3 -d ' ')"
      fi
      if [[ "$_actual_" =~ $_expected_ ]]; then
        _pass_=true
      else
        _pass_=false
      fi
      _negation_check_
    else
      echo "File not found: $_fullname_"
    fi        
}

TEMP=`getopt -o h --long help \
             -n 'javawrap' -- "$@"`

if [ $? != 0 ] ; then echo "Terminating..." >&2 ; exit 1 ; fi

eval set -- "$TEMP"

while true; do
  case "$1" in
    -h | --help ) show_help; exit 0 ;;
    -- ) shift; break ;;
    * ) break ;;
  esac
done