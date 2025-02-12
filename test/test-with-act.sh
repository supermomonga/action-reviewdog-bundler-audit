#!/bin/bash

set -e

# 現在のディレクトリをリポジトリのルートに移動
cd "$(dirname "$0")/.."

# テスト用の一時ディレクトリを作成
TEMP_DIR=$(mktemp -d)
trap 'rm -rf "$TEMP_DIR"' EXIT

# テスト用のGemfile.lockを一時ディレクトリにコピー
cp test/fixtures/vulnerable/Gemfile.lock "$TEMP_DIR/"

# actを使用してGitHub Actionをテスト
echo "=== GitHub Actionのテストを開始します ==="
echo "テスト1: デフォルト設定でのテスト"
act pull_request \
  --artifact-server-path "$TEMP_DIR" \
  --env GITHUB_TOKEN=dummy_token \
  --workflows .github/workflows/test.yml \
  --eventpath test/fixtures/pull_request.json

echo "すべてのテストが成功しました! 🎉"
