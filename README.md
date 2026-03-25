# IPFS Server

A production-ready IPFS node built on [Kubo](https://github.com/ipfs/kubo) with Caddy as a reverse proxy for authentication, deployed via [Kamal](https://kamal-deploy.org/).

## Architecture

A single Docker image bundles two services:

- **Kubo v0.40.0** — IPFS daemon providing content pinning, IPNS publishing, and a public gateway
- **Caddy** — reverse proxy adding basic auth to the admin API and handling large uploads

```
                        ┌─────────────────────────────────┐
                        │         Docker Container        │
                        │                                 │
  ipfs.1001.digital ───▶│  :8080  Kubo Gateway (public)   │
                        │         read-only, pinned only  │
                        │                                 │
admin.ipfs.1001.digital▶│  :5080  Caddy ──▶ :5001 Kubo API│
                        │         basic auth              │
                        │                                 │
          swarm ◀──────▶│  :4001  Kubo Swarm (P2P)        │
                        └─────────────────────────────────┘
```

## Features

- **Public gateway** serves only locally pinned content (`Gateway.NoFetch = true`)
- **Admin API** protected by basic auth via Caddy — supports the full Kubo HTTP API
- **Unlimited upload size** with streaming support for large files
- **IPNS records** with a 14-day lifetime to survive extended downtime
- **Web UI** automatically pinned on startup for admin access
- **Persistent storage** via a Docker volume (`ipfs_data`)

## Prerequisites

- Docker
- [Kamal](https://kamal-deploy.org/) (`gem install kamal`)
- pnpm
- A server with ports 4001, 8080, and 5080 available

## Setup

1. Copy the environment template and fill in your values:

```sh
cp .env.production.example .env.production
```

| Variable | Description |
|---|---|
| `DOCKER_REGISTRY_USERNAME` | Docker Hub username |
| `DEPLOY_HOST` | Target server IP or hostname |
| `KAMAL_REGISTRY_PASSWORD` | Docker Hub access token |
| `IPFS_HOST` | Public gateway domain |
| `IPFS_ADMIN_HOST` | Admin API domain |
| `ADMIN_PASSWORD_HASH` | Bcrypt-hashed admin password |

2. Generate a bcrypt password hash for admin access:

```sh
caddy hash-password --plaintext 'your-password'
```

3. Install dependencies and run initial setup:

```sh
pnpm install
pnpm kamal:setup
```

### Node Configuration

These optional environment variables can be set in `.env.production` to tune node behavior:

| Variable | Default | Description |
|---|---|---|
| `GATEWAY_NO_FETCH` | `true` | When `true`, only serves pinned/cached content. Set to `false` to fetch from the IPFS network on demand. |
| `GATEWAY_DESERIALIZED_RESPONSES` | `true` | Enables directory listings and deserialized responses. |
| `IPNS_RECORD_LIFETIME` | `336h` | How long IPNS records remain valid. Default is 14 days. |
| `STORAGE_MAX` | `20GB` | Maximum disk space for the IPFS datastore. |
| `CONN_MGR_HIGH_WATER` | `96` | Maximum number of peer connections to maintain. |
| `CONN_MGR_LOW_WATER` | `32` | Peer connections to trim down to when `HighWater` is reached. |
| `CONTAINER_CPUS` | `2` | CPU cores available to the Docker container. |
| `CONTAINER_MEMORY` | `6G` | Maximum memory for the Docker container. |
| `RESOURCE_MGR_MAX_MEMORY` | `4GB` | Maximum memory for the libp2p resource manager. Should be less than `CONTAINER_MEMORY` to leave headroom for Caddy, GC, and other overhead. |
| `RESOURCE_MGR_MAX_FILE_DESCRIPTORS` | `4096` | Maximum file descriptors for the libp2p resource manager. |

## Deployment

```sh
pnpm kamal:deploy
```

This builds the Docker image, pushes it to Docker Hub, and deploys to your server. Kamal handles zero-downtime deploys, health checks, and TLS.

## Usage

### Public Gateway

Access pinned content over HTTP:

```
https://ipfs.1001.digital/ipfs/<CID>
https://ipfs.1001.digital/ipns/<name>
```

Only locally pinned content is served — the gateway does not fetch from the network.

### Admin API

The full [Kubo RPC API](https://docs.ipfs.tech/reference/kubo/rpc/) is available behind basic auth:

```sh
# Pin content
curl -u admin:<password> -X POST \
  "https://admin.ipfs.1001.digital/api/v0/pin/add?arg=<CID>"

# Add a file
curl -u admin:<password> -X POST -F file=@myfile.txt \
  "https://admin.ipfs.1001.digital/api/v0/add"

# Publish an IPNS record
curl -u admin:<password> -X POST \
  "https://admin.ipfs.1001.digital/api/v0/name/publish?arg=<CID>"
```

### Shell Access

```sh
pnpm kamal:sh
```

## Project Structure

```
├── Dockerfile                      # Multi-stage: Caddy + Kubo
├── config/
│   ├── Caddyfile                   # Reverse proxy config
│   ├── deploy.yml                  # Kamal deployment manifest
│   └── container-init.d/
│       ├── 001-server-config.sh    # IPFS daemon configuration
│       ├── 002-admin-proxy.sh      # Start Caddy
│       └── 003-pin-webui.sh        # Pin Web UI on startup
├── .kamal/
│   └── hooks/
│       ├── pre-deploy              # Stop containers to free ports
│       └── post-deploy             # Register admin proxy
├── package.json                    # Kamal deployment scripts
└── .env.production.example         # Environment template
```

## License

MIT
