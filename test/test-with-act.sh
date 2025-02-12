#!/bin/bash

set -e

cd "$(dirname "$0")/.."

# Pull Requestのコンテキストを設定
export GITHUB_EVENT_NAME="pull_request"
export GITHUB_EVENT_PATH="$PWD/test/fixtures/pull_request.json"
export GITHUB_REPOSITORY="supermomonga/action-reviewdog-bundler-audit"
export GITHUB_SHA="dummy_sha"
export GITHUB_REF="refs/pull/1/merge"
export GITHUB_API_URL="https://api.github.com"
export GITHUB_SERVER_URL="https://github.com"
export GITHUB_GRAPHQL_URL="https://api.github.com/graphql"

echo "GitHub Action ==="
echo "1: デフォルト設定でのテスト"
act -q -j "test-bundler-audit" \
  -W .github/workflows/test.yml \
  -e test/fixtures/pull_request.json \
  --container-architecture linux/amd64 \
  -s GITHUB_TOKEN="dummy_token" \
  --artifact-server-path /tmp/artifacts

echo "すべてのテストが成功しました! 🎉"
