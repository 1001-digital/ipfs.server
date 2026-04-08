import { create } from "kubo-rpc-client";
import { appendFileSync, readFileSync, readdirSync, statSync } from "node:fs";
import { resolve, dirname, basename, join, posix } from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = dirname(fileURLToPath(import.meta.url));
const rootDir = resolve(__dirname, "..");

// Parse args
const args = process.argv.slice(2);
const targetArg = args.find((a) => !a.startsWith("--"));
if (!targetArg) {
  console.error(
    "Usage: pnpm upload <file-or-directory> [--pin] [--mfs-path /target]"
  );
  process.exit(1);
}

const target = resolve(targetArg);
const isDirectory = statSync(target).isDirectory();
const pin = args.includes("--pin");
const mfsIdx = args.indexOf("--mfs-path");
const mfsPath = mfsIdx !== -1 ? args[mfsIdx + 1] : `/${basename(target)}`;

// Env vars sourced via `set -a && . ./.env.production` in package.json
const host = process.env.IPFS_ADMIN_HOST;
const user = process.env.ADMIN_USER || "admin";
const password = process.env.ADMIN_PASSWORD;

if (!host || !password) {
  console.error("Set IPFS_ADMIN_HOST and ADMIN_PASSWORD");
  process.exit(1);
}

const gateway = process.env.IPFS_HOST || "ipfs.io";
const auth =
  "Basic " + Buffer.from(`${user}:${password}`).toString("base64");

const client = create({
  url: `https://${host}`,
  headers: { authorization: auth },
});

// Collect all files recursively from a directory
function collectFiles(base: string, rel = ""): { path: string; mfsPath: string }[] {
  const entries: { path: string; mfsPath: string }[] = [];
  for (const name of readdirSync(join(base, rel))) {
    const fullPath = join(base, rel, name);
    const relPath = rel ? `${rel}/${name}` : name;
    if (statSync(fullPath).isDirectory()) {
      entries.push(...collectFiles(base, relPath));
    } else {
      entries.push({ path: fullPath, mfsPath: posix.join(mfsPath, relPath) });
    }
  }
  return entries;
}

if (isDirectory) {
  const files = collectFiles(target);
  console.log(`Uploading ${files.length} files from ${target} to ${host}...`);

  try { await client.files.rm(mfsPath, { recursive: true }); } catch {}

  let uploaded = 0;
  for (const file of files) {
    const content = readFileSync(file.path);
    await client.files.write(file.mfsPath, content, {
      create: true,
      parents: true,
      truncate: true,
    });
    uploaded++;
    console.log(`  [${uploaded}/${files.length}] ${file.mfsPath}`);
  }
} else {
  console.log(`Uploading file ${target} to ${host}...`);

  const content = readFileSync(target);
  await client.files.write(mfsPath, content, {
    create: true,
    parents: true,
    truncate: true,
  });
  console.log(`  ${mfsPath}`);
}

// Get the CID from MFS
const stat = await client.files.stat(mfsPath);
const cid = stat.cid.toString();

// Pin if requested
if (pin) {
  await client.pin.add(stat.cid);
  console.log(`\nPinned ${cid}`);
}

console.log();
console.log(`Root CID: ${cid}`);
console.log(`Gateway:  https://${gateway}/ipfs/${cid}`);
console.log(`\nDone! ${mfsPath} is now visible in the Web UI.`);

// Log
const logLine = `${new Date().toISOString()}  ${cid}  ${mfsPath}  ${target}\n`;
appendFileSync(resolve(rootDir, "uploads.log"), logLine);
console.log(`CID logged to uploads.log`);
