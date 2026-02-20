#!/usr/bin/env bash
set -euo pipefail

WORKFLOW_FILE=".github/workflows/test-and-deploy.yml"
OUTPUT_FILE="artifact-list.txt"

echo "🔍 Extracting artifactId values from pom.xml..."

# Extract artifactIds (ignore parent + duplicates)
ARTIFACTS=$(grep -oP '(?<=<artifactId>)[^<]+' pom.xml \
  | grep -vE '^(parent|spring-boot-starter|spring-boot)$' \
  | sort -u)

if [ -z "$ARTIFACTS" ]; then
  echo "❌ No artifactIds found"
  exit 1
fi

echo "📦 Found artifacts:"
echo "$ARTIFACTS"

# Save plain list (optional but useful)
echo "$ARTIFACTS" > "$OUTPUT_FILE"

# Convert to YAML array
YAML_ARRAY=$(printf '%s\n' "$ARTIFACTS" | yq -R -o=json | yq -p=json -o=yaml)

echo "🧾 YAML array:"
echo "$YAML_ARRAY"

echo "✏️ Updating workflow dropdown using yq..."

yq eval "
.on.workflow_dispatch.inputs.artifact.options = $YAML_ARRAY
" -i "$WORKFLOW_FILE"

echo "✅ Workflow updated successfully"