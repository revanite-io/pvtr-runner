#!/bin/sh

# entrypoint.sh - Dynamic configuration script for privateer

# Check that all required environment variables are provided
missing_vars=false

if [ -z "$INPUT_GH_TOKEN" ]; then
    echo "Error: GH_TOKEN environment variable is required to make API calls, but not set"
    missing_vars=true
fi

if [ -z "$GITHUB_REPOSITORY_OWNER" ]; then
    echo "Error: REPO_OWNER environment variable is required but not set"
    missing_vars=true
fi

if [ -z "$GITHUB_REPOSITORY" ]; then
    echo "Error: REPO_NAME environment variable is required but not set"
    missing_vars=true
fi

if [ "$missing_vars" = true ]; then
    exit 1
fi

# Extract repo name from GITHUB_REPOSITORY (format: owner/repo)
REPO_NAME=$(echo "$GITHUB_REPOSITORY" | cut -d'/' -f2)

# Update config.yml with provided environment variables
sed -i "s/{{ gh_token }}/$INPUT_GH_TOKEN/g" config.yml
sed -i "s/{{ REPO_OWNER }}/$GITHUB_REPOSITORY_OWNER/g" config.yml
sed -i "s/{{ REPO_NAME }}/$REPO_NAME/g" config.yml

# Execute the main privateer command with all provided arguments
exec /bin/privateer run -b /bin/pvtr-plugins
