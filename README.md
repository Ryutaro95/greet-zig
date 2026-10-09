# greet-zig

Zigの学習用に作成したシンプルなCLIアプリです。

## 必要環境

- Zig 0.17.0

## 実行

```sh
zig build run -- help
```

## コマンド

| コマンド | 説明 |
| --- | --- |
| `hello` | 指定した挨拶を表示（`-g` 必須、`-n` 省略時は `World`） |
| `help` | ヘルプを表示 |
| `user:create` | ユーザー作成のデモ（`-n` 必須、保存処理なし） |

```sh
zig build run -- hello -g こんにちは -n Ryutaro
# こんにちは, Ryutaro!

zig build run -- user:create -n Alice
# Creating user: Alice
```

オプションは `-g / --greeting` と `-n / --name` に対応しています。

## スピナーのデモ

```sh
zig run src/spinner_demo.zig
```

## 参考

[How to Build Your Own CLI App in Zig from Scratch](https://rebuild-x.github.io/docs/#/./zig/terminal/cli)
