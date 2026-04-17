---
"@1001/ipfs-server": patch
---

Fix WebUI pin script by using POST for Kubo API health check

The init script that pins the IPFS WebUI was sending GET requests to
`/api/v0/version`, which Kubo rejects with 405 since v0.5.0. This
caused the readiness loop to spin forever, preventing the WebUI from
being pinned. Switch to `--post-data=''` so wget sends a POST.
