---
"@1001/ipfs-server": patch
---

Fix WebUI pinning broken by the Kubo 0.41 upgrade

Since Kubo 0.41, `/webui` no longer redirects straight to `/ipfs/<cid>` but to `/webui/`, which returns a 503 when the WebUI content is not local (we run with `Gateway.NoFetch=true`). The init script's wget-based redirect parsing therefore found no CID and the WebUI was never pinned, leaving `admin.ipfs.1001.digital/webui` broken after deploys. The script now issues a raw request via `nc`, extracting the CID from the redirect headers or the 503 error body, whichever is present.
