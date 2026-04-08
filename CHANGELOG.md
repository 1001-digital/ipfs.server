# @1001/ipfs-server

## 1.4.0

### Minor Changes

- [`8e8e2a1`](https://github.com/1001-digital/ipfs.server/commit/8e8e2a100b01476a34c497c90dd4f23e82e13e0b) Thanks [@jwahdatehagh](https://github.com/jwahdatehagh)! - Add upload script for files and directories

  Upload files or entire directories to the IPFS node's MFS via `pnpm upload`. Supports optional pinning (`--pin`) and custom MFS paths (`--mfs-path`). Runs natively on Node 24 with no build tooling required.

  ```sh
  # Upload a directory
  pnpm upload ./dist

  # Upload a single file
  pnpm upload ./image.png

  # Pin the content after uploading
  pnpm upload ./dist --pin

  # Specify a custom MFS path (defaults to /<name>)
  pnpm upload ./dist --mfs-path /my-site
  ```

## 1.3.0

### Minor Changes

- [`769a50f`](https://github.com/1001-digital/ipfs.server/commit/769a50fa77f24792553f480a9cfc1916621af7b0) Thanks [@jwahdatehagh](https://github.com/jwahdatehagh)! - Enable garbage collection by default

## 1.2.0

### Minor Changes

- [`27a9ec0`](https://github.com/1001-digital/ipfs.server/commit/27a9ec0a62635993e4a9d58a0a56c039f554844b) Thanks [@jwahdatehagh](https://github.com/jwahdatehagh)! - Add configurable storage volume via `IPFS_VOLUME` environment variable

  - The IPFS data volume can now be configured via `IPFS_VOLUME` env var, defaulting to the named Docker volume `ipfs_data`
  - Supports host path bind mounts (e.g. `/mnt/ipfs/ipfs_data`) for custom storage locations

## 1.1.0

### Minor Changes

- [`c924671`](https://github.com/1001-digital/ipfs.server/commit/c9246713c86d9e92029f74fddb6ca8ea878787d9) Thanks [@jwahdatehagh](https://github.com/jwahdatehagh)! - Add configurable resource limits for CPU, memory, and file descriptors

  - Container-level limits (`CONTAINER_CPUS`, `CONTAINER_MEMORY`) are now configurable via environment variables (defaults: 2 CPUs, 6G memory)
  - Added Kubo libp2p resource manager limits (`RESOURCE_MGR_MAX_MEMORY`, `RESOURCE_MGR_MAX_FILE_DESCRIPTORS`) with defaults of 4GB and 4096

## 1.0.1

### Patch Changes

- [`96d71e7`](https://github.com/1001-digital/ipfs.server/commit/96d71e7b813f1c721106bd092651f35c39868dbe) Thanks [@jwahdatehagh](https://github.com/jwahdatehagh)! - Increase default storage max from 10GB to 20GB

## 1.0.0

### Major Changes

- [`b2babf4`](https://github.com/1001-digital/ipfs.server/commit/b2babf45b9d20ccc710e82cfa11728d8a3c313b5) Thanks [@jwahdatehagh](https://github.com/jwahdatehagh)! - V1 Release

### Patch Changes

- [`c2317c1`](https://github.com/1001-digital/ipfs.server/commit/c2317c1dc66b8e2eac24f86d17d5dcd80daf4bbc) Thanks [@jwahdatehagh](https://github.com/jwahdatehagh)! - Let users configure kubo config via ENV variables
