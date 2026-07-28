---
"@1001/ipfs-server": minor
---

Upgrade Kubo from v0.41.0 to v0.42.0

This picks up the upstream fix for pin operations hanging during reprovide
cycles under selective `Provide.Strategy` modes, bounded daemon shutdowns, and
the stronger `ipfs diag healthy` container health check. The deployment keeps
Kubo's new anonymous telemetry disabled by default and pins Kamal 2.10.1 for
compatibility with the production proxy.
