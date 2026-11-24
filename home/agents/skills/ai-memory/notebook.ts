#!/usr/bin/env -S deno run --allow-env=HOME --allow-read --allow-write --allow-run=git
/**
 * Keep a Git clone of the user's shared notebook (~/notebook) in step.
 *
 * Commands:
 *   clone <url>   Make the clone
 *   pull          Take in what others wrote
 *   push -m <subject> --author <name <email>> [--agent A] [--model M]
 *        [--source S]... -- <path>...
 *                 Commit the named files alone, take in, send
 *   id [--record] Print a fresh id for a memory, or for a record
 */

import { join } from "jsr:@std/path@^1";

const TOOL = "ai-memory";
const ATTEMPTS = 3;
const TIMEOUT_MS = 60_000;

/** Layers of one item per line: lines added apart are both kept. */
const ATTRIBUTES = [
  "memory/core.md merge=union",
  "memory/pending.md merge=union",
  "memory/episodic/*.md merge=union",
  "memory/forgotten/*.md merge=union",
].join("\n") + "\n";

const CROCKFORD = "0123456789abcdefghjkmnpqrstvwxyz";

/** A lowercase ULID, its random part drawn anew every time. */
export function ulid(now: number = Date.now()): string {
  let time = "";
  for (let i = 0, rest = now; i < 10; i++, rest = Math.floor(rest / 32)) {
    time = CROCKFORD[rest % 32] + time;
  }
  const random = crypto.getRandomValues(new Uint8Array(16));
  return time + Array.from(random, (b) => CROCKFORD[b % 32]).join("");
}

/** An id for a memory, different in copies of the notebook written apart. */
export function memoryId(): string {
  return `m${ulid().slice(-10)}`;
}

export function notebookDir(): string {
  const home = Deno.env.get("HOME");
  if (!home) throw new Error("HOME environment variable not set");
  return join(home, "notebook");
}

interface Ran {
  ok: boolean;
  out: string;
  err: string;
}

const SETTINGS = [
  "core.autocrlf=false",
  "core.eol=lf",
  "core.quotePath=false",
  "core.hooksPath=/dev/null",
  "commit.gpgsign=false",
  "user.name=ai-memory",
  "user.email=ai-memory@localhost",
].flatMap((s) => ["-c", s]);

async function git(cwd: string, ...args: string[]): Promise<Ran> {
  const { success, stdout, stderr } = await new Deno.Command("git", {
    args: [...SETTINGS, ...args],
    cwd,
    stdin: "null",
    // Git's messages are matched below, so they must not be translated.
    env: { GIT_TERMINAL_PROMPT: "0", LC_ALL: "C" },
    signal: AbortSignal.timeout(TIMEOUT_MS),
  }).output();
  const text = new TextDecoder();
  return {
    ok: success,
    out: text.decode(stdout).trim(),
    err: text.decode(stderr).trim(),
  };
}

async function must(cwd: string, ...args: string[]): Promise<string> {
  const ran = await git(cwd, ...args);
  if (!ran.ok) throw new Error(`git ${args[0]}: ${ran.err || ran.out}`);
  return ran.out;
}

async function exists(path: string): Promise<boolean> {
  try {
    await Deno.stat(path);
    return true;
  } catch (error) {
    if (error instanceof Deno.errors.NotFound) return false;
    throw error;
  }
}

async function requireClone(dir: string): Promise<void> {
  if (!await exists(join(dir, ".git"))) {
    throw new Error(
      `${dir} is not a clone of the notebook; ask the user for its URL and run: notebook.ts clone <url>`,
    );
  }
}

/** Sessions share one clone, so only one runs Git in it at a time. */
async function locked<T>(dir: string, then: () => Promise<T>): Promise<T> {
  using file = await Deno.open(join(dir, ".git", `${TOOL}.lock`), {
    create: true,
    write: true,
  });
  await file.lock(true);
  return await then();
}

async function clone(dir: string, url: string): Promise<void> {
  if (await exists(dir)) throw new Error(`${dir} already exists`);
  await must(
    ".",
    "clone",
    "--quiet",
    "--config",
    "core.autocrlf=false",
    "--",
    url,
    dir,
  );
  if (
    !await exists(join(dir, "memory")) || !await exists(join(dir, "records"))
  ) {
    throw new Error(`what ${url} holds is not a notebook; remove ${dir}`);
  }
}

