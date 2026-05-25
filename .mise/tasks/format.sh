#!/usr/bin/env bash
#MISE description="Format the project"

# Check if $1 is set, if not fallback to the current directory
if [ -z "$1" ]; then
  TARGET_DIR="."
else
  TARGET_DIR="$1"
fi

swiftformat $TARGET_DIR --config .swiftformat