---
name: mcp-manager
description: MCPサーバーの統合管理。MCPの追加・削除・一覧表示・設定変更・推薦・更新・履歴管理のリクエスト時にトリガー。"MCP", ".mcp.json", "MCPサーバー", "MCP server", "~/.claude.json のMCP設定", "MCPを追加", "MCPを削除", "おすすめのMCP", "MCP一覧", "MCP管理", "MCP更新", "MCPを最新に", "MCP履歴", "前に使ったMCP", "MCPアーカイブ" 等のキーワードで起動。具体的なサーバー名（playwright, supabase, context7等）への言及でも起動。
tools: Read, Bash, Glob, Grep, WebSearch, WebFetch, Write, Edit
---

# MCP Manager

MCPサーバーの統合管理スキル。3つのスコープ（プロジェクト・グローバル・プラグイン）を横断的に管理する。

## スコープ概要

| スコープ | 設定ファイル | 編集可否 |
|---------|-------------|---------|
| **プロジェクト** | `<project>/.mcp.json` → `mcpServers` キー配下 | ✅ 読み書き可 |
| **グローバル** | `~/.claude.json` → `mcpServers` or `projects.<path>.mcpServers` | ✅ 読み書き可 |
| **プラグイン** | `~/.claude/plugins/marketplaces/*/external_plugins/*/.mcp.json` | ❌ 読み取り専用 |

詳細なフォーマット仕様は [references/config-formats.md](references/config-formats.md) を参照。

## ワークフロー判定

ユーザーのリクエストに応じて以下のワークフローを実行する:

| リクエスト例 | ワークフロー |
|-------------|------------|
| 「MCP一覧」「MCPサーバーを見せて」 | → 一覧/状態確認 |
| 「〇〇MCPを追加して」「〇〇を入れて」 | → 追加 |
| 「〇〇MCPを削除して」「〇〇を外して」 | → 削除 |
| 「〇〇の設定を変更」「引数を変えて」 | → 設定変更 |
| 「おすすめのMCPは？」「何を入れるべき？」 | → 推薦 |
| 「MCPの更新確認」「最新バージョンは？」 | → 更新確認/更新実行 |
| 「MCPを最新にして」「アップデートして」 | → 更新実行 |
| 「前に使ったMCPは？」「MCP履歴」 | → 履歴/アーカイブ |
| 「〇〇を復元して」「以前の設定に戻して」 | → 履歴から復元 |

---

## ワークフロー1: 一覧/状態確認

3スコープから全MCPサーバー情報を収集し、統合一覧を表示する。

### 手順

1. **プロジェクトスコープ**: カレントディレクトリの `.mcp.json` を読み取る
2. **グローバルスコープ**: `~/.claude.json` から `mcpServers` と `projects.*.mcpServers` を読み取る
3. **プラグインスコープ**: `~/.claude/plugins/marketplaces/*/external_plugins/*/.mcp.json` を全てスキャン
4. **統合テーブル出力**:

```markdown
## MCP サーバー一覧

### プロジェクトスコープ (<project>/.mcp.json)
| サーバー名 | タイプ | 接続先/コマンド |
|-----------|--------|---------------|
| serena | stdio | uvx serena start-mcp-server |
| github | stdio | gh mcp-server |

### グローバルスコープ (~/.claude.json)
| サーバー名 | タイプ | 接続先/コマンド | 対象プロジェクト |
|-----------|--------|---------------|---------------|
| (none) | - | - | - |

### プラグインスコープ (読み取り専用)
| サーバー名 | タイプ | 接続先/コマンド | プラグイン |
|-----------|--------|---------------|----------|
| context7 | stdio | npx @upstash/context7-mcp | claude-plugins-official |
```

5. **重複検出**: 同名サーバーが複数スコープに存在する場合は警告を表示

---

## ワークフロー2: 追加

### 手順

