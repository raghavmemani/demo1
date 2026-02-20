#!/usr/bin/env bash
set -e

ARTIFACT="$1"
LIST_FILE="artifact-list.txt"

if [ -z "$ARTIFACT" ]; then
  echo "❌ No artifactId provided"
  exit 1
fi

if [ ! -f "$LIST_FILE" ]; then
  echo "❌ artifact-list.txt not found"
  exit 1
fi

if grep -qx "$ARTIFACT" "$LIST_FILE"; then
  echo "✅ Valid artifactId: $ARTIFACT"
else
  echo "❌ Invalid artifactId: $ARTIFACT"
  echo "Allowed values:"
  cat "$LIST_FILE"
  exit 1
fi
