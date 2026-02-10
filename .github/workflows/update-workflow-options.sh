#!/bin/bash

POM_FILE="pom.xml"
WORKFLOW_FILE=".github/workflows/main.yml"
TARGET_ARTIFACT="spring-boot-configuration-processor"

# 1. Extract artifact list
ARTIFACTS=$(awk '
  /<artifactId>'"$TARGET_ARTIFACT"'<\/artifactId>/ {found=1; next}
  found && /<artifactId>/ {
    gsub(/.*<artifactId>|<\/artifactId>.*/, "", $0)
    print "          - " $0
  }
' "$POM_FILE" | sort -u)

# 2. Replace OPTIONS block in workflow
awk -v list="$ARTIFACTS" '
  BEGIN {inside=0}
  /# AUTO-GENERATED-OPTIONS-START/ {print; print list; inside=1; next}
  /# AUTO-GENERATED-OPTIONS-END/   {inside=0}
  !inside {print}
' "$WORKFLOW_FILE" > temp.yml

mv temp.yml "$WORKFLOW_FILE"

echo "Workflow options updated"