1. **サーバー特定**: ユーザーが指定したサーバー名を [references/mcp-catalog.md](references/mcp-catalog.md) で検索
2. **カタログにない場合**: WebSearch で `"<server-name> MCP server"` を検索して設定情報を取得
3. **スコープ選択**: ユーザーに確認（デフォルト: プロジェクト）
   - プロジェクト固有のサーバー → プロジェクトスコープ
   - 全プロジェクト共通 → グローバルスコープ
4. **設定生成**: カタログの設定例をベースに生成
5. **シークレット確認**: トークン等が必要な場合は `${ENV_VAR}` パターンを使用し、環境変数の設定方法を案内
6. **JSON書き込み**: 対象ファイルを読み取り → サーバーエントリを追加 → 書き込み
7. **履歴に記録**: 追加した設定とメタ情報を `~/.claude/mcp-history.json` に保存（ワークフロー7参照）
8. **プラグイン版チェック**: カタログでプラグイン版が存在する場合は、プラグインでの追加も選択肢として提示

### 重要事項
- 既存の `.mcp.json` が存在しない場合は新規作成
- 既存サーバーと同名の場合は上書き確認
- トークンを平文で書かない（必ず `${ENV_VAR}` を使用）

---

## ワークフロー3: 削除

### 手順

1. **一覧表示**: ワークフロー1を実行して現在の状態を表示
2. **対象選択**: ユーザーが削除したいサーバーを確認
3. **スコープ確認**: 対象サーバーが存在するスコープを特定
   - プラグインスコープの場合: 「プラグインのMCPサーバーは直接削除できません。プラグインを無効化してください。」と案内
4. **履歴に保存**: 削除前の設定とメタ情報を `~/.claude/mcp-history.json` にアーカイブ（ワークフロー7参照）
5. **設定から除去**: 対象ファイルを読み取り → サーバーエントリを削除 → 書き込み
6. **確認**: 削除後の状態を表示（「履歴から復元できます」と案内）

---

## ワークフロー4: 設定変更

### 手順

1. **対象特定**: サーバー名とスコープを特定
2. **現在設定表示**: 現在の設定JSONをそのまま表示
3. **変更内容確認**: ユーザーの変更リクエストを確認
4. **履歴に保存**: 変更前の設定を `~/.claude/mcp-history.json` にアーカイブ（ロールバック用）
5. **部分更新**: 対象のフィールドのみ更新（全体上書きではなく）
6. **確認**: 変更後の設定を表示

---

## ワークフロー5: 推薦

プロジェクトのテックスタックを分析し、最適なMCPサーバーを推薦する。

### Phase 1: テックスタック検出

以下を分析:
- `package.json` → dependencies, devDependencies
- `pyproject.toml` / `requirements.txt` → Python パッケージ
- `Cargo.toml` → Rust crates
- `go.mod` → Go モジュール
- `.github/` → GitHub Actions
- `Dockerfile`, `docker-compose.yml` → Docker 使用
- `vercel.json`, `.vercel/` → Vercel デプロイ
- `firebase.json` → Firebase 使用
- `wrangler.toml` → Cloudflare 使用
- `.env*` ファイル → SUPABASE_, STRIPE_, SENTRY_ 等の環境変数プレフィックス

### Phase 2: カタログマッチング

[references/mcp-catalog.md](references/mcp-catalog.md) の検出パターンと照合:
- 依存パッケージ名 → 対応サーバー
- 設定ファイル → 対応サーバー
- 環境変数プレフィックス → 対応サーバー

### Phase 3: 既存インストールチェック

3スコープの既存サーバーと照合し、既にインストール済みのものを除外。

### Phase 4: Web 検索補完（カタログ不足時）

カタログに載っていない依存パッケージについて、WebSearch で MCP サーバーの存在を確認。

### Phase 5: 推薦結果出力

