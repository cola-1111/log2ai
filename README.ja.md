# log2ai

ターミナルセッションを記録し、秘密情報をマスキングした出力をクリップボードへコピーするCLIツールです。

## 概要

`log2ai` は、ターミナルの入出力をローカルファイルへ記録し、最後に実行したコマンドとその出力を秘密情報をマスキングした状態で表示・コピーできるCLIツールです。Claude Code、Codex、その他のAIツールへ安全にターミナルのコンテキストを渡すために設計されています。

**これはWSL2専用のMVPです。**

## 必要環境

- WSL2 (Ubuntu)
- Bash
- `script` コマンド（通常プリインストール済み、`bsdutils`パッケージ）
- `clip.exe`（クリップボードコピー用、WSL interop経由で利用可能）

## インストール

```bash
git clone https://github.com/cola-1111/log2ai.git
cd log2ai
bash install.sh
```

`~/.local/bin/log2ai` にインストールされます。`~/.local/bin` がPATHに含まれていない場合、インストーラーが追加方法を表示します。

## 使い方

### 記録の開始

```bash
# ターミナル1
log2ai start
```

新しい記録セッションが開始されます。通常どおり作業してください。

```bash
npm run build
python manage.py migrate
curl https://api.example.com/status
```

`exit` を入力するか `Ctrl+D` を押すと記録が終了します。

### セッション一覧の表示

```bash
# ターミナル2（または記録終了後）
log2ai list
```

出力例：

```
SESSION ID                  STATUS    STARTED AT
20260712-201530-24873        active    2026-07-12 20:15:30
20260712-201605-25110        stopped   2026-07-12 20:16:05
```

`*` マーカーは最新セッションを示します。

### 最後のコマンドを表示（マスキング済み）

```bash
log2ai show
log2ai show --session 20260712-201530-24873
```

### セッション全体を表示（マスキング済み）

```bash
log2ai show --all
log2ai show --session 20260712-201530-24873 --all
```

### クリップボードへコピー（マスキング済み）

```bash
log2ai copy
log2ai copy --session 20260712-201530-24873
log2ai copy --session 20260712-201530-24873 --all
```

### 複数ターミナルでの利用

複数のターミナルで同時に `log2ai start` を実行できます。各セッションには一意のセッションID（タイムスタンプ＋PID）が割り当てられます。`log2ai list` で全セッションを確認し、`--session <ID>` で特定のセッションを指定してください。

### セッションID

セッションIDは `YYYYMMDD-HHMMSS-PID` 形式（例：`20260712-201530-24873`）です。開始時刻とプロセスIDから生成されるため、同じ秒に複数セッションを開始しても衝突しません。

## ログ保存場所

ログは以下に保存されます：

```
${XDG_STATE_HOME:-$HOME/.local/state}/log2ai/sessions/
```

ディレクトリ権限：`700`、ファイル権限：`600`

**生ログには秘密情報が含まれる可能性があります。** 出力には必ず `log2ai show` または `log2ai copy` を使用してください。

## 秘密情報のマスキング

`show` と `copy` の出力で以下がマスキングされます：

- KEY、SECRET、TOKEN、PASS、PASSWORD、PASSWD、DATABASE_URL、ACCESS_TOKEN、CLIENT_SECRET を含む環境変数
- Authorizationヘッダー（Bearer、Basic）
- OpenAI APIキー（`sk-...`）
- Anthropic APIキー（`sk-ant-...`）
- GitHub Personal Access Token（`ghp_...`）
- GitHub fine-grained token（`github_pat_...`）
- AWS Access Key ID（`AKIA...`）
- JWT（`eyJ...`）
- npmトークン（`npm_...`）
- 接続URLのパスワード（postgres://、mysql://、redis://）
- PEM形式の秘密鍵ブロック

### 制限事項

- マスキングはベストエフォートです。すべての秘密情報を検出できるわけではありません。
- カスタム形式の秘密情報は対象外です。
- AIツールや第三者に渡す前に、必ず出力内容を確認してください。

## AIに渡す前に

**`log2ai show` や `log2ai copy` の出力をAIアシスタントに渡す前に、必ず内容を確認してください。** マスキングはリスクを軽減しますが、すべての機密情報の完全な除去を保証するものではありません。

## アンインストール

```bash
rm -f ~/.local/bin/log2ai
rm -rf "${XDG_STATE_HOME:-$HOME/.local/state}/log2ai"
```

## コマンド一覧

| コマンド | 説明 |
|---------|------|
| `start` | ターミナルセッションの記録を開始 |
| `list` | 記録済みセッションの一覧を表示 |
| `show` | セッションログを表示（マスキング済み） |
| `copy` | セッションログをWindowsクリップボードへコピー（マスキング済み） |
| `help` | ヘルプを表示 |
| `version` | バージョンを表示 |

## オプション

| オプション | 対象コマンド | 説明 |
|-----------|-------------|------|
| `--session <ID>` | show, copy | 特定のセッションを指定 |
| `--all` | show, copy | 最後のコマンドではなくセッション全体を対象にする |

## MVPの制約

- WSL2専用（macOS、Linuxデスクトップ、ネイティブWindowsは非対応）
- Bash専用（Zsh固有の対応なし）
- AI API連携なし
- 設定ファイルなし
- 自動ログローテーション・クリーンアップなし
- シェル補完なし
- コマンド境界の検出にはBashのDEBUGトラップを使用しており、複雑な複数行コマンドやサブシェルは完全には取得できない場合があります

## ライセンス

MIT License。[LICENSE](LICENSE) を参照してください。
