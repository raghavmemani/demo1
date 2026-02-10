name: Update Workflow Options

on:
  schedule:
    - cron: "*/1 * * * *"   # every 1 minute
  workflow_dispatch:

permissions:
  contents: write
  workflows: write

jobs:
  update:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout repo
        uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Make script executable
        run: chmod +x .github/workflows/update-workflow-options.sh

      - name: Run updater
        run: .github/workflows/update-workflow-options.sh

      - name: Commit changes
        uses: stefanzweifel/git-auto-commit-action@v5
        with:
          commit_message: "chore: update artifact dropdown options"
          file_pattern: |
            .github/workflows/test-and-deploy.yml
            artifact-list.txt
