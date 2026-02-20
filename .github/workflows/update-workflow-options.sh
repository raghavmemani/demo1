#!/bin/bash
set -e
set -x   # 🔍 FULL DEBUG MODE

POM_FILE="pom.xml"
WORKFLOW_FILE=".github/workflows/test-and-deploy.yml"
OUTPUT_FILE="artifact-list.txt"

echo "===== RUNNING SCRIPT ====="
echo "PWD: $(pwd)"
ls -la

# --------------------------
# Validate files
# --------------------------
if [ ! -f "$POM_FILE" ]; then
  echo "❌ pom.xml NOT FOUND"
  exit 1
fi

if [ ! -f "$WORKFLOW_FILE" ]; then
  echo "❌ Workflow file NOT FOUND"
  exit 1
fi

# --------------------------
# Install yq if missing
# --------------------------
if ! command -v yq >/dev/null 2>&1; then
  echo "📦 Installing yq..."
  sudo wget -qO /usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64
  sudo chmod +x /usr/local/bin/yq
fi

yq --version

# --------------------------
# Extract artifactIds
# --------------------------
echo "🔍 Extracting artifactIds from pom.xml..."

ARTIFACTS=$(grep -oP '(?<=<artifactId>).*?(?=</artifactId>)' "$POM_FILE" \
  | sort -u)

if [ -z "$ARTIFACTS" ]; then
  echo "❌ No artifactIds found"
  exit 1
fi

echo "📦 Extracted artifacts:"
echo "$ARTIFACTS"

echo "$ARTIFACTS" > "$OUTPUT_FILE"

# --------------------------
# Convert artifacts → YAML array
# --------------------------
YAML_ARRAY=$(printf "%s\n" "$ARTIFACTS" | yq -R . | yq -s .)

echo "🧾 YAML array:"
echo "$YAML_ARRAY"

# --------------------------
# Update workflow using yq
# --------------------------
echo "✏️ Updating workflow file using yq..."

yq eval \
  ".on.workflow_dispatch.inputs.artifact.options = $YAML_ARRAY" \
  -i "$WORKFLOW_FILE"

# --------------------------
# Final verification
# --------------------------
echo "✅ Workflow updated successfully"
echo "===== UPDATED OPTIONS ====="
yq '.on.workflow_dispatch.inputs.artifact.options' "$WORKFLOW_FILE"
