import { assertEquals, assertThrows } from "jsr:@std/assert@^1";
import { _internal } from "./notes.ts";

const { sortNotePaths, generatePath, parseCount } = _internal;

const base = "/home/u/Compost/AI-Notes";

Deno.test("sortNotePaths", async (t) => {
  await t.step("puts dated notes newest first", () => {
    const paths = [
      `${base}/2026-10/03-0900-a.md`,
      `${base}/2026-11/21-2013-b.md`,
      `${base}/2026-11/14-1313-c/07-d.md`,
    ];
    assertEquals(sortNotePaths(paths, base), [
      `${base}/2026-11/21-2013-b.md`,
      `${base}/2026-11/14-1313-c/07-d.md`,
      `${base}/2026-10/03-0900-a.md`,
    ]);
  });

  await t.step(
    "puts notes outside a dated folder after every dated note",
    () => {
      const paths = [
        `${base}/refactoring_candidates.md`,
        `${base}/2026-10/03-0900-a.md`,
        `${base}/zzz/loose.md`,
        `${base}/2026-11/21-2013-b.md`,
      ];
      assertEquals(sortNotePaths(paths, base), [
        `${base}/2026-11/21-2013-b.md`,
        `${base}/2026-10/03-0900-a.md`,
        `${base}/refactoring_candidates.md`,
        `${base}/zzz/loose.md`,
      ]);
    },
  );
});

Deno.test("generatePath", async (t) => {
  const now = new Date(2026, 10, 22, 9, 5);

  await t.step("names a single note after the minute it was made", () => {
    assertEquals(
      generatePath(base, "設計", false, now),
      `${base}/2026-11/22-0905-設計.md`,
    );
  });

  await t.step("names a folder for several notes", () => {
    assertEquals(
      generatePath(base, "設計", true, now),
      `${base}/2026-11/22-0905-設計/`,
    );
  });

  await t.step("refuses a title that would cut another folder level", () => {
    assertThrows(() => generatePath(base, "a/b", false, now), Error, "/");
  });

  await t.step("refuses a blank title", () => {
    assertThrows(() => generatePath(base, "  ", false, now), Error, "title");
  });
});

Deno.test("parseCount", async (t) => {
  await t.step("reads a non-negative integer", () => {
    assertEquals(parseCount("--limit", "10"), 10);
    assertEquals(parseCount("--offset", "0"), 0);
  });

  await t.step("refuses anything else", () => {
    for (const value of ["abc", "-1", "1.5", "", undefined]) {
      assertThrows(() => parseCount("--limit", value), Error, "--limit");
    }
  });
});
