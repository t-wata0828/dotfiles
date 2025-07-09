#!/bin/bash

set -e

# 現在のディレクトリを取得
DOTFILES=$(cd $(dirname $0) && pwd)

echo "=== Dotfiles セットアップ開始 ==="
echo "Dotfiles ディレクトリ: $DOTFILES"

# macOSの設定
if [ -f "$DOTFILES/scripts/setup_mac.sh" ]; then
    echo "macOSの設定を適用中..."
    source "$DOTFILES/scripts/setup_mac.sh"
fi

# Homebrewのセットアップ
if [ -f "$DOTFILES/scripts/setup_brew.sh" ]; then
    echo "Homebrewのセットアップ中..."
    source "$DOTFILES/scripts/setup_brew.sh"
fi

# シンボリックリンクの作成
if [ -f "$DOTFILES/scripts/setup_symlinks.sh" ]; then
    echo "シンボリックリンクを作成中..."
    source "$DOTFILES/scripts/setup_symlinks.sh"
fi

# 設定ファイルの配置
echo "設定ファイルの配置中..."
if [ -f "$DOTFILES/.zshrc" ]; then
    ln -sf "$DOTFILES/.zshrc" "$HOME/.zshrc"
    echo "  .zshrc をリンクしました"
fi

if [ -f "$DOTFILES/.gitconfig" ]; then
    ln -sf "$DOTFILES/.gitconfig" "$HOME/.gitconfig"
    echo "  .gitconfig をリンクしました"
fi

echo "=== セットアップが完了しました！ ==="
echo "新しい設定を適用するには、ターミナルを再起動するか 'source ~/.zshrc' を実行してください。"
