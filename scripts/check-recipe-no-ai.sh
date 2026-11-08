#!/usr/bin/env bash
# Fails if the LMS recipe references the AI modules, AI providers, or AI answer activities.
# The demo kit ships AI answers; the recipe must apply to sites without them.

set -euo pipefail
cd "$(dirname "$0")/.."

PATTERN='ai_providers_api|lms_ai|pluginId: ai_answer|evaluation_prompt|source_of_truth'

if grep -rnE "$PATTERN" recipes/lms_demo_kit; then
  echo "Recipe contains AI config or content (matches above). Remove it before committing." >&2
  exit 1
fi

echo "Recipe is AI-free."
