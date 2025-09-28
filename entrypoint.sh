#!/bin/sh

# entrypoint.sh - Dynamic configuration script for privateer

# Check that all required environment variables are provided
missing_vars=false
RESULTS_SRC_DIR="evaluation_results"
RESULTS_DEST_DIR="evaluation_results/baseline-scanner"

mkdir -p $RESULTS_DEST_DIR

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

echo "=== After privateer run ==="
echo "Current working directory: $(pwd)"
echo "Contents of evaluation_results:"
ls -la evaluation_results/ 2>/dev/null || echo "evaluation_results directory not found"
echo "Contents of baseline-scanner directory:"
ls -la $RESULTS_DEST_DIR 2>/dev/null || echo "baseline-scanner directory not found"

SARIF_PATH="$RESULTS_DEST_DIR/baseline-scanner.sarif"

# Validate and fix SARIF file for GitHub Actions
if [ -f "$SARIF_PATH" ]; then
    echo "Validating SARIF file: $SARIF_PATH"
    
    # Check if the file is valid JSON
    if ! jq empty "$SARIF_PATH" 2>/dev/null; then
        echo "Error: Invalid JSON in SARIF file"
        exit 1
    fi
    
    # Check for empty runs array - this causes the "1 item required; only 0 were supplied" error
    RUNS_COUNT=$(jq '.runs | length' "$SARIF_PATH")
    echo "Number of runs in SARIF: $RUNS_COUNT"
    
    if [ "$RUNS_COUNT" -eq 0 ]; then
        echo "Warning: SARIF file has empty runs array. Creating minimal valid SARIF file..."
        
        # Create a valid SARIF with empty results but proper structure
        FIXED_SARIF_PATH="${SARIF_PATH%.sarif}-fixed.sarif"
        jq '.runs = [{
            "tool": {
                "driver": {
                    "name": "OSPS Baseline Scanner",
                    "version": "1.0.0",
                    "informationUri": "https://github.com/revanite-io/pvtr-runner",
                    "rules": []
                }
            },
            "results": [],
            "columnKind": "utf16CodeUnits"
        }]' "$SARIF_PATH" > "$FIXED_SARIF_PATH"
        
        echo "Fixed SARIF file created: $FIXED_SARIF_PATH"
        echo "sarif_file=$FIXED_SARIF_PATH" >> "$GITHUB_OUTPUT"
    else
        echo "SARIF file appears valid for GitHub CodeQL upload"
        echo "sarif_file=$SARIF_PATH" >> "$GITHUB_OUTPUT"
    fi
else
    echo "SARIF file not found at: $SARIF_PATH"
    echo "evaluation_results:"
    find "$RESULTS_DEST_DIR" -type f 2>/dev/null || echo "No evaluation results directory found"
fi

exit $status
