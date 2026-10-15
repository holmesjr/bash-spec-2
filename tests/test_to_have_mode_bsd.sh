#!/usr/bin/env bash

# Regression test for the to_have_mode BSD stat parser.
#
# On macOS, `stat <file>` emits multi-line output with "File:" and
# "Size:" headers. The previous `cut -f 3 -d ' '` extraction picked
# up "File:" instead of the mode. This test pins the extraction to
# the Access: line.
#
# Skipped on Linux (where the test is already covered by test_bash-spec.sh
# with the GNU stat -c %A path).

DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
. "$DIR/../bash-spec.sh"

os="$(uname -s)"
if [[ "$os" == Linux ]]; then
  describe "to_have_mode BSD parser" "$(

    it "is skipped on Linux" "$(
      : # the GNU stat -c %A path is exercised by test_bash-spec.sh
    )"

  )"
  exit 0
fi

describe "to_have_mode BSD parser" "$(

  context "When a file is chmod'd to a specific mode" "$(

    touch "$DIR/.mode_test_$$"
    chmod u=rw,g=r,o=x "$DIR/.mode_test_$$"
    target="$DIR/.mode_test_$$"

    it "extracts the symbolic mode from the Access line" "$(
      expect "$target" to_have_mode -rw-r----x
    )"

    context "When the file mode is different" "$(

      result="$(
        expect "$target" to_have_mode -rwxrwxrwx
      )"

      it "Reports the actual mode in the failure message" "$(
        # Actual should be the real mode, not the BSD stat header word.
        expect "$result" to_match "actual: '-rw-r----x'"
      )"
    )"

    rm -f "$target"
  )"
)"
