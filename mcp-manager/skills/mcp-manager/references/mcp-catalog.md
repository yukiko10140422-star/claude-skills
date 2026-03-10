# MCP サーバーカタログ

推薦・追加時に参照するサーバー一覧。各エントリにはカテゴリ、設定例、検出パターンを含む。

---

## Documentation

### context7
- **用途**: ライブラリ/フレームワークの最新ドキュメント参照
- **検出パターン**: `package.json`, `pyproject.toml` 等が存在する全プロジェクト
- **GitHub**: upstash/context7-mcp
- **プラグイン版あり**: claude-plugins-official/context7
- **設定例**:
```json
{
  "context7": {
    "command": "npx",
    "args": ["-y", "@upstash/context7-mcp"]
  }
}
```

---

## Browser Automation

### playwright
- **用途**: ブラウザ操作、E2Eテスト、スクリーンショット取得
- **検出パターン**: `playwright.config.*`, `@playwright/test` in dependencies
- **GitHub**: microsoft/playwright-mcp
- **プラグイン版あり**: claude-plugins-official/playwright
- **設定例**:
```json
{
  "playwright": {
    "command": "npx",
    "args": ["@playwright/mcp@latest"]
  }
}
```

### puppeteer
- **用途**: Chrome ブラウザ操作、スクレイピング
- **検出パターン**: `puppeteer` in dependencies
- **GitHub**: anthropics/anthropic-quickstarts (puppeteer-server)
- **設定例**:
```json
{
  "puppeteer": {
    "command": "npx",
    "args": ["-y", "@anthropic-ai/mcp-server-puppeteer"]
  }
}
```

---

## Database

### supabase
- **用途**: Supabase プロジェクト管理、DB操作
- **検出パターン**: `@supabase/supabase-js` in dependencies, `.env` に `SUPABASE_URL`
- **プラグイン版あり**: claude-plugins-official/supabase
- **設定例 (HTTP)**:
```json
{
  "supabase": {
    "type": "http",
    "url": "https://mcp.supabase.com/mcp"
  }
}
```
- **設定例 (stdio)**:
```json
{
  "supabase": {
    "command": "npx",
    "args": ["-y", "@supabase/mcp-server-supabase", "--supabase-access-token", "${SUPABASE_ACCESS_TOKEN}", "--project-id", "your-project-id"]
  }
}
```

### postgresql (neon)
- **用途**: PostgreSQL 直接操作
- **検出パターン**: `pg`, `postgres`, `@neondatabase/serverless` in dependencies
- **GitHub**: neondatabase/mcp-server-neon
- **設定例**:
```json
{
  "neon": {
    "command": "npx",
    "args": ["-y", "@neondatabase/mcp-server-neon"],
    "env": {
      "NEON_API_KEY": "${NEON_API_KEY}"
    }
  }
}
```

### turso
- **用途**: Turso/LibSQL データベース操作
- **検出パターン**: `@libsql/client` in dependencies
- **GitHub**: tursodatabase/turso-mcp
- **設定例**:
```json
{
  "turso": {
    "command": "npx",
    "args": ["-y", "@tursodatabase/mcp-server-turso"],
    "env": {
      "TURSO_AUTH_TOKEN": "${TURSO_AUTH_TOKEN}"
    }
  }
}
```

---

## Version Control & Project Management

### github
- **用途**: GitHub Issues, PR, Actions, リポジトリ操作
- **検出パターン**: `.git` ディレクトリ, `.github/` ディレクトリ
- **プラグイン版あり**: claude-plugins-official/github
- **設定例 (HTTP)**:
```json
{
  "github": {
    "type": "http",
    "url": "https://api.githubcopilot.com/mcp/",
    "headers": {
      "Authorization": "Bearer ${GITHUB_PERSONAL_ACCESS_TOKEN}"
    }
  }
}
```
- **設定例 (stdio / gh CLI)**:
```json
{
  "github": {
    "command": "gh",
    "args": ["mcp-server"]
  }
}
```

### gitlab
- **用途**: GitLab プロジェクト管理
- **検出パターン**: `.gitlab-ci.yml`
- **プラグイン版あり**: claude-plugins-official/gitlab
- **設定例**:
```json
{
  "gitlab": {
    "type": "http",
    "url": "https://gitlab.com/api/v4/mcp"
  }
}
```

### linear
- **用途**: Linear イシュー管理
- **検出パターン**: Linear 関連の設定やコメント
- **プラグイン版あり**: claude-plugins-official/linear
- **設定例**:
```json
{
  "linear": {
    "type": "http",
    "url": "https://mcp.linear.app/mcp"
  }
}
```

### asana
- **用途**: Asana タスク・プロジェクト管理
- **プラグイン版あり**: claude-plugins-official/asana
- **設定例**:
```json
{
  "asana": {
    "type": "sse",
    "url": "https://mcp.asana.com/sse"
  }
}
```

---

## Cloud & Infrastructure

### vercel
- **用途**: Vercel デプロイ管理
- **検出パターン**: `vercel.json`, `.vercel/`
- **GitHub**: vercel/mcp-adapter
- **設定例**:
```json
{
  "vercel": {
    "command": "npx",
    "args": ["-y", "@vercel/mcp@latest"],
    "env": {
      "VERCEL_ACCESS_TOKEN": "${VERCEL_ACCESS_TOKEN}"
    }
  }
}
```

