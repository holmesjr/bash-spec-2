#!/usr/bin/env bash

# Run every executable spec in this tree and report pass/fail counts.
#
# Convention: each spec file lives at <category>/<name>.spec.sh.
# The runner executes each spec from its own directory. Each spec
# handles finding and entering its own fixture directory if needed.
#
# Usage: _pretty_run_all.sh [GLOB]
#   GLOB  optional shell glob (default: "*/*spec.sh */test*.sh")
#         e.g. "*/test*.sh" to run only the test-style files, or
#         "tests/test_teardown.sh" to run a single file.
#
# Set VERBOSE=true to also print each spec's full output
# below its index line. Default is index only.
#
# Default mode:
#   - one line per spec in the index: green check for pass, red X for fail
#   - severity-tagged lines from the suite output:
#       OK:     green  with ✔ prefix
#       INFO:   cyan   with » prefix
#       WARN:   yellow with ⚠ prefix
#       ERROR:  red    with ✖ prefix
#     untagged lines are suppressed
#   - summary box: ran N specs, M pass, K fail
#   - exit code is the failure count, suitable for CI gating

set -uo pipefail

# ANSI colour escapes — central place to tweak palette.
_red=$'\033[31m'
_green=$'\033[32m'
_yellow=$'\033[33m'
_cyan=$'\033[36m'
_reset=$'\033[0m'

_self="${BASH_SOURCE[0]:-$0}"
case "$_self" in
  /*) _dir="$(dirname -- "$_self")" ;;
  *)  _dir="$(cd -- "$(dirname -- "$_self")" 2>/dev/null && pwd -P)" ;;
esac
cd "$_dir"

# Argument parsing. The runner accepts a single optional
# argument: a shell glob pattern to select which tests to run,
# e.g. "*/test*.sh" or "tests/test_teardown.sh" (omit the arg
# to run the default glob).
#
# Verbosity is controlled by the $VERBOSE=true
#   VERBOSE=true ./_pretty_run_all.sh        # full spec output
#   ./_pretty_run_all.sh                     # index only (default)
glob='*/*spec.sh */test*.sh'
for arg in "$@"; do
  case "$arg" in
    -h|--help)
      sed -n '2,/^$/p' "$0" | sed 's/^# \{0,1\}//'
      exit 0
      ;;
    *)  glob="$arg" ;;
  esac
done

# Severity-quiet mode: set QUIET=true to silence the severity-filtered
# INFO/WARN/ERROR lines that normally accompany each spec. The summary
# index (✔/✘) still prints.
QUIET=${QUIET:-false}

# Per-spec severity-filtered output is wrapped in loud() so QUIET=1
# silences it. Use this for any optional verbose detail that should
# follow the spec index, not as a wrapper around the spec itself
# (the spec must always run).
#
# Usage:
#   loud "lines to print"
#   loud bash -c 'printf "..."'     # command variant
loud () {
  $QUIET && return 0
  [[ $# -eq 0 ]] && return 0
  [[ "$1" == "-" ]] && cat || printf '%s\n' "$@"
  :
}

fails=0
total=0
passes=0
total_pass_assertions=0
total_fail_assertions=0
shopt -s extglob
# Filter a stream of bash-spec / spec output down to severity-tagged
# lines, colour-coded, four patterns, anything else is dropped.
banner_filter () {
  local in line
  while IFS=$'\n' read -r in; do
    read -r line <<< "$in"
    line=" $in"
    line="${line// ERROR/${_red}✖ ERROR}"
    line="${line// WARN/${_yellow}⚠ WARN}"
    line="${line// INFO/${_cyan}» INFO}" 
    line="${line// OK/${_green}✔ OK}" 
    if [[ "$line" != " $in" ]]; then
  	printf "     %s${_reset}\n" "$line"
    fi 
  done
}

# Print one index line per spec. All lines show passed/total
# counts; pass lines print green, fail lines red.
index_line () {
  local status="$1" name="$2" rc="$3" pass_n="$4" fail_n="$5"
  local total=$((pass_n + fail_n))
  if [[ "$status" == pass ]]; then
    printf "  ${_green}✔${_reset}  %-50s (%d/%d)\n" "$name" "$pass_n" "$total"
  else
    printf "  ${_red}✘${_reset}  %-50s (%d/%d) rc=%d\n" "$name" "$pass_n" "$total" "$rc"
  fi
}

declare -a FAILED_SPECS=()
# Per-file banners. Each iteration of the loop populates the
# file_banners local, then the per-file banners are emitted
# right after that file's index line.
declare -a file_banners=()

for test in $glob;
do
   [[ -x "$test" ]] || continue
   total=$((total + 1))

   spec_dir="$(dirname -- "$test")"
   spec_name="$(basename -- "$test")"
   rel_path="$(basename -- "$spec_dir")/${spec_name}"

   # Run the spec from its own directory. BASH_SPEC_PATH points at
   # the bash-spec.sh shipped alongside this runner, so specs that
   # source it directly (instead of the clean-env shim) find the
   # runner.
   out=$(cd "$spec_dir" && BASH_SPEC_PATH="$_dir/bash-spec.sh" \
         bash "./${spec_name}" 2>&1)
   rc=$?

   # Determine pass/fail from bash-spec SUMMARY.
   pass_count=$(echo "$out" | grep -oE "[0-9]+ PASSED" | tail -1 | grep -oE "[0-9]+")
   fail_count=$(echo "$out" | grep -oE "[0-9]+ FAILED" | tail -1 | grep -oE "[0-9]+")
   if [[ -z "$pass_count" && -z "$fail_count" ]]; then
     pass_count=0
     fail_count=$((rc == 0 ? 0 : 1))
   fi

   pass_n=${pass_count:-0}
   fail_n=${fail_count:-0}
   total_pass_assertions=$((total_pass_assertions + pass_n))
   total_fail_assertions=$((total_fail_assertions + fail_n))

   if [[ -z "$fail_count" || "$fail_count" == "0" ]] && [[ $rc -eq 0 ]]; then
     status=pass
     passes=$((passes + 1))
   else
     status=fail
     fails=$((fails + 1))
     FAILED_SPECS+=("$rel_path")
   fi

   index_line "$status" "$rel_path" "$rc" "${pass_count:-0}" "${fail_count:-0}"

   # Per-suite banners. Each suite's WARNINGS appear after the
   # suite's index line
   if ${VERBOSE:-false}; then
      echo "$out"
   else
      loud "$out" | banner_filter
   fi
done

total_assertions=$((total_pass_assertions + total_fail_assertions))

echo
echo "═══════════════════════════════════════════"
if [[ "$total" -eq 1 ]]; then
  printf "  Ran 1 spec:  ${_green}%d pass${_reset}, ${_red}%d fail${_reset}  (%d/%d)\n" "$passes" "$fails" "$total_pass_assertions" "$total_assertions"
else
  printf "  Ran %d specs: ${_green}%d pass${_reset}, ${_red}%d fail${_reset}  (%d/%d)\n" "$total" "$passes" "$fails" "$total_pass_assertions" "$total_assertions"
fi
echo "═══════════════════════════════════════════"

if [[ ${#FAILED_SPECS[@]} -gt 0 ]]; then
  echo
  echo "Failed:"
  printf "  %s\n" "${FAILED_SPECS[@]}"
fi

exit $fails
