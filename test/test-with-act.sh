#!/bin/bash

set -e

# 現在のディレクトリをリポジトリのルートに移動
cd "$(dirname "$0")/.."

# テスト用の一時ディレクトリを作成
TEMP_DIR=$(mktemp -d)
trap 'rm -rf "$TEMP_DIR"' EXIT

# テスト用のGemfile.lockを一時ディレクトリにコピー
cp test/fixtures/vulnerable/Gemfile.lock "$TEMP_DIR/"

# actコマンドの存在確認
if ! command -v act &> /dev/null; then
  echo "Error: actコマンドが見つかりません"
  echo "以下のコマンドでインストールしてください:"
  echo ""
  echo "macOSの場合:"
  echo "  brew install act"
  echo ""
  echo "その他の場合は以下を参照してください:"
  echo "  https://github.com/nektos/act#installation"
  exit 1
fi

# actを使用してGitHub Actionをテスト
echo "=== GitHub Actionのテストを開始します ==="
echo "テスト1: デフォルト設定でのテスト"
act pull_request \
  --artifact-server-path "$TEMP_DIR" \
  --env GITHUB_TOKEN=dummy_token \
  --workflows .github/workflows/test.yml \
  --eventpath test/fixtures/pull_request.json \
  --container-architecture linux/amd64

echo "すべてのテストが成功しました! 🎉"
