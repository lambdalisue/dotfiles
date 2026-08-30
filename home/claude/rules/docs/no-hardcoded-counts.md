# Never Hard-Code a Count That the Content Controls

Do not write a literal number for something the document itself enumerates, or
that grows and shrinks as the project changes: "there are 3 kinds of metric",
"the 5 feature families", "12 dimensions", "the 4th kind", "condition 3".

The number duplicates a fact that lives somewhere else — the list under the
heading, the registry in code, the directory listing. **The duplicate rots
silently.** Nothing fails when a member is added; the prose just becomes a lie,
and every cross-reference that quoted the old heading breaks at the same time.

## What counts as fluctuating

Fluctuating — do NOT write the number:

- Counts of things this project defines: metrics, axes, dimensions, crates,
  commands, checks, options, layers, columns, supported formats.
- Ordinals into such a set: "the 4th kind", "condition 3", "the 2nd of these".
- Counts derived from data that gets regenerated: corpus sizes, sample counts,
  "39 checks failed".

Fixed — the number IS the fact, keep it:

- Facts about external work: "the paper compared 14 feature types".
- Measurements in a dated experiment log or a commit message, where the date
  pins them.
- Numbers that ARE the design: a three-valued verdict, a two-sided band.
  Changing one changes the design, so breaking the name is the right signal.

## How to write instead

**Name the members; don't count them.** This is the first choice, not dropping
the number — a heading that only loses its count often loses the information
too.

| ❌ | ✅ |
| --- | --- |
| `## There are 4 kinds of metric` | `## Matching, directive, humanness, inspection` |
| `### The 4th kind looks at breakage` | `### Inspection looks at breakage` |
| `summed over the 5 families` | `summed over the scoring families` |
| `the 12 dimensions are passed raw` | `every humanness dimension is passed raw` |
| `the remaining 3 conditions` | `the remaining conditions` |

Naming survives every addition; counting breaks on the next one. Fall back to
simply dropping the number only when the members are too many to name, or are
already listed right there.

When the count genuinely helps a reader, put it where it is generated — a
listing the tool prints, a registry, or a test that asserts it
(`assert_eq!(names.len(), 12)`). There the count fails loudly when it goes
stale, which is the whole point.

## Anchors

Renaming a counted heading breaks every link to it. After the rename, run the
repository's link checker, or grep for the old anchor and update every
reference.

## Scope

Applies to every artifact that outlives the change: specs, design docs,
READMEs, code comments and doc comments, and API documentation. It does not
apply to dated records — experiment logs, commit messages, PR bodies, issue
bodies — where the number is a measurement pinned to a moment.
