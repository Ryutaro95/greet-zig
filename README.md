# greet-zig

Zigを学ぶために作成した、小さなコマンドラインアプリ

## 開発環境

- Zig 0.17.0

## ビルドと実行

プロジェクトのルートで実行します。

```sh
zig build
./zig-out/bin/greet-zig help
```

ビルドと実行をまとめて行うこともできます。`--` より後ろの引数がアプリに渡されます。

```sh
zig build run -- help
```

### ビルド済みの実行ファイルを使う

一度 `zig build` した後は、実行ファイルを直接起動できます。こちらは起動時に再ビルドしません。ソースを変更した場合は、もう一度 `zig build` してください。

```sh
./zig-out/bin/greet-zig hello --greeting Hello --name Alice
# Hello, Alice!

./zig-out/bin/greet-zig user:create -n Bob
# Creating user: Bob
```

### ソースファイルから直接実行する

`zig run` でソースをコンパイルして、そのまま実行する方法もあります。

```sh
zig run src/main.zig -- hello -g Hi -n Alice
# Hi, Alice!
```

## コマンド

### hello

指定した挨拶と名前を表示します。`--greeting` は必須で、`--name` を省略すると `World` を使います。

```sh
zig build run -- hello --greeting Hi --name Alice
# Hi, Alice!

zig build run -- hello -g こんにちは -n Ryutaro
# こんにちは, Ryutaro!

zig build run -- hello --greeting Hi
# Hi, World!

zig build run -- hello --greeting こんにちは --name "Ryutaro"
# こんにちは, Ryutaro!

zig build run -- hello -g "Good morning" -n "Alice Smith"
# Good morning, Alice Smith!
```

空白を含む値は引用符で囲み、1つの引数として渡します。

対応するターミナルでは、挨拶が緑色で表示されます。

### help

コマンドとオプションの使い方を表示します。

```sh
zig build run -- help
```

### user:create

コロンを含むコマンド名の例です。`--name` は必須です。現在はメッセージを表示するデモで、ユーザー情報は保存しません。

```sh
zig build run -- user:create --name Alice
# Creating user: Alice
```

`user create` のように空白で区切ったサブコマンドには対応していません。

## オプション

| 長い名前             | 短縮形       | 用途                                        |
| -------------------- | ------------ | ------------------------------------------- |
| `--greeting <value>` | `-g <value>` | `hello` の挨拶。必須                        |
| `--name <value>`     | `-n <value>` | `hello` の宛名、または `user:create` の名前 |

現在のパーサーは、オプション名と値を空白で区切る形式に対応しています。`--name=Alice` や、`-` で始まる値には対応していません。登録済みのオプションは共通の一覧から検索し、コマンド別に使用可能なオプションを制限する処理は実装していません。

## エラー

コマンドは成功時に値を返さず、失敗時にエラーを返します。CLI側では `try` を使ってエラーを呼び出し元へ伝えます。

| 実行例                                | エラー                                |
| ------------------------------------- | ------------------------------------- |
| `zig build run`                       | `NoArgsProvided`                      |
| `zig build run -- unknown`            | `UnknownCommand`                      |
| `zig build run -- hello`              | `MissingRequiredOption`               |
| `zig build run -- hello --greeting`   | `EmtpyGreeting`（現在のコードの表記） |
| `zig build run -- user:create --name` | `EmptyName`                           |

現在はデバッグ表示が有効です。出力例のほかに、検出したコマンドやオプションが表示されます。表示には `std.debug.print` を使っているため、出力先は標準エラーです。

## スピナーのデモ

```sh
zig run src/spinner_demo.zig
```

約2秒間、同じ行で記号が切り替わり、最後に `Done: Processing...` と表示されます。スピナーは `tick()` を呼ぶたびに表示を更新する仕組みです。

## ファイル構成

```text
build.zig             ビルド・実行の設定
build.zig.zon         パッケージ情報
src/
  main.zig            コマンド・オプションの登録と起動
  cli.zig             型定義、引数解析、色付き表示、スピナー
  commands.zig        各コマンドの処理
  spinner_demo.zig    スピナーの単独デモ
```

## 学習元

[How to Build Your Own CLI App in Zig from Scratch](https://rebuild-x.github.io/docs/#/./zig/terminal/cli) を参考にしています。型名をZigの慣習に合わせ、引数取得と待機処理をZig 0.17のAPIに合わせて調整しています。また、コマンドの成功・失敗を `bool` で返す設計から、エラーを返す設計へ変更しています。
