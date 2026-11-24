import {
  assert,
  assertEquals,
  assertMatch,
  assertRejects,
  assertThrows,
} from "jsr:@std/assert@^1";
import { join } from "jsr:@std/path@^1";
import {
  type Change,
  memoryId,
  parseChange,
  pull,
  push,
  ulid,
} from "./notebook.ts";

async function git(cwd: string, ...args: string[]): Promise<string> {
  const ran = await new Deno.Command("git", {
    args: [
      "-c",
      "user.name=t",
      "-c",
      "user.email=t@localhost",
      "-c",
      "commit.gpgsign=false",
      ...args,
    ],
    cwd,
  }).output();
  const text = new TextDecoder();
  assert(ran.success, text.decode(ran.stderr));
  return text.decode(ran.stdout);
}

/** A shared notebook and two clones of it. */
async function shared() {
  const root = await Deno.makeTempDir();
  await git(root, "init", "-q", "--bare", "-b", "main", "hub");
  await git(root, "clone", "-q", "hub", "a");
  const a = join(root, "a");
  await Deno.mkdir(join(a, "memory"));
  await Deno.writeTextFile(
    join(a, "memory/core.md"),
    "# 心得\n\n- 一 {id: m1}\n",
  );
  await Deno.writeTextFile(join(a, "memory/long.md"), "x\n");
  await git(a, "add", "-A");
  await git(a, "commit", "-qm", "start");
  await git(a, "push", "-q", "-u", "origin", "HEAD:main");
  await git(root, "clone", "-q", "hub", "b");
  return { a, b: join(root, "b"), hub: join(root, "hub") };
}

const change = (...paths: string[]): Change => ({
  message: "書いた",
  author: "AI <ai@localhost>",
  agent: "Agent 1",
  model: "model-1",
  sources: ["会話"],
  paths,
});
const write = (dir: string, path: string, text: string) =>
  Deno.writeTextFile(join(dir, path), text);
const read = (dir: string, path: string) => Deno.readTextFile(join(dir, path));

Deno.test("what one clone pushes is pulled in another", async () => {
  const { a, b } = await shared();
  await write(a, "memory/new.md", "new\n");
  await push(a, change("memory/new.md"));
  await pull(b);
  assertEquals(await read(b, "memory/new.md"), "new\n");
});

Deno.test("a commit names its author and how it was written", async () => {
  const { a, hub } = await shared();
  await write(a, "memory/long.md", "y\n");
  await push(a, change("memory/long.md"));
  assertEquals(
    (await git(hub, "log", "-1", "--format=%an <%ae>%n%B", "main")).trim(),
    "AI <ai@localhost>\n書いた\n\nNotebook-Tool: ai-memory\nNotebook-Agent: Agent 1\nNotebook-Model: model-1\nNotebook-Source: 会話",
  );
});

Deno.test("only the named files are committed", async () => {
  const { a, hub } = await shared();
  await write(a, "memory/long.md", "someone else's\n");
  await write(a, "memory/new.md", "new\n");
  await push(a, change("memory/new.md"));
  assertEquals(await git(hub, "show", "main:memory/long.md"), "x\n");
  assertEquals(await read(a, "memory/long.md"), "someone else's\n");
});

Deno.test("a removed file is removed from the shared notebook", async () => {
  const { a, b } = await shared();
  await Deno.remove(join(a, "memory/long.md"));
  await push(a, change("memory/long.md"));
  await pull(b);
  await assertRejects(() => read(b, "memory/long.md"), Deno.errors.NotFound);
});

Deno.test("items added apart to one layer are both kept", async () => {
  const { a, b } = await shared();
  const core = "# 心得\n\n- 一 {id: m1}\n";
  await write(a, "memory/core.md", core + "- 二 {id: m2}\n");
  await push(a, change("memory/core.md"));
  await write(b, "memory/core.md", core + "- 三 {id: m3}\n");
  await push(b, change("memory/core.md"));
  const text = await read(b, "memory/core.md");
  assert(text.includes("m2") && text.includes("m3"), text);
});

Deno.test("what is changed in two ways is told and the clone stays as it was", async () => {
  const { a, b } = await shared();
  await write(a, "memory/long.md", "a\n");
  await push(a, change("memory/long.md"));
  await write(b, "memory/long.md", "b\n");
  await assertRejects(
    () => push(b, change("memory/long.md")),
    Error,
    "memory/long.md",
  );
  assertEquals(await read(b, "memory/long.md"), "b\n");
  assertEquals(await git(b, "status", "--porcelain"), "");
});

Deno.test("what was refused stays here and is sent by the next push", async () => {
  const { a, hub } = await shared();
  const hook = join(hub, "hooks/pre-receive");
  await Deno.writeTextFile(
    hook,
    "#!/bin/sh\necho 'broken rule' >&2; exit 1\n",
    { mode: 0o755 },
  );
  await write(a, "memory/long.md", "y\n");
  await assertRejects(
    () => push(a, change("memory/long.md")),
    Error,
    "broken rule",
  );
  await Deno.remove(hook);
  await push(a, { ...change(), message: "", author: "" });
  assertEquals(await git(hub, "show", "main:memory/long.md"), "y\n");
});

Deno.test("a directory that is no clone is told how to become one", async () => {
  const dir = await Deno.makeTempDir();
  await assertRejects(() => pull(dir), Error, "notebook.ts clone");
});

Deno.test("ids", () => {
  assertMatch(ulid(), /^[0-7][0-9a-hjkmnp-tv-z]{25}$/);
  assert(ulid(1) < ulid(2));
  assert(ulid(1) !== ulid(1));
  assertMatch(memoryId(), /^m[0-9a-hjkmnp-tv-z]{10}$/);
});

Deno.test("parseChange", () => {
  assertEquals(
    parseChange([
      "-m",
      "s",
      "--author",
      "A <a@b>",
      "--source",
      "x",
      "--source",
      "y",
      "--",
      "p",
    ]),
    { message: "s", author: "A <a@b>", sources: ["x", "y"], paths: ["p"] },
  );
  assertThrows(
    () => parseChange(["--author", "A <a@b>", "--", "p"]),
    Error,
    "-m",
  );
  assertThrows(() => parseChange(["-m", "s", "--", "p"]), Error, "--author");
  assertThrows(() => parseChange(["-m", "a\nb", "--", "p"]), Error, "one line");
  assertThrows(() => parseChange(["--nope", "x"]), Error, "--nope");
});
