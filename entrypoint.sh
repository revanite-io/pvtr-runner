#!/bin/sh

# entrypoint.sh - Dynamic configuration script for privateer

# Check that all required environment variables are provided
missing_vars=false
RESULTS_SRC_DIR="$GITHUB_WORKSPACE/evaluation_results/baseline-scanner"

mkdir -p $RESULTS_SRC_DIR

if [ -z "$INPUT_GH_TOKEN" ]; then
    echo "Error: GH_TOKEN environment variable is required to make API calls, but not set"
    missing_vars=true
fi

if [ -z "$INPUT_REPO_OWNER" ]; then
    echo "Error: REPO_OWNER environment variable is required but not set"
    missing_vars=true
fi

if [ -z "$INPUT_REPO_NAME" ]; then
    echo "Error: REPO_NAME environment variable is required but not set"
    missing_vars=true
fi

if [ "$missing_vars" = true ]; then
    exit 1
fi

echo "INPUT_GH_TOKEN: $INPUT_GH_TOKEN"
echo "GITHUB_REPOSITORY_OWNER: $INPUT_REPO_OWNER"
echo "GITHUB_PATH: $INPUT_REPO_NAME"

sed -i "s/{{ INPUT_GH_TOKEN }}/$INPUT_GH_TOKEN/g" /pvtr-config.yml
sed -i "s/{{ GITHUB_REPOSITORY_OWNER }}/$INPUT_REPO_OWNER/g" /pvtr-config.yml
sed -i "s/{{ GITHUB_REPOSITORY }}/$INPUT_REPO_NAME/g" /pvtr-config.yml

cat /pvtr-config.yml

/bin/privateer list -c /pvtr-config.yml -b /bin/pvtr-plugins

# Execute the main privateer command with all provided arguments
/bin/privateer run -b /bin/pvtr-plugins -c /pvtr-config.yml
status=$?

SARIF_PATH="$RESULTS_SRC_DIR/baseline-scanner.sarif"

# Copy SARIF file to GitHub workspace
if [ -f "$SARIF_PATH" ]; then
    echo "sarif_file="$SARIF_PATH"" >> "$GITHUB_OUTPUT"
    echo "SARIF file copied to: $SARIF_PATH"
else
    echo "SARIF file not found at: $SARIF_PATH"
    echo "evaluation_results:"
    find "$RESULTS_SRC_DIR" -type f 2>/dev/null || echo "No evaluation results directory found"
fi

exit $status
