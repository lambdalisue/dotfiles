#!/usr/bin/env -S deno run --allow-env=HOME --allow-read
/**
 * AI Notes management CLI tool.
 *
 * Commands:
 *   generate <title> [--multiple]  Generate output path for new notes
 *   list [--limit N] [--offset N]  List existing notes (newest first)
 *
 * Examples:
 *   # Generate single document path
 *   notes.ts generate "implementation-plan"
 *   # => /Users/username/Compost/AI-Notes/2025-12/24-1430-implementation-plan.md
 *
 *   # Generate multiple documents directory path
 *   notes.ts generate "api-design" --multiple
 *   # => /Users/username/Compost/AI-Notes/2025-12/24-1430-api-design/
 *
 *   # List 10 most recent notes with titles
 *   notes.ts list --limit 10
 *   # => /path/to/note.md: タイトル
 *
 *   # List notes 10-20 (for pagination)
 *   notes.ts list --limit 10 --offset 10
 *
 * @requires --allow-env=HOME
 * @requires --allow-read (for list command)
 */

import { join, relative, SEPARATOR } from "jsr:@std/path@^1";
import { walk } from "jsr:@std/fs@^1";

interface NoteEntry {
  path: string;
  title: string;
}

const MONTH_DIR = /^\d{4}-\d{2}$/;

function getNotesBaseDir(): string {
  const homeDir = Deno.env.get("HOME");
  if (!homeDir) {
    throw new Error("HOME environment variable not set");
  }
  return join(homeDir, "Compost", "AI-Notes");
}

async function extractH1Title(filePath: string): Promise<string> {
  try {
    const content = await Deno.readTextFile(filePath);
    for (const line of content.split("\n")) {
      const trimmed = line.trim();
      if (trimmed.startsWith("# ")) {
        return trimmed.substring(2).trim();
      }
    }
    return "(no title)";
  } catch {
    return "(error reading file)";
  }
}

function isDated(path: string, baseDir: string): boolean {
  const [first, ...rest] = relative(baseDir, path).split(SEPARATOR);
  return rest.length > 0 && MONTH_DIR.test(first);
}

/**
 * Dated notes come first, newest first; their paths sort by time because
 * the month folder and the `{day}-{hour}{minutes}` prefix are zero-padded.
 * Anything else has no date to sort by and follows in name order.
 */
function sortNotePaths(paths: string[], baseDir: string): string[] {
  const dated = paths.filter((p) => isDated(p, baseDir));
  const undated = paths.filter((p) => !isDated(p, baseDir));
  dated.sort((a, b) => b.localeCompare(a));
  undated.sort((a, b) => a.localeCompare(b));
  return [...dated, ...undated];
}

function generatePath(
  baseDir: string,
  title: string,
  multiple: boolean,
  now: Date,
): string {
  if (title.trim() === "") {
    throw new Error("The title must not be blank");
  }
  if (title.includes("/")) {
    throw new Error(`The title must not contain "/": ${title}`);
  }

  const pad = (n: number) => String(n).padStart(2, "0");
  const monthDir = `${now.getFullYear()}-${pad(now.getMonth() + 1)}`;
  const name = `${pad(now.getDate())}-${pad(now.getHours())}${
    pad(now.getMinutes())
  }-${title}`;

  return multiple
    ? join(baseDir, monthDir, name) + "/"
    : join(baseDir, monthDir, `${name}.md`);
}

function parseCount(option: string, value: string | undefined): number {
  if (value === undefined || !/^\d+$/.test(value)) {
    throw new Error(`${option} needs a non-negative integer, got: ${value}`);
  }
  return Number(value);
}

async function listNotes(
  baseDir: string,
  limit?: number,
  offset = 0,
): Promise<NoteEntry[]> {
  const paths: string[] = [];
  try {
    for await (
      const entry of walk(baseDir, {
        exts: [".md"],
        includeDirs: false,
        followSymlinks: false,
      })
    ) {
      paths.push(entry.path);
    }
  } catch (error) {
    if (error instanceof Deno.errors.NotFound) {
      return [];
    }
    throw error;
  }

  const end = limit !== undefined ? offset + limit : undefined;
  const selected = sortNotePaths(paths, baseDir).slice(offset, end);

  const notes: NoteEntry[] = [];
  for (const path of selected) {
    notes.push({ path, title: await extractH1Title(path) });
  }
  return notes;
}

function showHelp() {
  console.log("AI Notes Management Tool");
  console.log("");
  console.log("Usage:");
  console.log("  notes.ts generate <title> [--multiple]");
  console.log("  notes.ts list [--limit N] [--offset N]");
  console.log("  notes.ts --help");
  console.log("");
  console.log("Commands:");
  console.log("  generate  Generate output path for new notes");
  console.log("  list      List existing notes (newest first)");
  console.log("");
  console.log("Options:");
  console.log(
    "  --multiple      Generate directory path (for generate command)",
  );
  console.log("  --limit N       Limit number of results (for list command)");
  console.log("  --offset N      Skip first N results (for list command)");
  console.log("  --help, -h      Show this help message");
}

async function run(args: string[]) {
  const command = args[0];

  if (command === "generate") {
    const title = args.slice(1).filter((arg) => !arg.startsWith("--"))[0];
    if (title === undefined) {
      throw new Error(
        "Title is required: notes.ts generate <title> [--multiple]",
      );
    }
    const multiple = args.includes("--multiple");
    console.log(generatePath(getNotesBaseDir(), title, multiple, new Date()));
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

    const notes = await listNotes(getNotesBaseDir(), limit, offset);
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
    showHelp();
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
export const _internal = { sortNotePaths, generatePath, parseCount };

if (import.meta.main) {
  main();
}
