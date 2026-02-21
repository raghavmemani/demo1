#!/usr/bin/env bash
set -euo pipefail

WORKFLOW_FILE=".github/workflows/test-and-deploy.yml"
TMP_OPTIONS=".github/workflows/.artifact-options.yml"

echo "🔍 Extracting artifactId values from pom.xml..."

# Extract artifactIds safely
grep -oP '(?<=<artifactId>)[^<]+' pom.xml \
  | grep -vE '^(parent|spring-boot|spring-boot-starter.*)$' \
  | sort -u \
  | sed 's/^/- /' > "$TMP_OPTIONS"

if [ ! -s "$TMP_OPTIONS" ]; then
  echo "❌ No artifactIds found"
  exit 1
fi

echo "📦 Generated options:"
cat "$TMP_OPTIONS"

echo "✏️ Updating workflow dropdown using yq..."

yq eval '
.on.workflow_dispatch.inputs.artifact.options = load("'"$TMP_OPTIONS"'")
' -i "$WORKFLOW_FILE"

echo "✅ Workflow updated successfully"