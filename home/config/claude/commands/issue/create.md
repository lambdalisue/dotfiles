---
name: issue-create
description: 自然言語からGitHub Issueを自動生成
arguments:
  required:
    - name: request
      description: 実装したい機能の説明（自然言語）
  optional:
    - name: complexity
      description: 複雑度（1-10）
    - name: guidance
      description: AIガイダンスレベル
---

# Issue作成コマンド

自然言語の要望文から構造化されたGitHub Issueを自動生成します。

## 使用方法

```bash
# 基本使用
claude "/issue/create editorconfig lintを導入したい"

# 複雑度指定
claude "/issue/create 難しいタスク --complexity 8"

# 短縮形
claude "editorconfig lintを導入したい Issue を作って"
```

## 実行スクリプト

```bash
#!/bin/bash
set -euo pipefail

# 引数解析
REQUEST="$1"
COMPLEXITY="${2:-}"
GUIDANCE="${3:-}"

# スクリプト実行
if [ -n "$COMPLEXITY" ]; then
    ./scripts/create-issue.sh "$REQUEST" -c "$COMPLEXITY"
elif [ -n "$GUIDANCE" ]; then
    ./scripts/create-issue.sh "$REQUEST" -g "$GUIDANCE"
else
    ./scripts/create-issue.sh "$REQUEST"
fi

# 結果表示
echo ""
echo "📝 Issue作成完了！"
echo "次のステップ: claude \"/issue/implement [番号]\""
```

## 機能

- Task ID自動採番（P0-001形式）
- 複雑度の自動推定
- AIガイダンスレベル判定
- 関連ドキュメント自動リンク
- 実行ステップ生成
- 成功条件定義
- 検証コマンド生成

## 関連コマンド

- [`/issue/implement`](implement.md) - Issueの自動実装
- [`/issue/list`](list.md) - Issue一覧表示
- [`/pr/create`](../pr/create.md) - PR作成
