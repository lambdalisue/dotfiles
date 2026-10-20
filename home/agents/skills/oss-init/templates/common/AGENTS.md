# {{project}}

<!-- Quote the one-line description from README.md; do not rephrase it here. -->
{{description}}

<!-- While the name is a coined placeholder, uncomment the next line; delete
     it once the real name replaces the placeholder. -->
<!-- "{{project}}" is a provisional name, to be replaced throughout the tree. -->


## How it is built

- **Test first.** Red → green → refactor. Write the failing test before the
  code that makes it pass.
- **Each layer holds one thing.** Put a fact in the one layer that owns it,
  and nowhere else.

  | Layer | Holds |
  | --- | --- |
  | `docs/concept.md` | what this is and for whom |
  | `docs/adr/` | one decision and why it was made |
  | `docs/spec/` | the behaviour users and other components can rely on |
  | Tests | the details that pin the behaviour down: rules, boundaries, tables |
  | Code | how it is done |
  | Commits | why a change was made |
  | Comments | why it is not done another way |

  Before writing, fixing or reviewing a record, read `docs/adr/README.md`;
  before writing, fixing or reviewing a spec, read `docs/spec/README.md`.
  Follow their writing order.
- **Dependencies are current.** Before adding or bumping one, look up its
  latest release in the registry. Do not copy a version from memory or from
  another repository.

## Quality gate

Run `just ci` before reporting a change as done. CI runs the same recipe.

## Layout

<!-- One row per top-level directory. -->

| Path | What lives there |
| --- | --- |
| `docs/` | concept, ADRs, specs, references |

## Language

- README, docs and commit messages: <!-- English | Japanese -->
- Code comments, log and error messages: English

## Commits

Scoped Commits:

```
<scope>: <description>

<why this change is needed>
```

- The scope names where the change is, from the table below. Several scopes
  are joined with `, `; a change across the whole tree uses `treewide`.
- The description starts in lower case, has no trailing period, and stays
  within 72 characters.
- The body explains why. The code shows how; the tests show what.
- A release commit is `release: vX.Y.Z`.
- A breaking change says so in the body and carries a `BREAKING CHANGE:`
  trailer.

<!-- Add a row for each component in the layout. -->

| Scope | Covers |
| --- | --- |
| `adr` | `docs/adr/` |
| `spec` | `docs/spec/` |
| `ci` | `.github/` |
| `nix` | `flake.nix`, `flake.lock` |
| `deps` | dependency updates |

Add a row when a new area appears.
