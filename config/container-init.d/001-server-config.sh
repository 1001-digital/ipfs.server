#!/bin/sh
set -e

# Configure the IPFS gateway to listen on all interfaces
# so Kamal proxy can reach it for SSL termination
ipfs config Addresses.Gateway /ip4/0.0.0.0/tcp/8080

# Keep the API bound to localhost only (security)
ipfs config Addresses.API /ip4/127.0.0.1/tcp/5001

# Only serve content that is already pinned/cached locally
ipfs config --bool Gateway.NoFetch "${GATEWAY_NO_FETCH:-true}"

# Enable directory listings and other deserialized responses
ipfs config --bool Gateway.DeserializedResponses "${GATEWAY_DESERIALIZED_RESPONSES:-true}"

# Allow the admin WebUI and standard origins to access the RPC API
ORIGINS='["https://'"${IPFS_ADMIN_HOST}"'", "http://localhost:3000", "http://127.0.0.1:5001", "https://webui.ipfs.io"]'
ipfs config --json API.HTTPHeaders.Access-Control-Allow-Origin "$ORIGINS"
ipfs config --json API.HTTPHeaders.Access-Control-Allow-Methods '["PUT", "POST"]'

# Keep IPNS records alive for 2 weeks to survive extended downtime
ipfs config Ipns.RecordLifetime "${IPNS_RECORD_LIFETIME:-336h}"

# Maximum disk space for the IPFS datastore
ipfs config Datastore.StorageMax "${STORAGE_MAX:-20GB}"

# Peer connection limits
ipfs config --json Swarm.ConnMgr.HighWater "${CONN_MGR_HIGH_WATER:-96}"
ipfs config --json Swarm.ConnMgr.LowWater "${CONN_MGR_LOW_WATER:-32}"

# Resource manager limits (memory & file descriptors for libp2p)
ipfs config Swarm.ResourceMgr.MaxMemory "${RESOURCE_MGR_MAX_MEMORY:-4GB}"
ipfs config --json Swarm.ResourceMgr.MaxFileDescriptors "${RESOURCE_MGR_MAX_FILE_DESCRIPTORS:-4096}"
