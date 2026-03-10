#!/bin/bash
# スキルリポジトリ自動同期スクリプト
# PostToolUse フックから呼ばれ、README更新 → git commit → push を行う

SKILLS_DIR="$HOME/.claude/plugins/marketplaces/local"
cd "$SKILLS_DIR" || exit 0

# ---- README.md 自動生成 ----
generate_readme() {
  local readme="$SKILLS_DIR/README.md"

  cat > "$readme" << 'HEADER'
# Claude Skills Collection

Claude Code カスタムスキル・プラグインコレクション。

## インストール

`~/.claude/settings.json` に以下を追加:

```json
{
  "enabledPlugins": {
    "<plugin-name>@claude-skills": true
  },
  "extraKnownMarketplaces": {
    "claude-skills": {
      "source": {
        "source": "github",
        "repo": "yukiko10140422-star/claude-skills"
      }
    }
  }
}
```

## プラグイン一覧

HEADER

  # 各プラグインディレクトリを走査
  for plugin_dir in "$SKILLS_DIR"/*/; do
    [ -d "$plugin_dir" ] || continue
    local plugin_name=$(basename "$plugin_dir")
    [ "$plugin_name" = "scripts" ] && continue
    [ "$plugin_name" = ".claude-plugin" ] && continue
    [ "$plugin_name" = ".git" ] && continue

    # plugin.json からdescription取得
    local pjson="$plugin_dir/.claude-plugin/plugin.json"
    local desc=""
    if [ -f "$pjson" ]; then
      desc=$(sed -n 's/.*"description".*:.*"\(.*\)".*/\1/p' "$pjson" | head -1)
    fi

    echo "### $plugin_name" >> "$readme"
    [ -n "$desc" ] && echo "$desc" >> "$readme"
    echo "" >> "$readme"

    # スキル一覧
    if [ -d "$plugin_dir/skills" ]; then
      echo "| スキル | 説明 |" >> "$readme"
      echo "|--------|------|" >> "$readme"

      for skill_dir in "$plugin_dir"/skills/*/; do
        [ -d "$skill_dir" ] || continue
        local skill_name=$(basename "$skill_dir")
        local skill_desc=""
        local skill_md="$skill_dir/SKILL.md"

        if [ -f "$skill_md" ]; then
          # frontmatter の description を抽出（最初の100文字）
          skill_desc=$(sed -n '/^description:/{ s/^description: *//; s/\(.\{100\}\).*/\1.../; p; q; }' "$skill_md")
        fi

        echo "| \`$skill_name\` | ${skill_desc:-—} |" >> "$readme"
      done
      echo "" >> "$readme"
    fi
  done

  # フッター
  cat >> "$readme" << 'FOOTER'
---

*自動生成 by sync-skills.sh*
FOOTER
}

# ---- メイン処理 ----

# 変更があるか確認
git add -A
if git diff --cached --quiet; then
  exit 0  # 変更なし
fi

# README 更新
generate_readme
git add -A

# コミットメッセージ生成（変更されたファイルから）
changed_files=$(git diff --cached --name-only)
if echo "$changed_files" | grep -q "SKILL.md"; then
  # スキル名を抽出
  skill_path=$(echo "$changed_files" | grep "SKILL.md" | head -1)
  skill_name=$(echo "$skill_path" | sed 's|.*/skills/\([^/]*\)/.*|\1|')
  msg="スキル更新: $skill_name"
elif echo "$changed_files" | grep -q "plugin.json"; then
  msg="プラグイン設定更新"
elif echo "$changed_files" | grep -q "marketplace.json"; then
  msg="マーケットプレイス設定更新"
else
  msg="スキルリポジトリ更新"
fi

git commit -m "$msg"
git push origin master 2>/dev/null || git push origin main 2>/dev/null