async function takeIn(dir: string): Promise<void> {
  const attributes = join(dir, ".git", "info", "attributes");
  await Deno.mkdir(join(dir, ".git", "info"), { recursive: true });
  await Deno.writeTextFile(attributes, ATTRIBUTES);
  await must(dir, "fetch", "--quiet");
  const merged = await git(
    dir,
    "merge",
    "--quiet",
    "--no-autostash",
    "-m",
    `別のコピーの変更とまとめた\n\nNotebook-Tool: ${TOOL}`,
    "@{upstream}",
  );
  if (merged.ok) return;
  const unmerged = await git(dir, "diff", "--name-only", "--diff-filter=U");
  if (await exists(join(dir, ".git", "MERGE_HEAD"))) {
    await must(dir, "merge", "--abort");
  }
  throw new Error(
    unmerged.out
      ? `changed both here and there, nothing was merged: ${
        unmerged.out.split("\n").join(", ")
      }`
      : merged.err || merged.out,
  );
}

export async function pull(dir: string): Promise<void> {
  await requireClone(dir);
  await locked(dir, () => takeIn(dir));
}

export interface Change {
  message: string;
  author: string;
  agent?: string;
  model?: string;
  sources: string[];
  paths: string[];
}

export async function push(dir: string, change: Change): Promise<void> {
  await requireClone(dir);
  await locked(dir, async () => {
    if (change.paths.length > 0) await commit(dir, change);
    for (let attempt = 1;; attempt++) {
      await takeIn(dir);
      const sent = await git(dir, "push", "--quiet", "origin", "HEAD");
      if (sent.ok) return;
      const raced = /fetch first|non-fast-forward/.test(sent.err);
      if (!raced || attempt === ATTEMPTS) {
        throw new Error(`committed here but not sent: ${sent.err}`);
      }
    }
  });
}

async function commit(dir: string, change: Change): Promise<void> {
  await must(dir, "add", "--all", "--", ...change.paths);
  const status = await must(
    dir,
    "diff",
    "--cached",
    "--name-only",
    "--",
    ...change.paths,
  );
  // A push that failed has left its commit here; running it again sends it.
  if (status === "") return;
  const trailers = [
    ["Notebook-Tool", TOOL],
    ["Notebook-Agent", change.agent],
    ["Notebook-Model", change.model],
    ...change.sources.map((s) => ["Notebook-Source", s]),
  ].filter(([, value]) => value).map(([key, value]) => `${key}: ${value}`);
  await must(
    dir,
    "commit",
    "--quiet",
    `--author=${change.author}`,
    "-m",
    change.message,
    "-m",
    trailers.join("\n"),
    "--",
    ...change.paths,
  );
}

export function parseChange(args: string[]): Change {
  const end = args.indexOf("--");
  const options = end < 0 ? args : args.slice(0, end);
  const change: Change = {
    message: "",
    author: "",
    sources: [],
    paths: end < 0 ? [] : args.slice(end + 1),
  };
  for (let i = 0; i < options.length; i += 2) {
    const value = options[i + 1];
    if (value === undefined) throw new Error(`${options[i]} needs a value`);
    if (value.includes("\n")) throw new Error(`${options[i]} takes one line`);
    switch (options[i]) {
      case "-m":
        change.message = value;
        break;
      case "--author":
        change.author = value;
        break;
      case "--agent":
        change.agent = value;
        break;
      case "--model":
        change.model = value;
        break;
      case "--source":
        change.sources.push(value);
        break;
      default:
        throw new Error(`Unknown option for push: ${options[i]}`);
    }
  }
  if (change.paths.length > 0) {
    if (!change.message) throw new Error("push needs -m <subject>");
    if (!/^.+ <.+>$/.test(change.author)) {
      throw new Error("push needs --author 'Name <email>'");
    }
  }
  return change;
}

const HELP = `Usage:
  notebook.ts clone <url>
  notebook.ts pull
  notebook.ts push -m <subject> --author 'Name <email>' [--agent A]
              [--model M] [--source S]... -- <path>...
  notebook.ts push        (send what an earlier push left here)
  notebook.ts id            (a memory's id)
  notebook.ts id --record   (a record's id)`;

async function run([command, ...args]: string[]): Promise<void> {
  const dir = notebookDir();
  if (command === "clone" && args.length === 1) await clone(dir, args[0]);
  else if (command === "pull" && args.length === 0) await pull(dir);
  else if (command === "push") await push(dir, parseChange(args));
  else if (command === "id" && args.length === 0) console.log(memoryId());
  else if (command === "id" && args.join() === "--record") console.log(ulid());
  else throw new Error(`unknown command\n\n${HELP}`);
}

if (import.meta.main) {
  if (Deno.args.includes("--help") || Deno.args.includes("-h")) {
    console.log(HELP);
  } else {
    try {
      await run(Deno.args);
    } catch (error) {
      console.error(`Error: ${error instanceof Error ? error.message : error}`);
      Deno.exit(1);
    }
  }
}
