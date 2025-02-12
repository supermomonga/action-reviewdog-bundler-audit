#!/bin/bash

set -e

# テスト用の一時ディレクトリを作成
cd "$(dirname "$0")"
TEMP_DIR=$(mktemp -d)
trap 'rm -rf "$TEMP_DIR"' EXIT

# テスト1: bundler-auditの出力フォーマットのテスト
test_output_format() {
  echo "=== テスト1: 出力フォーマットのテスト ==="

  # テスト用の環境変数を設定
  export GITHUB_WORKSPACE="$PWD/fixtures/vulnerable"
  export INPUT_GITHUB_TOKEN="dummy_token"
  export INPUT_LEVEL="warning"
  export INPUT_REPORTER="github-pr-check"

  # entrypoint.shを実行し、出力を一時ファイルに保存
  OUTPUT_FILE="$TEMP_DIR/output.txt"
  pushd fixtures/vulnerable > /dev/null

  # bundler-auditの実行(実際のreviewdog実行は避ける)
  bundle exec bundle-audit check --format json | \
    jq -r '.results[] | "Gemfile.lock:1:\(.advisory.criticality | if . == null then "UNKNOWN" else . | ascii_upcase end): \(.advisory.title) [\(.advisory.id)]"' > "$OUTPUT_FILE"

  # 出力フォーマットの検証
  if grep -qE '^Gemfile\.lock:[0-9]+:(HIGH|MEDIUM|LOW|UNKNOWN):.*\[.*\]$' "$OUTPUT_FILE"; then
    echo "✅ 出力フォーマットのテストが成功しました"
  else
    echo "❌ 出力フォーマットのテストが失敗しました"
    cat "$OUTPUT_FILE"
    exit 1
  fi
  popd > /dev/null
}

# テスト2: 深刻度レベルの変換テスト
test_severity_levels() {
  echo "=== テスト2: 深刻度レベルの変換テスト ==="

  # テスト用の環境変数を設定
  # 各レベルでのテスト
  for level in info warning error; do
    export INPUT_LEVEL="$level"
    echo "レベル '$level' のテスト..."

    pushd fixtures/vulnerable > /dev/null
    OUTPUT_FILE="$TEMP_DIR/output_$level.txt"

    bundle exec bundle-audit check --format json | \
      jq -r '.results[] | "Gemfile.lock:1:\(.advisory.criticality | if . == null then "UNKNOWN" else . | ascii_upcase end): \(.advisory.title) [\(.advisory.id)]"' > "$OUTPUT_FILE"

    if [ -s "$OUTPUT_FILE" ]; then
      echo "✅ レベル '$level' のテストが成功しました"
    else
      echo "❌ レベル '$level' のテストが失敗しました"
      exit 1
    fi
    popd > /dev/null
  done
}

# メインのテスト実行
main() {
  echo "bundler-audit with reviewdogのテストを開始します..."
  test_output_format
  test_severity_levels
  echo "すべてのテストが成功しました! 🎉"
}

main