### cloudflare
- **用途**: Cloudflare Workers, Pages, DNS 管理
- **検出パターン**: `wrangler.toml`, `wrangler.json`
- **GitHub**: cloudflare/mcp-server-cloudflare
- **設定例**:
```json
{
  "cloudflare": {
    "command": "npx",
    "args": ["-y", "@cloudflare/mcp-server-cloudflare"],
    "env": {
      "CLOUDFLARE_API_TOKEN": "${CLOUDFLARE_API_TOKEN}"
    }
  }
}
```

### aws
- **用途**: AWS リソース管理
- **検出パターン**: `serverless.yml`, `cdk.json`, `samconfig.toml`, AWS SDK in dependencies
- **設定例**:
```json
{
  "aws": {
    "command": "npx",
    "args": ["-y", "@anthropic-ai/mcp-server-aws"]
  }
}
```

### docker
- **用途**: Docker コンテナ管理
- **検出パターン**: `Dockerfile`, `docker-compose.yml`
- **GitHub**: docker/mcp-server
- **設定例**:
```json
{
  "docker": {
    "command": "npx",
    "args": ["-y", "@docker/mcp-server"]
  }
}
```

---

## Monitoring & Analytics

### sentry
- **用途**: Sentry エラートラッキング調査
- **検出パターン**: `@sentry/` in dependencies, `sentry.properties`
- **GitHub**: getsentry/sentry-mcp
- **設定例**:
```json
{
  "sentry": {
    "command": "npx",
    "args": ["-y", "@sentry/mcp-server"],
    "env": {
      "SENTRY_AUTH_TOKEN": "${SENTRY_AUTH_TOKEN}"
    }
  }
}
```

### datadog
- **用途**: Datadog モニタリング・ログ調査
- **検出パターン**: `dd-trace`, `datadog` in dependencies
- **設定例**:
```json
{
  "datadog": {
    "command": "npx",
    "args": ["-y", "@datadog/mcp-server"],
    "env": {
      "DD_API_KEY": "${DD_API_KEY}",
      "DD_APP_KEY": "${DD_APP_KEY}"
    }
  }
}
```

---

## Communication

### slack
- **用途**: Slack メッセージ送信、チャンネル管理
- **検出パターン**: `@slack/` in dependencies
- **プラグイン版あり**: claude-plugins-official/slack
- **設定例**:
```json
{
  "slack": {
    "type": "http",
    "url": "https://mcp.slack.com/mcp",
    "oauth": {
      "clientId": "1601185624273.8899143856786",
      "callbackPort": 3118
    }
  }
}
```

### notion
- **用途**: Notion ページ・データベース操作
- **検出パターン**: `@notionhq/client` in dependencies
- **設定例**:
```json
{
  "notion": {
    "command": "npx",
    "args": ["-y", "@notionhq/mcp-server"],
    "env": {
      "NOTION_API_KEY": "${NOTION_API_KEY}"
    }
  }
}
```

---

## File & Memory

### filesystem
- **用途**: ファイルシステム操作（サンドボックス付き）
- **GitHub**: anthropics/anthropic-quickstarts
- **設定例**:
```json
{
  "filesystem": {
    "command": "npx",
    "args": ["-y", "@anthropic-ai/mcp-server-filesystem", "/path/to/allowed/directory"]
  }
}
```

### memory
- **用途**: セッション間のメモリ永続化
- **GitHub**: anthropics/anthropic-quickstarts
- **設定例**:
```json
{
  "memory": {
    "command": "npx",
    "args": ["-y", "@anthropic-ai/mcp-server-memory"]
  }
}
```

---

## Code Analysis

### serena
- **用途**: セマンティックコード分析、シンボル操作
- **プラグイン版あり**: claude-plugins-official/serena
- **検出パターン**: 大規模コードベース、TypeScript/Python プロジェクト
- **設定例**:
```json
{
  "serena": {
    "command": "uvx",
    "args": ["--from", "git+https://github.com/oraios/serena", "serena", "start-mcp-server", "--context", "claude-code", "--project", "/path/to/project"]
  }
}
```

### greptile
- **用途**: コードベース全体の AI 検索
- **プラグイン版あり**: claude-plugins-official/greptile
- **設定例**:
```json
{
  "greptile": {
    "type": "http",
    "url": "https://api.greptile.com/mcp",
    "headers": {
      "Authorization": "Bearer ${GREPTILE_API_KEY}"
    }
  }
}
```

---

## AI & Search

### exa
- **用途**: AI パワードウェブ検索
- **GitHub**: exa-labs/exa-mcp-server
- **設定例**:
```json
{
  "exa": {
    "command": "npx",
    "args": ["-y", "exa-mcp-server"],
    "env": {
      "EXA_API_KEY": "${EXA_API_KEY}"
    }
  }
}
```

---

## Payment

### stripe
- **用途**: Stripe 支払い管理、API 操作
- **検出パターン**: `stripe` in dependencies
- **プラグイン版あり**: claude-plugins-official/stripe
- **設定例**:
```json
{
  "stripe": {
    "type": "http",
    "url": "https://mcp.stripe.com"
  }
}
```

---

## Frameworks

### firebase
- **用途**: Firebase プロジェクト管理
- **検出パターン**: `firebase` in dependencies, `firebase.json`
- **プラグイン版あり**: claude-plugins-official/firebase
- **設定例**:
```json
{
  "firebase": {
    "command": "npx",
    "args": ["-y", "firebase-tools@latest", "mcp"]
  }
}
```

### laravel-boost
- **用途**: Laravel プロジェクト支援
- **検出パターン**: `artisan`, `composer.json` with laravel
- **プラグイン版あり**: claude-plugins-official/laravel-boost
- **設定例**:
```json
{
  "laravel-boost": {
    "command": "php",
    "args": ["artisan", "boost:mcp"]
  }
}
```
