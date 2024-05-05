import { fromFileUrl } from "@std/path";

const root = new URL("../", import.meta.url);

function load(filename: string): [string, string | undefined][] {
  try {
    return Deno.readTextFileSync(new URL(`../${filename}.tsv`, import.meta.url))
      .trim()
      .split("\n")
      .filter((v) => v)
      .filter((v) => !v.startsWith("#"))
      .map((v) => v.split("\t", 2) as [string, string | undefined])
      .map(([s, d]) => [fromFileUrl(new URL(s, root)), d]);
  } catch (err) {
    if (err instanceof Deno.errors.NotFound) {
      return [];
    }
    throw err;
  }
}

const entriesFiles = ({
  "linux": [
    ".dotfiles",
    ".dotfiles_unixlike",
    ".dotfiles_linux",
  ],
  "darwin": [
    ".dotfiles",
    ".dotfiles_unixlike",
    ".dotfiles_darwin",
  ],
  "windows": [
    ".dotfiles",
    ".dotfiles_windows",
  ],
} as Record<string, string[]>)[Deno.build.os] ?? [".dotfiles"];

export const entries = entriesFiles.flatMap(load);
