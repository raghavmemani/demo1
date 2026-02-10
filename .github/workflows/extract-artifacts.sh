#!/usr/bin/env bash
set -e

POM_FILE="pom.xml"
OUTPUT_FILE="artifact-list.txt"

echo "🔍 Extracting artifactIds from pom.xml"

if [ ! -f "$POM_FILE" ]; then
  echo "❌ pom.xml not found"
  exit 1
fi

ARTIFACTS=$(grep -oP '(?<=<artifactId>)[^<]+' "$POM_FILE" | sort -u)

if [ -z "$ARTIFACTS" ]; then
  echo "❌ No artifactIds found"
  exit 1
fi

echo "$ARTIFACTS" > "$OUTPUT_FILE"

echo "✅ artifact-list.txt updated"
cat "$OUTPUT_FILE"
