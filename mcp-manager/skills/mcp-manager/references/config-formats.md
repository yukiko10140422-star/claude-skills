# MCP 設定フォーマット仕様

## 1. プロジェクトスコープ: `<project>/.mcp.json`

プロジェクトルートに配置。`mcpServers` キー配下にサーバーを定義。

```json
{
  "mcpServers": {
    "server-name": {
      // サーバー定義
    }
  }
}
```

## 2. グローバルスコープ: `~/.claude.json`

`projects` → プロジェクトパス → `mcpServers` キー配下。

```json
{
  "projects": {
    "/path/to/project": {
      "mcpServers": {
        "server-name": {
          // サーバー定義
        }
      }
    }
  }
}
```

グローバル（全プロジェクト共通）の場合はトップレベルの `mcpServers` キー:

```json
{
  "mcpServers": {
    "server-name": {
      // サーバー定義
    }
  }
}
```

## 3. プラグインスコープ: `~/.claude/plugins/marketplaces/*/.mcp.json`

プラグインが提供するMCPサーバー。**読み取り専用**。

フォーマットA（ラッパーなし - 多数派）:
```json
{
  "server-name": {
    // サーバー定義
  }
}
```

フォーマットB（`mcpServers`ラッパーあり - 一部）:
```json
{
  "mcpServers": {
    "server-name": {
      // サーバー定義
    }
  }
}
```

## 4. サーバータイプ別スキーマ

### stdio タイプ
ローカルプロセスを起動して標準入出力で通信。

```json
{
  "type": "stdio",
  "command": "npx",
  "args": ["-y", "package-name@latest"],
  "env": {
    "API_KEY": "${ENV_VAR_NAME}"
  }
}
```

`type` フィールドは省略可能（デフォルトが stdio）。

### http タイプ
HTTP エンドポイントに接続。

```json
{
  "type": "http",
  "url": "https://example.com/mcp",
  "headers": {
    "Authorization": "Bearer ${API_TOKEN}"
  }
}
```

### sse タイプ
Server-Sent Events エンドポイントに接続。

```json
{
  "type": "sse",
  "url": "https://example.com/sse"
}
```

### http+oauth タイプ
OAuth 認証付き HTTP 接続。

```json
{
  "type": "http",
  "url": "https://example.com/mcp",
  "oauth": {
    "clientId": "your-client-id",
    "callbackPort": 3118
  }
}
```

## 5. 環境変数展開

`${VAR_NAME}` 構文で環境変数を参照可能。トークンやシークレットは必ずこの形式を使う。

```json
{
  "headers": {
    "Authorization": "Bearer ${MY_API_TOKEN}"
  }
}
```

対応する環境変数は `.env` ファイルまたはシェル環境に設定する。
