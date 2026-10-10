# {{project}}

{{description}}

<!-- 具体例: コマンドとその出力、スクリーンショット、コードの断片など。 -->

## インストール

<!-- Homebrew、そのスタックのパッケージマネージャ、nix run、リリースからのダウンロードなど、使えるもの。 -->

## 使い方

## 開発

`nix develop` で開発用のシェルに入る（または `.envrc.sample` を `.envrc` にコピーして `direnv allow`）。そのうえで:

```sh
just fmt   # すべてのソースを整形する
just ci    # CI と同じ確認（整形・lint・テスト）
```

目指すものは [docs/concept.md](docs/concept.md)、判断の理由は [docs/adr/](docs/adr/)、約束する振る舞いは [docs/spec/](docs/spec/) にある。

## ライセンス

MIT。[LICENSE](LICENSE) を参照。
