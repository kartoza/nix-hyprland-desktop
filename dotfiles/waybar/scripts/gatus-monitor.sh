#!/usr/bin/env bash

# Gatus Status Monitor for Waybar
# Monitors Gatus dashboard and displays status with color-coded indicators
# Only changes state after 3 consecutive identical results to avoid flapping

# Configuration
INSTANCE_NAME="${1:-PROD}"  # Instance name (PROD or GSH)

# Set URL based on instance
if [[ "${INSTANCE_NAME}" == "GSH" ]]; then
    GATUS_URL="https://gsh-gatus.do.kartoza.com"
else
    GATUS_URL="https://gatus.do.kartoza.com"
fi

API_ENDPOINT="${GATUS_URL}/api/v1/endpoints/statuses"

# State tracking files
STATE_DIR="/tmp/gatus-monitor"
mkdir -p "${STATE_DIR}"
CURRENT_STATE_FILE="${STATE_DIR}/${INSTANCE_NAME}_current_state"
PENDING_STATE_FILE="${STATE_DIR}/${INSTANCE_NAME}_pending_state"
PENDING_COUNT_FILE="${STATE_DIR}/${INSTANCE_NAME}_pending_count"

# Function to output JSON for Waybar
output_json() {
    local text="$1"
    local tooltip="$2"
    local class="$3"
    local alt="$4"
    
    # Escape newlines and other special characters for JSON  
    tooltip=$(printf '%s' "${tooltip}" | sed 's/\\/\\\\/g; s/"/\\"/g')
    
    echo "{\"text\":\"${text}\",\"tooltip\":\"${tooltip}\",\"class\":\"${class}\",\"alt\":\"${alt}\"}"
}

# Fetch status from Gatus API, ignoring SSL errors
# TODO - install Kartoza CA certs to avoid --insecure
RESPONSE=$(curl -s -f --insecure --max-time 10 "${API_ENDPOINT}" 2>&1)
CURL_EXIT=$?

# Check if curl succeeded
if [[ ${CURL_EXIT} -ne 0 ]]; then
    output_json "⚠" "Failed to connect to Gatus\n${GATUS_URL}\nError: ${RESPONSE}" "error" "error"
    exit 0
fi

# Check if jq is available
if ! command -v jq &> /dev/null; then
    output_json "❓" "jq is required for Gatus monitoring\nPlease install jq" "unknown" "unknown"
    exit 0
fi

# Parse Gatus API response
# The API returns an array of endpoint groups with their status results
# We need to check for: 
# 1. 3 consecutive failures in recent results, OR 
# 2. 3 or more services currently failing

# Count total endpoints
TOTAL_COUNT=$(echo "${RESPONSE}" | jq '[.[] | select(.results != null)] | length')

# Count currently offline services (most recent result shows failure)
CURRENTLY_OFFLINE=$(echo "${RESPONSE}" | jq '[.[] | select(.results != null and .results[0].success == false)] | length')

# Check for services with 3 consecutive failures in their most recent results
# Look at the first 3 results (most recent) for each service
SERVICES_WITH_3_CONSECUTIVE_FAILURES=$(echo "${RESPONSE}" | jq '[.[] | select(.results != null and (.results | length >= 3) and .results[0].success == false and .results[1].success == false and .results[2].success == false)] | length')

if [[ ${TOTAL_COUNT} -eq 0 ]]; then
    output_json "❓" "No endpoints monitored\n${GATUS_URL}" "unknown" "unknown"
    exit 0
fi

# Determine new state based on requirements:
# Report issue only if: 3+ services currently red OR any service has 3 consecutive red results
NEW_STATE=""
NEW_TEXT=""
NEW_TOOLTIP=""

if [[ ${CURRENTLY_OFFLINE} -ge 3 ]] || [[ ${SERVICES_WITH_3_CONSECUTIVE_FAILURES} -gt 0 ]]; then
    # Critical: Either 3+ services offline OR any service has 3 consecutive failures
    NEW_STATE="critical"
    NEW_TEXT="${INSTANCE_NAME}"
    if [[ ${SERVICES_WITH_3_CONSECUTIVE_FAILURES} -gt 0 ]]; then
        NEW_TOOLTIP="Gatus Service Status:\n\n✗ ${SERVICES_WITH_3_CONSECUTIVE_FAILURES} service(s) with 3 consecutive failures\n⚠ ${CURRENTLY_OFFLINE}/${TOTAL_COUNT} services currently offline"
    else
        NEW_TOOLTIP="Gatus Service Status:\n\n✗ ${CURRENTLY_OFFLINE} services currently OFFLINE\n⚠ $((TOTAL_COUNT - CURRENTLY_OFFLINE))/${TOTAL_COUNT} services operational"
    fi
