#!/bin/sh
set -e

# Pin the IPFS WebUI after the daemon starts.
# Extracts the CID from the API redirect so it stays
# correct across Kubo version upgrades.
(
  # Wait for the API to be ready
  while ! wget -qO /dev/null http://localhost:5001/api/v0/version 2>/dev/null; do
    sleep 1
  done

  # Extract the WebUI CID from the /webui redirect
  WEBUI_PATH=$(wget -S --spider http://localhost:5001/webui 2>&1 | grep -oi '/ipfs/[a-z2-7]*' | head -1)

  if [ -n "$WEBUI_PATH" ]; then
    echo "Pinning WebUI: $WEBUI_PATH"
    ipfs pin add --progress "$WEBUI_PATH"
  else
    echo "Warning: could not detect WebUI CID" >&2
  fi
) &
