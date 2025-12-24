#!/usr/bin/env -S deno run --allow-env=HOME --allow-read
/**
 * AI Notes management CLI tool.
 *
 * Commands:
 *   generate <title> [--multiple]  Generate output path for new notes
 *   list [--limit N] [--offset N]  List existing notes (newest first, sorted by path)
 *
 * Examples:
 *   # Generate single document path
 *   deno run -A notes.ts generate "implementation-plan"
 *   # => /Users/username/Compost/AI-Notes/2025-12/24-1430-implementation-plan.md
 *
 *   # Generate multiple documents directory path
 *   deno run -A notes.ts generate "api-design" --multiple
 *   # => /Users/username/Compost/AI-Notes/2025-12/24-1430-api-design/
 *
 *   # List 10 most recent notes with titles
 *   deno run -A notes.ts list --limit 10
 *   # => /path/to/note.md: タイトル
 *
 *   # List notes 10-20 (for pagination)
 *   deno run -A notes.ts list --limit 10 --offset 10
 *
 * @requires --allow-env=HOME
 * @requires --allow-read (for list command)
 */

import { join } from "jsr:@std/path";
import { walk } from "jsr:@std/fs";

interface NoteEntry {
  path: string;
  title: string;
}

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
    const lines = content.split("\n");

    for (const line of lines) {
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

function generatePath(title: string, multiple = false): string {
  const now = new Date();

  // Format components
  const year = now.getFullYear();
  const month = String(now.getMonth() + 1).padStart(2, "0");
  const day = String(now.getDate()).padStart(2, "0");
  const hour = String(now.getHours()).padStart(2, "0");
  const minutes = String(now.getMinutes()).padStart(2, "0");

  // Build path components
  const baseDir = getNotesBaseDir();
  const monthDir = `${year}-${month}`;
  const filename = `${day}-${hour}${minutes}-${title}`;

  if (multiple) {
    // Multiple documents: {day}-{hour}{minutes}-{title}/
    return join(baseDir, monthDir, filename) + "/";
  } else {
    // Single document: {day}-{hour}{minutes}-{title}.md
    return join(baseDir, monthDir, `${filename}.md`);
  }
}

async function listNotes(
  limit?: number,
  offset = 0,
): Promise<NoteEntry[]> {
  const baseDir = getNotesBaseDir();
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
      // Notes directory doesn't exist yet
      return [];
    }
    throw error;
  }

  // Sort by path (newest first - descending order)
  // Path format: {year}-{month}/{day}-{hour}{minutes}-{title}.md
  paths.sort((a, b) => b.localeCompare(a));

  // Apply offset and limit
  const start = offset;
  const end = limit !== undefined ? start + limit : undefined;
  const selectedPaths = paths.slice(start, end);

  // Extract titles from selected files
  const notes: NoteEntry[] = [];
  for (const path of selectedPaths) {
    const title = await extractH1Title(path);
    notes.push({ path, title });
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
  console.log("  --multiple      Generate directory path (for generate command)");
  console.log("  --limit N       Limit number of results (for list command)");
  console.log("  --offset N      Skip first N results (for list command)");
  console.log("  --help, -h      Show this help message");
}

async function main() {
  const args = Deno.args;

  if (
    args.length === 0 || args.includes("--help") || args.includes("-h")
  ) {
    showHelp();
    Deno.exit(args.length === 0 ? 1 : 0);
  }

  const command = args[0];

  if (command === "generate") {
    const multiple = args.includes("--multiple");
    const title = args.slice(1).filter((arg) => !arg.startsWith("--"))[0];

    if (!title) {
      console.error("Error: Title is required for generate command");
      console.error("Usage: notes.ts generate <title> [--multiple]");
      Deno.exit(1);
    }

    const path = generatePath(title, multiple);
    console.log(path);
  } else if (command === "list") {
    let limit: number | undefined;
    let offset = 0;

    // Parse limit and offset
    for (let i = 1; i < args.length; i++) {
      if (args[i] === "--limit" && i + 1 < args.length) {
        limit = parseInt(args[i + 1], 10);
        i++;
      } else if (args[i] === "--offset" && i + 1 < args.length) {
        offset = parseInt(args[i + 1], 10);
        i++;
      }
    }

    const notes = await listNotes(limit, offset);

    if (notes.length === 0) {
      console.log("No notes found");
    } else {
      for (const note of notes) {
        console.log(`${note.path}: ${note.title}`);
      }
    }
  } else {
    console.error(`Error: Unknown command '${command}'`);
    console.error("");
    showHelp();
    Deno.exit(1);
  }
}

if (import.meta.main) {
  main();
}
