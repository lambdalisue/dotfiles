import { assertEquals, assertMatch, assertThrows } from "jsr:@std/assert@^1";
import { join } from "jsr:@std/path@^1";
import { _internal } from "./notes.ts";

const { sortArchive, render, rfc3339, parseNew, parseCount, listNotes } =
  _internal;

Deno.test("render", async (t) => {
  const at = new Date(2026, 10, 22, 9, 5, 7);
  const id = "01m84hnp3481dtph4gvt7ef1b8";

  await t.step("writes a memo with the metadata of a record", () => {
    assertEquals(
      render(id, { title: "設計", labels: ["設計"], workgroups: ["work"] }, at),
      `---
id: ${id}
labels: [ai-note, 設計]
workgroup: [work]
source: ai-notes
created: ${rfc3339(at)}
updated: ${rfc3339(at)}
---

# 設計
`,
    );
  });

  await t.step("leaves out a workgroup nobody named", () => {
    const text = render(id, { title: "a", labels: [], workgroups: [] }, at);
    assertEquals(text.includes("workgroup"), false);
  });

  await t.step("writes times as RFC 3339", () => {
    assertMatch(rfc3339(at), /^2026-11-22T09:05:07[+-]\d{2}:\d{2}$/);
  });
});

Deno.test("parseNew", async (t) => {
  await t.step("reads a title, labels and workgroups", () => {
    assertEquals(
      parseNew(["設計 A/B", "--label", "x", "--workgroup", "work"]),
      { title: "設計 A/B", labels: ["x"], workgroups: ["work"] },
    );
  });

  await t.step("refuses a missing, blank or multi-line title", () => {
    for (const args of [[], ["  "], ["a\nb"]]) {
      assertThrows(() => parseNew(args), Error, "title");
    }
  });

  await t.step("refuses a label that would not be one plain word", () => {
    for (const label of ["a, b", "a]", "a: b", ""]) {
      assertThrows(() => parseNew(["t", "--label", label]), Error, "--label");
    }
  });

  await t.step("refuses an unknown option", () => {
    assertThrows(() => parseNew(["t", "--nope", "x"]), Error, "--nope");
  });
});

Deno.test("listNotes puts notebook notes newest first, then the archive", async () => {
  const root = await Deno.makeTempDir();
  const memos = join(root, "memos");
  const archive = join(root, "archive");
  await Deno.mkdir(memos);
  await Deno.mkdir(join(archive, "2026-10"), { recursive: true });
  const note = (id: string, label: string, title: string, created: string) =>
    Deno.writeTextFile(
      join(memos, `${id}.md`),
      `---\nid: ${id}\nlabels: [${label}]\ncreated: ${created}\n---\n\n# ${title}\n`,
    );
  await note("01b", "ai-note, x", "早い", "2026-11-01T00:00:00+09:00");
  await note("01a", "ai-note", "遅い", "2026-11-02T00:00:00+09:00");
  await note("01c", "memo", "ノートでない", "2026-11-03T00:00:00+09:00");
  await Deno.writeTextFile(join(memos, "README.md"), "# メモ\n");
  await Deno.writeTextFile(join(archive, "2026-10/03-0900-a.md"), "# 昔\n");

  const titles = async (limit?: number, offset?: number) =>
    (await listNotes(memos, archive, limit, offset)).map((n) => n.title);
  assertEquals(await titles(), ["遅い", "早い", "昔"]);
  assertEquals(await titles(1, 1), ["早い"]);
  assertEquals(await listNotes(join(root, "no"), join(root, "no")), []);
});

Deno.test("sortArchive", () => {
  const base = "/home/u/Compost/AI-Notes";
  assertEquals(
    sortArchive([
      `${base}/refactoring_candidates.md`,
      `${base}/2026-10/03-0900-a.md`,
      `${base}/zzz/loose.md`,
      `${base}/2026-11/21-2013-b.md`,
      `${base}/2026-11/14-1313-c/07-d.md`,
    ], base),
    [
      `${base}/2026-11/21-2013-b.md`,
      `${base}/2026-11/14-1313-c/07-d.md`,
      `${base}/2026-10/03-0900-a.md`,
      `${base}/refactoring_candidates.md`,
      `${base}/zzz/loose.md`,
    ],
  );
});

Deno.test("parseCount", () => {
  assertEquals(parseCount("--limit", "10"), 10);
  assertEquals(parseCount("--offset", "0"), 0);
  for (const value of ["abc", "-1", "1.5", "", undefined]) {
    assertThrows(() => parseCount("--limit", value), Error, "--limit");
  }
});