```markdown
## おすすめ MCP サーバー

### 検出されたテックスタック
- Next.js + TypeScript
- Supabase
- Tailwind CSS

### 推薦一覧
| サーバー名 | 理由 | インストール済み | プラグイン版 |
|-----------|------|---------------|------------|
| context7 | ライブラリドキュメント参照 | ❌ | ✅ あり |
| playwright | E2Eテスト | ❌ | ✅ あり |
| supabase | Supabase操作 | ✅ 済み | ✅ あり |

インストールしたいサーバーを教えてください（例: 「context7を追加して」）
```

---

## ワークフロー6: 更新確認/更新実行

### Phase 1: バージョン情報収集

1. **stdioタイプのサーバーを抽出**: 3スコープすべてからコマンドが `npx`/`uvx` のサーバーを収集
2. **現在のバージョン指定を解析**:
   - `@latest` → 常に最新（更新不要だが最新バージョン番号は表示）
   - `@1.2.3` → 固定バージョン（更新候補）
   - バージョン指定なし → latest扱い
3. **最新バージョン取得**:
   - npm パッケージ: `npm view <package> version` で最新版確認
   - uvx パッケージ: `pip index versions <package>` または WebSearch で確認
   - GitHub リポジトリ: WebFetch で `https://api.github.com/repos/<owner>/<repo>/releases/latest` を確認

### Phase 2: 比較テーブル出力

```markdown
## MCP サーバー更新状況
| サーバー名 | スコープ | 現在 | 最新 | 状態 |
|-----------|---------|------|------|------|
| playwright | プロジェクト | @latest | 1.50.0 | ✅ 最新 |
| context7 | プラグイン | (latest) | 1.2.3 | ✅ 最新 |
| supabase | プロジェクト | @1.0.0 | 1.2.0 | ⬆️ 更新可能 |

更新したいサーバーを選んでください（「すべて更新」も可）
```

### Phase 3: 更新実行（ユーザーが指定した場合）

1. **対象サーバーの設定を読み取り**
2. **args配列内のパッケージ名バージョンを最新に書き換え**:
   - `package@1.0.0` → `package@1.2.0`
   - `package@latest` → そのまま（既に最新追従）
3. **設定ファイルに書き戻し**
4. **履歴に記録**: 更新前の設定をアーカイブに保存（ワークフロー7参照）
5. **変更サマリー出力**

### 注意事項
- プラグインスコープのサーバーは更新不可（読み取り専用）→ プラグイン自体の更新を案内
- `@latest` 指定のサーバーは設定変更不要だが、互換性情報があれば表示
- 更新前に必ず現在の設定を履歴に保存

---

## ワークフロー7: 履歴/アーカイブ

過去に使用したMCPサーバーの設定とメタ情報を永続保管し、いつでも復元できるようにする。

### 履歴ファイル

`~/.claude/mcp-history.json` に保管（プロジェクト横断で共有）。

```json
{
  "version": 1,
  "entries": [
    {
      "id": "uuid-or-timestamp",
      "serverName": "supabase",
      "action": "added",
      "timestamp": "2026-03-10T12:00:00Z",
      "scope": "project",
      "project": "/c/dev/software/projectcontact",
      "config": {
        "command": "npx",
        "args": ["-y", "@supabase/mcp-server-supabase", "--project-id", "xxx"]
      },
      "meta": {
        "packageName": "@supabase/mcp-server-supabase",
        "packageVersion": "1.2.0",
        "serverType": "stdio",
        "category": "Database",
        "description": "Supabase プロジェクト管理、DB操作",
        "catalogRef": "supabase",
        "pluginAvailable": true,
        "requiredEnvVars": ["SUPABASE_ACCESS_TOKEN"],
        "tags": ["database", "supabase", "postgresql"]
      },
      "notes": ""
    }
  ]
}
```

### 履歴への記録タイミング

以下のワークフロー実行時に自動で履歴エントリを追加:

