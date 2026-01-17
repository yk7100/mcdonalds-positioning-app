# マクドナルド配置アプリ 🍔

iPhone/Android対応のクルー配置最適化PWAアプリです。

## 🎯 機能

### ✅ クルー管理
- 氏名登録
- カウンタースキル評価 (0-100)
- 厨房スキル評価 (0-100)
- ポテト対応可否
- 免許保有確認
- データ永続化 (オフライン対応)

### 🧮 配置計算
- in人数設定 (2-20人)
- 目標セールス設定 (0-200,000円)
- スキルベース最適配置
- エリア別自動配置:
  - 🏍️ ライダー (10人に1人)
  - 🔥 ポテト (70,000円以上で独立)
  - 🍳 厨房
  - 💻 カウンター
  - 🚗 ドライブスルー
  - その他

### ⚙️ 設定
- データ一括削除
- オフライン動作
- PWA対応 (ホーム画面追加可能)

## 📱 使い方

### Webアプリとして使用
1. ブラウザでURLを開く
2. そのまま使用可能

### PWAアプリとして使用 (推奨)
**iPhone (Safari):**
1. Safariでアプリを開く
2. 共有ボタンをタップ
3. 「ホーム画面に追加」を選択

**Android (Chrome):**
1. Chromeでアプリを開く
2. メニュー → 「ホーム画面に追加」

## 🛠️ 技術スタック

- **Framework**: Flutter 3.35.4
- **Language**: Dart 3.9.2
- **State Management**: Provider 6.1.5+1
- **Storage**: SharedPreferences 2.5.3
- **Platform**: Web (PWA)

## 📦 ビルド方法

```bash
# 依存パッケージインストール
flutter pub get

# Webビルド (本番環境)
flutter build web --release --pwa-strategy=offline-first

# 開発サーバー起動
flutter run -d chrome
```

## 🚀 デプロイ

GitHub Pagesで公開されています。

### ローカルデプロイ
```bash
# ビルド
flutter build web --release

# ローカルサーバー起動
cd build/web
python3 -m http.server 8000
```

## 📄 ライセンス

このプロジェクトはマクドナルド店舗運営支援用に作成されました。

## 🤝 貢献

バグ報告や機能追加の提案は Issue からお願いします。
