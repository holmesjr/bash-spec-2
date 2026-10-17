#!/usr/bin/env bash
# Plain echo statements showing the four severity patterns
# recognised by the pretty runner's severity filter:
#
#   INFO:  - general progress, always emitted
#   WARN:  - the expression's failure is a warning, not a test
#            failure (the should_succeed after confirms the
#            overall test still passed)
#   WARN:  - emitted after a real failure
#   ERROR: - emitted after a real failure
#
# The runner matches INFO/WARN/ERROR as a prefix, so
# WARN_NETWORK_UNREACHABLE would also be recognised.

DIR="${BASH_SOURCE%/*}"
. "$DIR/../../bash-spec.sh"

describe "severity patterns" "$(

  context "always-emitted info echo" "$(

    it "echoes an info line" "$(
      echo "INFO: starting the demo"
      should_succeed
    )"
  )"

  context "expression-fails, triggers warning AND failure" "$(

    it "echoes a warning before should_succeed, which records the failure" "$(
      echo "EXPECTED##FAIL" 
      [[ "vpn_ok" == "NOPE" ]] || ! echo "WARN: Check the VPN (demo-fail)"
      should_succeed
    )"
  )"

  context "expression-fails, triggers error AND failure" "$(

    it "echoes an error before should_succeed, which records the failure" "$(
      echo "EXPECTED##FAIL"
      [[ "network_ok" == "NOPE" ]] || ! echo "ERROR: Network Down (demo-fail)"
      should_succeed
    )"
  )"
)"
