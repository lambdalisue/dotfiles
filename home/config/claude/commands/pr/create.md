---
name: pr-create
description: GitHub Pull Requestの自動作成
arguments:
  required:
    - name: issue_number
      description: 関連Issue番号
  optional:
    - name: draft
      description: ドラフトPRとして作成（true/false）
---

# PR作成コマンド

現在の変更からPull Requestを自動作成します。

## 使用方法

```bash
# 基本使用
claude "/pr/create 123"

# ドラフトPR
claude "/pr/create 123 --draft"

# 短縮形
claude "Issue #123 のPRを作成して"
claude "現在の変更でPRを作成して"
```

## 実行スクリプト

```bash
#!/bin/bash
set -euo pipefail

ISSUE_NUMBER="$1"
DRAFT="${2:-false}"
NO_CHECKS="${3:-false}"

echo "📝 PR作成を開始します（Issue #$ISSUE_NUMBER）"

# オプション構築
OPTIONS=""
if [ "$DRAFT" = "true" ]; then
    OPTIONS="$OPTIONS --draft"
fi
if [ "$NO_CHECKS" = "true" ]; then
    OPTIONS="$OPTIONS --no-checks"
fi

# PR作成スクリプト実行
./scripts/create-pr.sh "$ISSUE_NUMBER" $OPTIONS

echo "✅ PR作成完了！"
```

## PR作成プロセス

1. **変更確認**

   - git status
   - git diff

2. **品質保証**

   - TypeCheck
   - Lint
   - Build

3. **ブランチ操作**

   - ブランチ作成/切り替え
   - コミット作成
   - プッシュ

4. **PR作成**

   - テンプレート使用
   - Closes #xxx 設定
   - ラベル付与

5. **Issue更新**
   - 完了コメント追加
   - ステータス更新

## PRテンプレート

自動的に以下の情報が含まれます：

- Task ID
- 変更サイズ（XS/S/M/L/XL）
- PR Type（feat/fix/docs/test）
- 品質チェック結果
- 関連Issue

## 関連コマンド

- [`/issue/implement`](../issue/implement.md) - Issue実装
- [`/pr/review`](review.md) - PRレビュー
- [`/test/run`](../test/run.md) - テスト実行
