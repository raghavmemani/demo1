#!/bin/bash
set -e

POM_FILE="pom.xml"
WORKFLOW_FILE=".github/workflows/test-and-deploy.yml"
OUTPUT_FILE="artifact-list.txt"

START_MARKER="# AUTO-GENERATED-OPTIONS-START"
END_MARKER="# AUTO-GENERATED-OPTIONS-END"

echo "🔍 Extracting artifactIds from pom.xml..."

ARTIFACTS=$(grep -oP '(?<=<artifactId>).*?(?=</artifactId>)' "$POM_FILE" \
  | sort -u)

if [ -z "$ARTIFACTS" ]; then
  echo "❌ No artifactIds found"
  exit 1
fi

echo "$ARTIFACTS" > "$OUTPUT_FILE"

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
echo "📄 artifact-list.txt contents:"
cat "$OUTPUT_FILE"
