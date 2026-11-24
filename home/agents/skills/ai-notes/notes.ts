#!/usr/bin/env -S deno run --allow-env=HOME --allow-read --allow-write
/**
 * AI Notes management CLI tool.
 *
 * A note is a memo of the user's notebook (~/notebook) labelled `ai-note`.
 * Notes written before they moved there stay readable in ~/Compost/AI-Notes.
 *
 * Commands:
 *   new <title> [--label L]... [--workgroup W]...
 *                                  Create a note and print its path
 *   list [--limit N] [--offset N]  List notes (newest first)
 */

import { join, relative, SEPARATOR } from "jsr:@std/path@^1";
import { walk } from "jsr:@std/fs@^1";
import { notebookDir, ulid } from "../ai-memory/notebook.ts";

const LABEL = "ai-note";

interface NoteEntry {
  path: string;
  title: string;
}

interface NewNote {
  title: string;
  labels: string[];
  workgroups: string[];
}

const MONTH_DIR = /^\d{4}-\d{2}$/;

function memosDir(): string {
  return join(notebookDir(), "records", "memos");
}

function archiveDir(): string {
  return join(Deno.env.get("HOME") ?? "", "Compost", "AI-Notes");
}

function h1(content: string): string {
  return content.match(/^# +(.+?)\s*$/m)?.[1] ?? "(no title)";
}

function rfc3339(at: Date): string {
  const pad = (n: number) => String(n).padStart(2, "0");
  const offset = -at.getTimezoneOffset();
  const zone = `${offset < 0 ? "-" : "+"}${
    pad(Math.floor(Math.abs(offset) / 60))
  }:${pad(Math.abs(offset) % 60)}`;
  return `${at.getFullYear()}-${pad(at.getMonth() + 1)}-${pad(at.getDate())}T${
    pad(at.getHours())
  }:${pad(at.getMinutes())}:${pad(at.getSeconds())}${zone}`;
}

function render(id: string, note: NewNote, at: Date): string {
  const meta = [
    `id: ${id}`,
    `labels: [${[LABEL, ...note.labels].join(", ")}]`,
    ...(note.workgroups.length > 0
      ? [`workgroup: [${note.workgroups.join(", ")}]`]
      : []),
    "source: ai-notes",
    `created: ${rfc3339(at)}`,
    `updated: ${rfc3339(at)}`,
  ];
  return `---\n${meta.join("\n")}\n---\n\n# ${note.title}\n`;
}

function parseNew(args: string[]): NewNote {
  const [title, ...options] = args;
  if (title === undefined || title.trim() === "" || title.includes("\n")) {
    throw new Error("new needs a title of one line");
  }
  const note: NewNote = { title: title.trim(), labels: [], workgroups: [] };
  for (let i = 0; i < options.length; i += 2) {
    const [option, value] = [options[i], options[i + 1]];
    const into = option === "--label"
      ? note.labels
      : option === "--workgroup"
      ? note.workgroups
      : undefined;
    if (!into) throw new Error(`Unknown option for new: ${option}`);
    if (!/^[\p{L}\p{N}][\p{L}\p{N}_-]*$/u.test(value ?? "")) {
      throw new Error(`${option} needs one word, got: ${value}`);
    }
    into.push(value);
  }
  return note;
}

function parseCount(option: string, value: string | undefined): number {
  if (value === undefined || !/^\d+$/.test(value)) {
    throw new Error(`${option} needs a non-negative integer, got: ${value}`);
  }
  return Number(value);
}

async function markdownIn(dir: string): Promise<string[]> {
  const paths: string[] = [];
  try {
    for await (
      const entry of walk(dir, {
        exts: [".md"],
        includeDirs: false,
        followSymlinks: false,
      })
    ) {
      paths.push(entry.path);
    }
  } catch (error) {
    if (!(error instanceof Deno.errors.NotFound)) throw error;
  }
  return paths;
}

async function notebookNotes(dir: string): Promise<NoteEntry[]> {
  const notes: (NoteEntry & { created: number })[] = [];
  for (const path of await markdownIn(dir)) {
    const content = await Deno.readTextFile(path);
    const meta = content.match(/^---\n([\s\S]*?)\n---\n/)?.[1];
    if (!meta) continue;
    // Famulen writes a list either inline or as indented items.
    const labels = meta.match(/^labels:(.*(?:\n *- .*)*)/m)?.[1] ?? "";
    if (!labels.split(/[\s,[\]]+/).includes(LABEL)) continue;
    const created = Date.parse(meta.match(/^created: *(\S+)/m)?.[1] ?? "");
    notes.push({ path, title: h1(content), created: created || 0 });
  }
  notes.sort((a, b) => b.created - a.created);
  return notes.map(({ path, title }) => ({ path, title }));
}

/**
 * Dated notes come first, newest first; their paths sort by time because
 * the month folder and the `{day}-{hour}{minutes}` prefix are zero-padded.
 * Anything else has no date to sort by and follows in name order.
 */
function sortArchive(paths: string[], baseDir: string): string[] {
  const isDated = (path: string) => {
    const [first, ...rest] = relative(baseDir, path).split(SEPARATOR);
    return rest.length > 0 && MONTH_DIR.test(first);
  };
  const dated = paths.filter(isDated);
  const undated = paths.filter((p) => !isDated(p));
  dated.sort((a, b) => b.localeCompare(a));
  undated.sort((a, b) => a.localeCompare(b));
  return [...dated, ...undated];
}

async function listNotes(
  memos: string,
  archive: string,
  limit?: number,
  offset = 0,
): Promise<NoteEntry[]> {
  const notes = await notebookNotes(memos);
  const archived = sortArchive(await markdownIn(archive), archive);
  const all: (NoteEntry | string)[] = [...notes, ...archived];
  const end = limit !== undefined ? offset + limit : undefined;
  return await Promise.all(
    all.slice(offset, end).map(async (n) =>
      typeof n === "string"
        ? { path: n, title: h1(await Deno.readTextFile(n)) }
        : n
    ),
  );
}

const HELP = `AI Notes Management Tool

Usage:
  notes.ts new <title> [--label L]... [--workgroup W]...
  notes.ts list [--limit N] [--offset N]
  notes.ts --help

Commands:
  new   Create a note in the notebook and print its path
  list  List notes, newest first

Options:
  --label L      Add a label beside "${LABEL}" (for new command)
  --workgroup W  Say which workgroup it concerns (for new command)
  --limit N      Limit number of results (for list command)
  --offset N     Skip first N results (for list command)
  --help, -h     Show this help message`;

async function run(args: string[]) {
  const command = args[0];

  if (command === "new") {
    const note = parseNew(args.slice(1));
    const at = new Date();
    const id = ulid(at.getTime());
    const path = join(memosDir(), `${id}.md`);
    await Deno.writeTextFile(path, render(id, note, at), { createNew: true });
    console.log(path);
  } else if (command === "list") {
    let limit: number | undefined;
    let offset = 0;
    for (let i = 1; i < args.length; i++) {
      if (args[i] === "--limit") {
        limit = parseCount("--limit", args[++i]);
      } else if (args[i] === "--offset") {
        offset = parseCount("--offset", args[++i]);
      } else {
        throw new Error(`Unknown option for list: ${args[i]}`);
      }
    }

    const notes = await listNotes(memosDir(), archiveDir(), limit, offset);
    if (notes.length === 0) {
      console.log("No notes found");
    }
    for (const note of notes) {
      console.log(`${note.path}: ${note.title}`);
    }
  } else {
    throw new Error(`Unknown command '${command}'`);
  }
}

async function main() {
  const args = Deno.args;
  if (args.length === 0 || args.includes("--help") || args.includes("-h")) {
    console.log(HELP);
    Deno.exit(args.length === 0 ? 1 : 0);
  }
  try {
    await run(args);
  } catch (error) {
    console.error(`Error: ${error instanceof Error ? error.message : error}`);
    Deno.exit(1);
  }
}

/** @internal */
export const _internal = {
  listNotes,
  parseCount,
  parseNew,
  render,
  rfc3339,
  sortArchive,
};

if (import.meta.main) {
  main();
}