elif [[ ${CURRENTLY_OFFLINE} -gt 0 ]]; then
    # Warning: Some services offline but not critical threshold
    NEW_STATE="warning" 
    NEW_TEXT="${INSTANCE_NAME}"
    NEW_TOOLTIP="Gatus Service Status:\n\n⚠ ${CURRENTLY_OFFLINE} service(s) currently offline\n✓ $((TOTAL_COUNT - CURRENTLY_OFFLINE))/${TOTAL_COUNT} services operational\n(Not critical: < 3 services and no consecutive failures)"
else
    # All good: No services offline
    NEW_STATE="perfect"
    NEW_TEXT="${INSTANCE_NAME}"
    NEW_TOOLTIP="Gatus Service Status:\n\n✓ All ${TOTAL_COUNT} services online"
fi

# Read current displayed state
CURRENT_STATE=$(cat "${CURRENT_STATE_FILE}" 2>/dev/null || echo "")

# If new state matches current state, output current state
if [[ "${NEW_STATE}" == "${CURRENT_STATE}" ]]; then
    # State hasn't changed, reset pending counter
    echo "0" > "${PENDING_COUNT_FILE}"
    echo "" > "${PENDING_STATE_FILE}"
    output_json "${NEW_TEXT}" "${NEW_TOOLTIP}" "${NEW_STATE}" "${NEW_STATE}"
    exit 0
fi

# State is different, check if it's been pending
PENDING_STATE=$(cat "${PENDING_STATE_FILE}" 2>/dev/null || echo "")
PENDING_COUNT=$(cat "${PENDING_COUNT_FILE}" 2>/dev/null || echo "0")

if [[ "${NEW_STATE}" == "${PENDING_STATE}" ]]; then
    # Same pending state, increment counter
    PENDING_COUNT=$((PENDING_COUNT + 1))
    echo "${PENDING_COUNT}" > "${PENDING_COUNT_FILE}"
    
    if [[ ${PENDING_COUNT} -ge 3 ]]; then
        # 3 consecutive identical results, update current state
        echo "${NEW_STATE}" > "${CURRENT_STATE_FILE}"
        echo "0" > "${PENDING_COUNT_FILE}"
        echo "" > "${PENDING_STATE_FILE}"
        output_json "${NEW_TEXT}" "${NEW_TOOLTIP}" "${NEW_STATE}" "${NEW_STATE}"
    else
        # Still pending, show current state with note in tooltip
        CURRENT_TEXT="${INSTANCE_NAME}"
        CURRENT_TOOLTIP=$(cat "${STATE_DIR}/${INSTANCE_NAME}_current_tooltip" 2>/dev/null || echo "${NEW_TOOLTIP}")
        output_json "${CURRENT_TEXT}" "${CURRENT_TOOLTIP}\n\n[Pending state change: ${PENDING_COUNT}/3]" "${CURRENT_STATE}" "${CURRENT_STATE}"
    fi
else
    # Different pending state, reset and start tracking new state
    echo "${NEW_STATE}" > "${PENDING_STATE_FILE}"
    echo "1" > "${PENDING_COUNT_FILE}"
    # Save current tooltip for display
    echo -e "${NEW_TOOLTIP}" > "${STATE_DIR}/${INSTANCE_NAME}_current_tooltip"
    # Show current state while new state is pending
    if [[ -n "${CURRENT_STATE}" ]]; then
        CURRENT_TEXT="${INSTANCE_NAME}"
        CURRENT_TOOLTIP=$(cat "${STATE_DIR}/${INSTANCE_NAME}_current_tooltip" 2>/dev/null || echo "${NEW_TOOLTIP}")
        output_json "${CURRENT_TEXT}" "${CURRENT_TOOLTIP}\n\n[Pending state change: 1/3]" "${CURRENT_STATE}" "${CURRENT_STATE}"
    else
        # No current state, use new state immediately (first run)
        echo "${NEW_STATE}" > "${CURRENT_STATE_FILE}"
        output_json "${NEW_TEXT}" "${NEW_TOOLTIP}" "${NEW_STATE}" "${NEW_STATE}"
    fi
fi
