#!/bin/sh

cd "$GITHUB_WORKSPACE"
export REVIEWDOG_GITHUB_API_TOKEN="${INPUT_GITHUB_TOKEN}"

# bundler-auditの実行と結果のreviewdog形式への変換
bundle-audit check --format json | \
  jq -c '.' | \
  jq -r '.results[] | "Gemfile.lock:1 \(.advisory.criticality | if . == null then "UNKNOWN" else . | ascii_upcase end) \(.advisory.title) [\(.advisory.id)]"' | \
  reviewdog -efm="%f:%l %m" \
    -name="bundler-audit" \
    -reporter="${INPUT_REPORTER:-github-pr-check}" \
    -level="${INPUT_LEVEL:-warning}"
