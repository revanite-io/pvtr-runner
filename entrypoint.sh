#!/bin/sh

# entrypoint.sh - Dynamic configuration script for privateer

# Check that all required environment variables are provided
missing_vars=false

if [ -z "$ACTIONS_RUNTIME_TOKEN" ]; then
    echo "Error: GH_TOKEN environment variable is required to make API calls, but not set"
    missing_vars=true
fi

if [ -z "$GITHUB_REPOSITORY_OWNER" ]; then
    echo "Error: REPO_OWNER environment variable is required but not set"
    missing_vars=true
fi

if [ -z "$GITHUB_PATH" ]; then
    echo "Error: REPO_NAME environment variable is required but not set"
    missing_vars=true
fi

if [ "$missing_vars" = true ]; then
    exit 1
fi

echo "INPUT_GH_TOKEN: $ACTIONS_RUNTIME_TOKEN"
echo "GITHUB_REPOSITORY_OWNER: $GITHUB_REPOSITORY_OWNER"
echo "GITHUB_PATH: $GITHUB_REPOSITORY"

sed "s/{{ INPUT_GH_TOKEN }}/$ACTIONS_RUNTIME_TOKEN/g" /pvtr-config.yml
sed "s/{{ GITHUB_REPOSITORY_OWNER }}/$GITHUB_REPOSITORY_OWNER/g" /pvtr-config.yml
sed "s/{{ GITHUB_REPOSITORY }}/$GITHUB_REPOSITORY/g" /pvtr-config.yml

# Execute the main privateer command with all provided arguments
exec /bin/privateer run -b /bin/pvtr-plugins -c /pvtr-config.yml
