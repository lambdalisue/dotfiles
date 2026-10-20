# {{project}}

{{description}}

<!-- A concrete example: a command and its output, a screenshot, a snippet. -->

## Install

<!-- Homebrew, the stack's package manager, nix run, a release download — whichever apply. -->

## Usage

## Development

Enter the development shell with `nix develop` (or copy `.envrc.sample` to
`.envrc` and `direnv allow`), then:

```sh
just fmt   # format every source
just ci    # everything CI runs: format check, lint, tests
```

The design lives in [docs/concept.md](docs/concept.md), the decisions behind it
in [docs/adr/](docs/adr/), and the behaviour it promises in
[docs/spec/](docs/spec/).

## License

MIT. See [LICENSE](LICENSE).
