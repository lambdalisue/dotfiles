import { fromFileUrl, globToRegExp } from "@std/path";

const root = new URL("../", import.meta.url);

function load(filename: string): RegExp[] {
  try {
    return Deno.readTextFileSync(new URL(`../${filename}.tsv`, import.meta.url))
      .trim()
      .split("\n")
      .filter((v) => v)
      .filter((v) => !v.startsWith("#"))
      .map((v) => fromFileUrl(new URL(v, root)))
      .map((v) => globToRegExp(v));
  } catch (err) {
    if (err instanceof Deno.errors.NotFound) {
      return [];
    }
    throw err;
  }
}

const patternFiles = ({
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

export const patterns = patternFiles.flatMap(load);
