#!/bin/sh

# entrypoint.sh - Dynamic configuration script for privateer

# Check that all required environment variables are provided
missing_vars=false
RESULTS_SRC_DIR="evaluation_results"
RESULTS_DEST_DIR="$GITHUB_WORKSPACE/evaluation_results"

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

ls -la $RESULTS_SRC_DIR

# After run, export evaluation results to the GitHub workspace if present

if [ -d "$RESULTS_SRC_DIR" ]; then
    mkdir -p "$RESULTS_DEST_DIR"
    cp -r "$RESULTS_SRC_DIR/"* "$RESULTS_DEST_DIR" 2>/dev/null || true
    if [ -n "$GITHUB_OUTPUT" ]; then
        echo "results_dir=$RESULTS_SRC_DIR" >> "$GITHUB_OUTPUT"
    fi
    echo "Exported evaluation results to: $RESULTS_DEST_DIR"
else
    echo "Something went wrong, no evaluation results were found"
fi

exit $status
