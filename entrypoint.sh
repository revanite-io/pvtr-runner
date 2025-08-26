#!/bin/sh -l
set -e
set -o pipefail

OUTPUT_DIR="/github/workspace/cli-output"
mkdir -p "$OUTPUT_DIR"

echo "[My CLI Action] Starting execution..."

# ----- BEGIN USER CLI COMMAND -----
# Replace 'my-cli-tool' with your CLI command. The first argument ($1)
# contains the value from the 'cli-arguments' input. Keep it double-quoted
# to prevent word splitting and globbing. Ensure outputs are written to
# "$OUTPUT_DIR" so they are available to subsequent steps.
#
# Example:
# my-cli-tool "$1" > "$OUTPUT_DIR/result.txt"
# ----- END USER CLI COMMAND -----

# Set the action output
if [ -z "${GITHUB_OUTPUT:-}" ]; then
  echo "Warning: GITHUB_OUTPUT is not set. Falling back to legacy ::set-output is not supported."
else
  echo "cli-output-path=$OUTPUT_DIR" >> "$GITHUB_OUTPUT"
fi

echo "[My CLI Action] Completed successfully. Artifacts at: $OUTPUT_DIR"


