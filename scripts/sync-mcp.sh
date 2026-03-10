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
  # .mcp.json のあるディレクトリ（プロジェクトルート）を特定
  local mcp_dir=$(dirname "$FILE")

  # git リポジトリか確認
  if ! git -C "$mcp_dir" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    return 0
  fi

  cd "$mcp_dir" || return 0

  # .mcp.json に変更があるか
  if git diff --name-only -- .mcp.json | grep -q ".mcp.json" || \
     git diff --cached --name-only -- .mcp.json | grep -q ".mcp.json"; then
    git add .mcp.json
    git commit -m "MCP設定更新: .mcp.json"
    git push 2>/dev/null
  fi
}

# ---- 2. MCP履歴をスキルリポジトリに保存 ----
update_mcp_history() {
  # 履歴ファイル初期化
  if [ ! -f "$HISTORY_FILE" ]; then
    echo '{"version":1,"entries":[]}' > "$HISTORY_FILE"
  fi

  # .mcp.json を読み取ってスナップショットを生成
  local mcp_file="$FILE"
  [ ! -f "$mcp_file" ] && return 0

  local project_dir=$(dirname "$mcp_file")
  local project_name=$(basename "$project_dir")
  local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

  # Node.js で JSON 操作（jq がない環境対応）
  node -e "
    const fs = require('fs');
    const history = JSON.parse(fs.readFileSync('$HISTORY_FILE', 'utf8'));
    const mcpConfig = JSON.parse(fs.readFileSync('$mcp_file', 'utf8'));
    const servers = mcpConfig.mcpServers || mcpConfig;

    for (const [name, config] of Object.entries(servers)) {
      // 既に同じサーバー・同じプロジェクトの最新エントリと同一なら skip
      const existing = history.entries.find(e =>
        e.serverName === name &&
        e.project === '$project_dir' &&
        JSON.stringify(e.config) === JSON.stringify(config)
      );
      if (existing) continue;

      // メタ情報を自動収集
      const meta = {
        serverType: config.type || (config.command ? 'stdio' : 'unknown'),
        timestamp: '$timestamp'
      };

      // npm パッケージ名を抽出
      if (config.args) {
        const pkgArg = config.args.find(a => a.startsWith('@') || (!a.startsWith('-') && a.includes('/')));
        if (pkgArg) meta.packageName = pkgArg.replace(/@latest$/, '');
      }

      // 必要な環境変数を抽出
      const envVars = [];
      const configStr = JSON.stringify(config);
      const matches = configStr.match(/\\$\\{([^}]+)\\}/g);
      if (matches) {
        matches.forEach(m => envVars.push(m.replace(/\\$\\{|\\}/g, '')));
        meta.requiredEnvVars = envVars;
      }

      // URL を記録
      if (config.url) meta.url = config.url;

      history.entries.push({
        serverName: name,
        action: 'snapshot',
        timestamp: '$timestamp',
        scope: '$mcp_file'.includes('.claude.json') ? 'global' : 'project',
        project: '$project_dir',
        projectName: '$project_name',
        config: config,
        meta: meta
      });
    }

    fs.writeFileSync('$HISTORY_FILE', JSON.stringify(history, null, 2));
  " 2>/dev/null

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
