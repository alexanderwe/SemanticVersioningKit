#!/usr/bin/env bash
#MISE description="Lint the project"

# Check if $1 is set, if not fallback to the current directory
if [ -z "$1" ]; then
  TARGET_DIR="."
else
  TARGET_DIR="$1"
fi

swiftlint $TARGET_DIR --config .swiftlint.yml