# HuckMe Shop — 意図的に脆弱なRailsラボ

これは **ペネトレーションテストツール（[Strix](https://github.com/usestrix/strix)、
[Cairn](https://github.com/oritera/Cairn) など）の動作検証専用**に作られた、
ECサイト風の見た目を持つRailsアプリです。認証・検索・レビュー投稿・ファイルダウンロード・
管理画面など一通りの機能を揃えつつ、各機能に意図的な脆弱性を仕込んでいます。

> ⚠️ **このアプリは本番公開・公開ネットワークへの露出を想定していません。**
> 自分が所有・管理する隔離されたローカル環境でのみ使用してください。

## 目的

- AIペネトレーションテストツールが、OWASP Top 10相当の脆弱性をどの程度・どのように
  検出・悪用（PoC生成）できるかを検証するためのターゲットを用意すること
- 本物のECサイトに近い見た目・データ量にすることで、ツールが実運用アプリに近い条件で
  どう振る舞うかを確認しやすくすること

## 含まれる脆弱性

SQLインジェクション、IDOR（権限のないオブジェクトアクセス）、マスアサインメントによる
権限昇格、格納型XSS、CSRF、パストラバーサル、OSコマンドインジェクション、SSRF、
機密データの過剰露出、平文PII保存、弱い認証・予測可能なトークンなど13種類。
各脆弱性の詳細・該当ファイルは **[VULNERABILITIES.md](VULNERABILITIES.md)** を参照してください。

## 使い方

### 1. 起動

Docker が動いていれば以下だけで起動します（初回のみ `db:prepare` と `db:seed` が自動実行されます）。

```bash
docker compose up -d --build
```

起動後、`http://localhost:3000` でアクセスできます（`127.0.0.1` にのみバインドされており、
外部ネットワークには公開されません）。

停止:

```bash
docker compose down
```

### 2. ログイン情報（シード済み）

| email | password | role |
|---|---|---|
| admin@huckme.local | Admin1234! | admin |
| alice@huckme.local | password123 | user |
| bob@huckme.local | letmein | user |

### 3. ペネトレーションテストツールで検証する

Strix（OpenAI APIキー使用）、Cairn（Claude Codeをワーカーとして使用）それぞれの
具体的なインストール・設定・実行コマンドは **[PENTEST_TOOLS_SETUP.md](PENTEST_TOOLS_SETUP.md)**
にまとめています。基本的な流れは:

1. 上記コマンドでラボを起動する
2. Strix / Cairn をインストールし、LLM（OpenAI または Claude Code）を設定する
3. `http://localhost:3000` をターゲットに指定してスキャンを実行する
4. 検出結果を `VULNERABILITIES.md` の一覧と比較し、ツールの検出率・PoCの質を評価する

## 技術構成

- Ruby on Rails 7.2 / SQLite / Puma
- Docker / Docker Compose
- 認証: `has_secure_password`（bcrypt）

## 注意事項

- APIキー（OpenAI等）やLLMの利用上限は事前に設定してください。大量のリクエストが発生します。
- `config/master.key` は `.gitignore` で除外されています。リポジトリをクローンした環境で
  アプリを起動するには、同じ `master.key` が必要です（Rails標準の暗号化資格情報の仕組み）。
