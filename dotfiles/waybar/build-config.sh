#!/usr/bin/env bash
# Merge all JSON snippets in config.d/ into a single waybar config file

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${SCRIPT_DIR}/config.d"
OUTPUT_FILE="${SCRIPT_DIR}/config"

# Check if config.d exists
if [ ! -d "${CONFIG_DIR}" ]; then
  echo "Error: ${CONFIG_DIR} does not exist"
  exit 1
fi

# Start with an empty JSON object
echo '{}' >"${OUTPUT_FILE}.tmp"

# Merge all JSON files in order (sorted by filename)
for json_file in "${CONFIG_DIR}"/*.json; do
  if [ -f "${json_file}" ]; then
    # Merge the JSON file into the accumulated result
    jq -s '.[0] * .[1]' "${OUTPUT_FILE}.tmp" "${json_file}" >"${OUTPUT_FILE}.tmp2"
    mv "${OUTPUT_FILE}.tmp2" "${OUTPUT_FILE}.tmp"
  fi
done

# Move the final result to the output file
mv "${OUTPUT_FILE}.tmp" "${OUTPUT_FILE}"

echo "✓ Merged config created at ${OUTPUT_FILE}"
