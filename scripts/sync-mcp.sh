#!/bin/bash
# MCP設定変更時の自動同期スクリプト
# 1. プロジェクトリポジトリの .mcp.json を commit & push
# 2. MCP履歴をスキルリポジトリに保存

# 引数: 変更されたファイルパス
FILE="$1"
SKILLS_DIR="$HOME/.claude/plugins/marketplaces/local"
HISTORY_FILE="$SKILLS_DIR/mcp-history.json"

# ---- 1. プロジェクトリポジトリの .mcp.json を commit & push ----
sync_project_repo() {
  local mcp_dir=$(dirname "$FILE")

  if ! git -C "$mcp_dir" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    return 0
  fi

  cd "$mcp_dir" || return 0

  if git diff --name-only -- .mcp.json 2>/dev/null | grep -q ".mcp.json" || \
     git diff --cached --name-only -- .mcp.json 2>/dev/null | grep -q ".mcp.json"; then
    git add .mcp.json
    git commit -m "MCP設定更新: .mcp.json"
    git push 2>/dev/null
  fi
}

# ---- 2. MCP履歴をスキルリポジトリに保存 ----
update_mcp_history() {
  if [ ! -f "$HISTORY_FILE" ]; then
    echo '{"version":1,"entries":[]}' > "$HISTORY_FILE"
  fi

  local mcp_file="$FILE"
  [ ! -f "$mcp_file" ] && return 0

  local project_dir=$(dirname "$mcp_file")
  local project_name=$(basename "$project_dir")
  local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

  # Windows パス変換（Node.js 用）
  local history_w mcp_w
  history_w=$(cygpath -w "$HISTORY_FILE" 2>/dev/null) || history_w="$HISTORY_FILE"
  mcp_w=$(cygpath -w "$mcp_file" 2>/dev/null) || mcp_w="$mcp_file"

  # Node.js スクリプトを一時ファイルに書いて実行（エスケープ問題回避）
  local tmpjs
  tmpjs=$(mktemp /tmp/sync-mcp-XXXXXX.mjs)

  cat > "$tmpjs" << 'NODESCRIPT'
import { readFileSync, writeFileSync } from 'fs';
const [historyPath, mcpPath, projectDir, projectName, ts] = process.argv.slice(2);

const history = JSON.parse(readFileSync(historyPath, 'utf8'));
const mcpConfig = JSON.parse(readFileSync(mcpPath, 'utf8'));
const servers = mcpConfig.mcpServers || mcpConfig;

for (const [name, config] of Object.entries(servers)) {
  const existing = history.entries.find(e =>
    e.serverName === name &&
    e.project === projectDir &&
    JSON.stringify(e.config) === JSON.stringify(config)
  );
  if (existing) continue;

  const meta = {
    serverType: config.type || (config.command ? 'stdio' : 'unknown'),
  };

  if (config.args) {
    const pkgArg = config.args.find(a =>
      a.startsWith('@') || (!a.startsWith('-') && !a.startsWith('--') && a.includes('-'))
    );
    if (pkgArg) meta.packageName = pkgArg.replace(/@latest$/, '');
  }

  if (config.command) meta.command = config.command;
  if (config.url) meta.url = config.url;

  const configStr = JSON.stringify(config);
  const envMatches = [...configStr.matchAll(/\$\{([^}]+)\}/g)];
  if (envMatches.length > 0) {
    meta.requiredEnvVars = envMatches.map(m => m[1]);
  }

  history.entries.push({
    serverName: name,
    action: 'snapshot',
    timestamp: ts,
    scope: mcpPath.includes('.claude.json') ? 'global' : 'project',
    project: projectDir,
    projectName,
    config,
    meta
  });
}

writeFileSync(historyPath, JSON.stringify(history, null, 2));
NODESCRIPT

  node "$tmpjs" "$history_w" "$mcp_w" "$project_dir" "$project_name" "$timestamp" 2>/dev/null
  rm -f "$tmpjs"

  # スキルリポジトリに commit & push
  cd "$SKILLS_DIR" || return 0
  git add -A
  if ! git diff --cached --quiet; then
    git commit -m "MCP履歴更新: $project_name"
    git push origin master 2>/dev/null || git push origin main 2>/dev/null
  fi
}

# ---- メイン ----
sync_project_repo
update_mcp_history
