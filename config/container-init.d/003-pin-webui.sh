#!/bin/sh
set -e

# Pin the IPFS WebUI after the daemon starts.
# Since Kubo 0.41, /webui redirects to /webui/, which either
# redirects to /ipfs/<cid> (content local) or returns a 503
# page naming the CID (content missing with Gateway.NoFetch).
# Use a raw request via nc so the CID is visible in headers
# and body regardless of the status code.
(
  # Wait for the API to be ready
  while ! wget -qO /dev/null --post-data='' http://localhost:5001/api/v0/version 2>/dev/null; do
    sleep 1
  done

  webui_path() {
    printf 'GET %s HTTP/1.0\r\nHost: localhost\r\n\r\n' "$1" \
      | nc 127.0.0.1 5001 \
      | grep -o '/ipfs/[A-Za-z0-9]\{46,\}' | head -1
  }

  # /webui held the CID before Kubo 0.41, /webui/ does since
  WEBUI_PATH=$(webui_path /webui)
  [ -n "$WEBUI_PATH" ] || WEBUI_PATH=$(webui_path /webui/)

  if [ -n "$WEBUI_PATH" ]; then
    echo "Pinning WebUI: $WEBUI_PATH"
    ipfs pin add --progress --name ipfs-webui "$WEBUI_PATH"
  else
    echo "Warning: could not detect WebUI CID" >&2
  fi
) &
