#!/bin/bash
set -e
set -x   # 🔍 FULL DEBUG MODE

POM_FILE="pom.xml"
WORKFLOW_FILE=".github/workflows/test-and-deploy.yml"
OUTPUT_FILE="artifact-list.txt"

START_MARKER="# AUTO-GENERATED-OPTIONS-START"
END_MARKER="# AUTO-GENERATED-OPTIONS-END"

echo "===== RUNNING SCRIPT ====="
echo "PWD: $(pwd)"
echo "Files in repo:"
ls -la

echo "🔍 Extracting artifactIds from pom.xml..."

if [ ! -f "$POM_FILE" ]; then
  echo "❌ pom.xml NOT FOUND"
  exit 1
fi

ARTIFACTS=$(grep -oP '(?<=<artifactId>).*?(?=</artifactId>)' "$POM_FILE" | sort -u)

echo "📦 Extracted artifacts:"
echo "$ARTIFACTS"

if [ -z "$ARTIFACTS" ]; then
  echo "❌ No artifactIds found"
  exit 1
fi

echo "$ARTIFACTS" > "$OUTPUT_FILE"

echo "📄 artifact-list.txt written:"
cat "$OUTPUT_FILE"

if ! grep -q "$START_MARKER" "$WORKFLOW_FILE"; then
  echo "❌ START MARKER NOT FOUND in workflow"
  exit 1
fi

if ! grep -q "$END_MARKER" "$WORKFLOW_FILE"; then
  echo "❌ END MARKER NOT FOUND in workflow"
  exit 1
fi

echo "✏️ Updating workflow file..."

TMP_FILE=$(mktemp)

awk -v start="$START_MARKER" -v end="$END_MARKER" -v items="$ARTIFACTS" '
{
  print
  if ($0 ~ start) {
    split(items, arr, "\n")
    for (i in arr) {
      printf "          - %s\n", arr[i]
    }
    skip=1
  }
  if ($0 ~ end) skip=0
  next
}
' "$WORKFLOW_FILE" > "$TMP_FILE"

mv "$TMP_FILE" "$WORKFLOW_FILE"

echo "✅ Updated workflow options"
echo "===== FINAL WORKFLOW SNIPPET ====="
sed -n '/AUTO-GENERATED-OPTIONS-START/,/AUTO-GENERATED-OPTIONS-END/p' "$WORKFLOW_FILE"
