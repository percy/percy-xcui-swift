#!/usr/bin/env bash
#
# Runs the PercyXcui host unit-test suite (Swift Testing) with code coverage,
# then enforces a minimum line-coverage threshold via llvm-cov.
#
# Why this exists
#   The shipped SDK targets iOS, but its pure logic (device mapping, JSON
#   building, CLI wrapper HTTP, logging, options/errors) is exercised on the
#   macOS host through `#if canImport(UIKit)` fallbacks. Lines that genuinely
#   require the iOS runtime (the screenshot-capture pipeline in
#   GenericProvider / ScreenshotController) cannot run on the host and are
#   covered by the simulator XCUITests instead. The host floor is therefore
#   below 100% by design; see COVERAGE_FLOOR below.
#
# Toolchain handling
#   Swift Testing ships in the toolchain. On a runner WITHOUT full Xcode
#   (Command Line Tools only) the Testing.framework / interop dylib are not on
#   the default search path, so we add them explicitly and pin an rpath. When
#   full Xcode is present `swift test` finds them natively and no extra flags
#   are needed.
#
# Usage: Scripts/coverage.sh [floor_percent]
set -euo pipefail

cd "$(dirname "$0")/.."

# Minimum acceptable host line coverage. The achieved host figure is ~95.7%;
# the remaining lines are the iOS-runtime screenshot pipeline (simulator-only)
# plus two defensive branches Foundation cannot trigger without aborting. The
# floor is set to the honest host maximum.
COVERAGE_FLOOR="${1:-95.0}"

EXTRA_FLAGS=()
if ! xcrun --find xctest >/dev/null 2>&1; then
  # Command Line Tools only: locate Swift Testing's framework + interop dylib.
  DEV_DIR="$(xcode-select -p)"
  FW_DIR="$DEV_DIR/Library/Developer/Frameworks"
  LIB_DIR="$DEV_DIR/Library/Developer/usr/lib"
  if [[ -d "$FW_DIR" ]]; then
    echo "Command Line Tools detected; adding Swift Testing search paths."
    EXTRA_FLAGS+=(
      -Xswiftc -F -Xswiftc "$FW_DIR"
      -Xlinker -F -Xlinker "$FW_DIR"
      -Xlinker -rpath -Xlinker "$FW_DIR"
      -Xlinker -rpath -Xlinker "$LIB_DIR"
    )
  fi
fi

echo "Running unit tests with code coverage..."
# --no-parallel: the suites share process-global state (a registered
# URLProtocol stub and AppPercy's static config), so cross-suite parallelism
# must be disabled for deterministic results.
# Use ${EXTRA_FLAGS[@]+"${EXTRA_FLAGS[@]}"} (not "${EXTRA_FLAGS[@]}") so an empty
# array under `set -u` expands to nothing instead of erroring "unbound variable"
# on macOS bash 3.2 — the full-Xcode CI runner leaves EXTRA_FLAGS empty.
swift test --enable-code-coverage --no-parallel ${EXTRA_FLAGS[@]+"${EXTRA_FLAGS[@]}"}

BIN_PATH="$(swift build --show-bin-path)"
PROFDATA="$BIN_PATH/codecov/default.profdata"

# Resolve the test bundle's executable (name contains spaces).
BUNDLE="$(/usr/bin/find "$BIN_PATH" -maxdepth 1 -name '*.xctest' -print -quit)"
if [[ "$(uname)" == "Darwin" ]]; then
  EXEC="$BUNDLE/Contents/MacOS/$(basename "$BUNDLE" .xctest)"
else
  EXEC="$BUNDLE"
fi

echo ""
echo "Coverage report (source only):"
xcrun llvm-cov report "$EXEC" \
  -instr-profile "$PROFDATA" \
  -ignore-filename-regex='(Tests|\.build)/.*'

PERCENT="$(xcrun llvm-cov export "$EXEC" \
  -instr-profile "$PROFDATA" \
  -ignore-filename-regex='(Tests|\.build)/.*' \
  -summary-only \
  | python3 -c "import sys,json;print(json.load(sys.stdin)['data'][0]['totals']['lines']['percent'])")"

echo ""
printf 'Line coverage: %.2f%% (floor: %s%%)\n' "$PERCENT" "$COVERAGE_FLOOR"

BELOW="$(python3 -c "import sys;print(1 if float('$PERCENT') < float('$COVERAGE_FLOOR') else 0)")"
if [[ "$BELOW" == "1" ]]; then
  echo "FAIL: line coverage is below the floor."
  exit 1
fi

echo "PASS: line coverage meets the floor."
