### My CLI Action

#### Description
My CLI Action is a robust Docker-based wrapper to execute your CLI tool within a consistent, minimal, and secure environment. It forwards arguments to your CLI and exposes the path to generated artifacts for downstream steps.

#### Inputs
- **cli-arguments**: Arguments to pass to the CLI tool. Optional. Default: empty string.

#### Outputs
- **cli-output-path**: Path to the directory containing generated artifacts produced by your CLI.

#### Example Workflow Usage
```yaml
name: Run My CLI
on:
  push:
    branches: [ main ]

jobs:
  run-cli:
    runs-on: ubuntu-latest
    steps:
      - name: Check out repository
        uses: actions/checkout@v4

      - name: Run My CLI Action
        id: run-cli
        uses: your-org/my-cli-action@v1
        with:
          cli-arguments: "--foo bar --output-format json"

      - name: Upload CLI artifacts
        uses: actions/upload-artifact@v4
        with:
          name: cli-output
          path: ${{ steps.run-cli.outputs.cli-output-path }}
```

Notes:
- Replace `your-org/my-cli-action@v1` with the correct owner/repo and ref for this action.
- Ensure `entrypoint.sh` contains the concrete command to run your CLI and writes outputs into the directory indicated by `cli-output-path`.