| アクション | `action` フィールド | 記録内容 |
|-----------|-------------------|---------|
| ワークフロー2: 追加 | `"added"` | 追加した設定とメタ情報 |
| ワークフロー3: 削除 | `"removed"` | 削除前の設定（復元用） |
| ワークフロー4: 設定変更 | `"modified"` | 変更前の設定（ロールバック用） |
| ワークフロー6: 更新実行 | `"updated"` | 更新前の設定 + 新バージョン情報 |

### メタ情報の収集方法

追加/記録時に以下のメタ情報を自動収集:

1. **packageName**: args配列からnpmパッケージ名を抽出
2. **packageVersion**: `npm view <package> version` で取得、または args 内のバージョン指定から抽出
3. **serverType**: 設定の `type` フィールド、または `command` 存在で `stdio` と判定
4. **category**: [references/mcp-catalog.md](references/mcp-catalog.md) から照合
5. **description**: カタログの用途説明、またはカタログにない場合は WebSearch で取得
6. **catalogRef**: カタログ内のサーバーID（カタログにあれば）
7. **pluginAvailable**: プラグイン版の存在有無
8. **requiredEnvVars**: 設定内の `${VAR}` パターンから抽出
9. **tags**: カテゴリに基づく自動タグ + ユーザーが追加したカスタムタグ

### ワークフロー7a: 履歴一覧表示

「前に使ったMCPは？」「MCP履歴を見せて」

1. `~/.claude/mcp-history.json` を読み取り
2. テーブル形式で表示（新しい順）:

```markdown
## MCP 使用履歴

| # | サーバー名 | アクション | 日時 | スコープ | プロジェクト | カテゴリ |
|---|-----------|-----------|------|---------|------------|---------|
| 1 | supabase | added | 2026-03-10 | project | projectcontact | Database |
| 2 | playwright | removed | 2026-03-08 | project | myapp | Browser |
| 3 | context7 | added | 2026-03-05 | global | (全体) | Documentation |

詳細を見たいエントリの番号を指定してください。
復元したい場合は「#2を復元して」のように指示してください。
```

3. **フィルタ対応**: プロジェクト別、カテゴリ別、アクション別で絞り込み可能
4. **詳細表示**: 番号指定で完全な設定JSONとメタ情報を表示

### ワークフロー7b: 履歴から復元

「#2を復元して」「以前のsupabase設定に戻して」

1. 履歴エントリを特定（番号 or サーバー名で検索）
2. 保存された設定を表示し、復元先スコープを確認
3. ワークフロー2（追加）と同じ手順で設定を書き込み
4. 復元アクションも履歴に記録（`action: "restored"`）

### ワークフロー7c: 履歴の管理

- **タグ追加**: `「#3にtag:必須を追加して」` → エントリの tags に追加
- **メモ追加**: `「#3にメモ: 本番用設定」` → エントリの notes に追記
- **履歴クリーンアップ**: 古いエントリの削除（確認付き）
- **エクスポート**: 特定プロジェクトの全MCP設定を1つのJSONとして出力

### 初期化

`~/.claude/mcp-history.json` が存在しない場合:
1. 空の履歴ファイルを作成: `{"version": 1, "entries": []}`
2. **既存サーバーの自動インポート**: 現在3スコープに存在する全サーバーを `action: "imported"` として履歴に追加（初回のみ）

---

## セキュリティガイドライン

すべてのワークフローで以下を遵守:

1. **トークン平文禁止**: API キー、トークン、パスワードは必ず `${ENV_VAR}` 形式で参照
2. **環境変数案内**: 新しいトークンが必要な場合は環境変数の設定方法を案内
3. **`.gitignore` チェック**: `.mcp.json` にシークレットが含まれる場合は `.gitignore` への追加を提案
4. **プラグイン読み取り専用**: プラグインスコープの設定は絶対に変更しない

## Windows パス注意事項

- Windows 環境では `~` は `/c/Users/<username>` に展開される
- パスのセパレータは `/`（bash 環境）を使用
- `jq` がない場合は Python や Node.js で JSON 操作を代替
