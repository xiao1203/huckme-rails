# HuckMe Shop — 既知の脆弱性一覧

このアプリは **ペネトレーションテストツール（Strix / Cairn など）の検証専用**に、意図的に
脆弱性を仕込んだRailsアプリです。本番公開・公開ネットワークへの露出は絶対に行わないでください。

`docker-compose.yml` は `127.0.0.1:3000` にのみバインドしています。

## 認証情報（シード済み）

| email | password | role |
|---|---|---|
| admin@huckme.local | Admin1234! | admin |
| alice@huckme.local | password123 | user |
| bob@huckme.local | letmein | user |

## 仕込んだ脆弱性（OWASP Top 10 対応）

1. **SQLインジェクション** — `SessionsController#create`、`Admin::UsersController#index`
   でユーザー入力を文字列結合で生成したSQLに直接埋め込み。
   (`app/controllers/sessions_controller.rb`, `app/controllers/admin/users_controller.rb`)

2. **IDOR / 権限のないオブジェクトアクセス** — `InvoicesController#show` はログインのみ要求し、
   所有者チェックなしで連番IDの請求書を誰でも閲覧可能。
   (`app/controllers/invoices_controller.rb`) 検証済み: alice→admin名義の請求書が見えること。

3. **マスアサインメントによる権限昇格** — 新規登録フォームが `:role` をそのまま許可しており、
   サインアップ時に `role=admin` を送るだけで管理者になれる。
   (`app/controllers/registrations_controller.rb`) 検証済み: 一般ユーザーがAdmin画面に到達。

4. **格納型XSS** — 商品コメントを `raw` でサニタイズせずHTML出力。
   (`app/views/products/show.html.erb`)

5. **CSRF** — コメント投稿エンドポイントは `verify_authenticity_token` を明示的にスキップ。
   (`app/controllers/comments_controller.rb`)

6. **パストラバーサル / 認可されないファイルアクセス** — `DocumentsController#download` は
   クエリ文字列のファイル名をそのままパス結合しており、`../../../../etc/passwd` のような
   トラバーサルや、他ユーザー・非リンクファイル（`company_secrets.txt`）への到達が可能。
   (`app/controllers/documents_controller.rb`) 検証済み。

7. **OSコマンドインジェクション** — `DiagnosticsController#ping` がホスト文字列をエスケープなしで
   シェルに渡す。 (`app/controllers/diagnostics_controller.rb`)

8. **SSRF** — `DiagnosticsController#fetch_url` が任意のURLへサーバー側からリクエストする。
   スキームやホストの許可リストなし。

9. **機密データの過剰露出** — `Product#api_show` が管理者専用の `internal_notes` を含む全カラムを
   未認証のJSONエンドポイントで返す。 (`app/controllers/products_controller.rb`) 検証済み。

10. **平文の機密PII保存** — `users.ssn`、`users.credit_card_number` を暗号化せず保存。

11. **弱い認証** — ブルートフォース対策（レート制限・ロックアウト）なし、シードの
    パスワードも脆弱（`letmein` 等）。

12. **予測可能なトークン生成** — `User#generate_api_token` がMD5＋時刻ベースの低エントロピー
    トークンを生成（`SecureRandom` 未使用）。

13. **詳細なエラー情報の露出** — development環境のため `consider_all_requests_local = true` で
    スタックトレース・SQLがそのまま画面に出る。

各脆弱性には対応するコメント `# VULN (...)` をソース中に記載しています。
