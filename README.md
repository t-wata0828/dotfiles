# dotfiles

Mac の開発環境を素早くセットアップするための個人的な設定ファイル集です。

## インストール方法

```bash
git clone https://github.com/yourusername/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

## 含まれる設定

### Shell
- **zsh** - カスタマイズされたプロンプト（Powerlevel10k）
- **sheldon** - プラグインマネージャー
- **asdf** - バージョン管理ツール

### 開発ツール
- **Git** - エイリアスと基本設定
- **Vim** - 基本的な設定
- **tmux** - セッション管理

### Homebrew パッケージ
- 開発に必要な基本的なツール
- 各種ライブラリ
- GUI アプリケーション

### 設定ファイル
- `.zshrc` - シェル設定
- `.gitconfig` - Git設定
- `.tmux.conf` - tmux設定
- `.vimrc` - Vim設定
- `.p10k.zsh` - Powerlevel10k設定
- `config/` - その他の設定ファイル

## 特徴
- セットアップの自動化
- 既存設定のバックアップ
- モジュール化されたセットアップスクリプト
- Brewfile による一括パッケージ管理

## 使用方法
セットアップ後、新しいターミナルセッションを開始するか、以下のコマンドで設定を再読み込みしてください：

```bash
source ~/.zshrc
```

