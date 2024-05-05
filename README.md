# 🩳 dotfiles

My personal dotfiles managed by my personal [Deno] script.

[Deno]: https://deno.land

## Usage

Install [Deno] and execute the `link` task like below:

```console
$ deno task link
```

Above runs the `link` task with dry-run mode. Use `--execute` flag to actually
link the dotfiles.

```console
$ deno task link --execute
```

And use `--force` flag to overwrite existing files.

```console
$ deno task link --execute --force
```

## Entries

Edit one of the following files to determine the entries.

- `.dotfiles`

## License

<p xmlns:cc="http://creativecommons.org/ns#" xmlns:dct="http://purl.org/dc/terms/"><a property="dct:title" rel="cc:attributionURL" href="https://github.com/lambdalisue/dotfiles">dotfiles</a> by <a rel="cc:attributionURL dct:creator" property="cc:attributionName" href="https://github.com/lambdalisue">Alisue <lambdalisue@gmail.com></a> is marked with <a href="http://creativecommons.org/publicdomain/zero/1.0?ref=chooser-v1" target="_blank" rel="license noopener noreferrer" style="display:inline-block;">CC0 1.0<img style="height:22px!important;margin-left:3px;vertical-align:text-bottom;" src="https://mirrors.creativecommons.org/presskit/icons/cc.svg?ref=chooser-v1"><img style="height:22px!important;margin-left:3px;vertical-align:text-bottom;" src="https://mirrors.creativecommons.org/presskit/icons/zero.svg?ref=chooser-v1"></a></p>
