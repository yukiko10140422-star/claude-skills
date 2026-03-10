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

### mcp-manager
MCPサーバーの統合管理スキル - 追加・削除・一覧・設定変更・推薦・更新確認

| スキル | 説明 |
|--------|------|
| `mcp-manager` | MCPサーバーの統合管理。MCPの追加・削除・一覧表示・設定変更・推薦・更新・履歴管理のリクエスト時にトリガー。"MCP", ".mcp.json", "MCPサーバー", "MCP server",... |

---

*自動生成 by sync-skills.sh*
