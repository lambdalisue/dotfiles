import { parseArgs } from "@std/cli";
import { dirname, fromFileUrl, join, relative, resolve } from "@std/path";
import { entries } from "./entries.ts";

const home = Deno.build.os === "windows"
  ? Deno.env.get("USERPROFILE")!
  : Deno.env.get("HOME")!;

const root = fromFileUrl(new URL("../", import.meta.url));

const targets = entries.map(([src, dst]) => {
  const info = Deno.lstatSync(src);
  const path = src;
  src = info.isSymlink ? resolve(Deno.readLinkSync(path)) : path;
  dst = join(home, relative(root, dst ?? path));
  return {
    path,
    src,
    dst,
    dir: info.isDirectory,
  };
});

function link(src: string, dst: string, dir: boolean, force: boolean) {
  Deno.mkdirSync(dirname(dst), { recursive: true });
  try {
    Deno.symlinkSync(src, dst, { type: dir ? "dir" : "file" });
  } catch (err) {
    if (force && err instanceof Deno.errors.AlreadyExists) {
      Deno.removeSync(dst, { recursive: true });
      Deno.symlinkSync(src, dst, { type: dir ? "dir" : "file" });
    } else {
      throw err;
    }
  }
}

function main(): void {
  const { execute, force } = parseArgs(Deno.args, {
    boolean: ["execute", "force"],
    alias: {
      "force": ["f"],
    },
  });

  for (const { path, src, dst, dir } of targets) {
    const displaySrc = relative(root, path);
    const displayDst = join("~", relative(home, dst));
    if (!execute) {
      console.log(
        `'${displaySrc}' will symlinked to '${displayDst}' (dry-run)`,
      );
    } else {
      try {
        link(src, dst, dir, force);
        console.log(`'${displaySrc}' is symlinked to '${displayDst}'`);
      } catch (err) {
        console.error(`Failed to symlink '${displayDst}': ${err.message}`);
      }
    }
  }
}

if (import.meta.main) {
  main();
}
