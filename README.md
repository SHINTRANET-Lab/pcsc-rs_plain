# pcsc-rs_plain

[pcsc-rs](https://github.com/SHINTRANET-Lab/pcsc-rs)（mimizk-rs）から、**TLS と自己更新を取り除いた**、最小の PC Status クライアントです。

TLS が使えない、または重すぎる機器のための版です。サーバーとは、平文の `ws://` で話します。`wss://` が必要なサーバーへは、同じ LAN の PC で動かす中継（[pcsc-rs_relay](https://github.com/SHINTRANET-Lab/pcsc-rs_relay)）を通します。

```
この機器 ──ws://──▶ relay（PC）──wss://──▶ PC Status サーバー
```

## 向いている機器

- MIPS などの、`ring`（rustls の暗号部品）が使えない機器
- Windows XP など、現代の TLS・証明書が使えない OS
- メモリや、ストレージの小さい機器

通常の PC やスマホなら、TLS を内蔵した、本家の pcsc-rs を使ってください。

## 本家との違い

| | pcsc-rs | pcsc-rs_plain |
|---|---|---|
| 接続 | `ws://`・`wss://` | **`ws://` のみ** |
| TLS（native-tls / rustls） | あり | **なし** |
| 自己更新 | あり | **なし**（手で入れ替え） |
| 取得する情報 | 同じ | 同じ |
| PCSC_HIDE | 対応 | 対応 |

`wss://` を指定すると、「TLS 機能が有効でない」というエラーで、接続できません。

## 設定

環境変数、または実行ディレクトリの `.env` で、設定します。

| 変数 | 内容 |
|---|---|
| `PCSC_URI` | 接続先。`ws://relay-host:8080` のように、`ws://` で指定します |
| `PASS` | PC Status のパスワード |
| `PCSC_HIDE` | サーバーに送らない項目（カンマ区切り）。例：`gpu,temperature` |
| `DEV_MODE` | 開発用の表示 |

`.env` の例：

```
PCSC_URI=ws://192.168.1.10:8080
PASS=secret
PCSC_HIDE=gpu_usage
```

使用率が読めない GPU は、`gpu_usage` が自動で非公開になります（本家と同じ動きです）。

## ビルド

```
cargo build --release
```

Windows XP 向け：

```
cargo build --release --target i686-pc-windows-msvc --no-default-features --features xp
```

MIPS など（Tier 3 のターゲット）は、nightly の `-Zbuild-std` が要ります。

```
cargo +nightly build --release -Zbuild-std=std,panic_abort --target mipsel-unknown-linux-musl
```

## 取得できる情報

CPU、メモリ、ストレージ、GPU、温度、バッテリー、稼働時間、ロードアベレージ、I/O 待ち。機器によって、取れる項目は変わります。詳しくは、本家の README を参照してください。

## ライブラリとして

`pcsc_rs::Monitor` は、システムの情報を、1 秒ごとに集めます。表示だけに使うこともできます。

## 由来

[Zel9278/pcsc-rs](https://github.com/Zel9278/pcsc-rs) を元にした、[SHINTRANET-Lab/pcsc-rs](https://github.com/SHINTRANET-Lab/pcsc-rs) の派生版です。
