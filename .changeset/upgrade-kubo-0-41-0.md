---
"@1001/ipfs-server": minor
---

Upgrade Kubo to v0.41.0

Bumps the base image from `ipfs/kubo:v0.40.0` to `v0.41.0`. Notable upstream changes: the provider keystore moves to a dedicated datastore under `$IPFS_PATH/provider-keystore/` (migrated automatically on first startup), a fixed DHT data race that previously caused random daemon crashes, faster imports for selective `Provide.Strategy` users, and WebUI v4.12.0. No changes to our config or init scripts are required.
