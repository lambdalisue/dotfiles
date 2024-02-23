# 🩳 dotfiles

My personal dotfiles managed by [chezmoi].

## Usage

Install chezmoi via `apk` (Alpine), `snap` (Ubuntu), `brew` (macOS), or `scoop` (Windows)

```console
# Alpine
$ apk add chezmoi

# Ubuntu
$ snap install chezmoi --classic

# macOS
$ brew install chezmoi

# Windows
$ scoop install chezmoi
```

See [Install](https://www.chezmoi.io/install) for more detail for installing chezmoi.

Then apply this dotfiles by chezmoi like

```console
$ chezmoi init https://github.com/lambdalisue/dotfiles
$ chezmoi diff
$ chezmoi apply -v
```

Pull and apply the latest changes on the repository with

```console
$ chezmoi update -v
```

[chezmoi]: https://www.chezmoi.io

## License

<p xmlns:cc="http://creativecommons.org/ns#" xmlns:dct="http://purl.org/dc/terms/"><a property="dct:title" rel="cc:attributionURL" href="https://github.com/lambdalisue/dotfiles">dotfiles</a> by <a rel="cc:attributionURL dct:creator" property="cc:attributionName" href="https://github.com/lambdalisue">Alisue <lambdalisue@gmail.com></a> is marked with <a href="http://creativecommons.org/publicdomain/zero/1.0?ref=chooser-v1" target="_blank" rel="license noopener noreferrer" style="display:inline-block;">CC0 1.0<img style="height:22px!important;margin-left:3px;vertical-align:text-bottom;" src="https://mirrors.creativecommons.org/presskit/icons/cc.svg?ref=chooser-v1"><img style="height:22px!important;margin-left:3px;vertical-align:text-bottom;" src="https://mirrors.creativecommons.org/presskit/icons/zero.svg?ref=chooser-v1"></a></p>
