#!/bin/bash

DOTFILES=$(cd $(dirname $0)/.. && pwd)

# シンボリックリンクを作成する関数
create_symlink() {
    local src=$1
    local dst=$2

    if [ -e "$dst" ]; then
        echo "バックアップを作成: $dst -> $dst.backup"
        mv "$dst" "$dst.backup"
    fi

    echo "シンボリックリンクを作成: $src -> $dst"
    ln -sf "$src" "$dst"
}

# 各設定ファイルのシンボリックリンクを作成
create_symlink "$DOTFILES/.zshrc" "$HOME/.zshrc"
create_symlink "$DOTFILES/.vimrc" "$HOME/.vimrc"
create_symlink "$DOTFILES/.tmux.conf" "$HOME/.tmux.conf"
create_symlink "$DOTFILES/.gitconfig" "$HOME/.gitconfig"

# 必要に応じてディレクトリを作成
mkdir -p "$HOME/.config"

# configディレクトリ内の設定
for config in "$DOTFILES/config/"*; do
    name=$(basename "$config")
    if [ -d "$config" ]; then
        mkdir -p "$HOME/.config/$name"
        for file in "$config/"*; do
            if [ -f "$file" ]; then
                base_name=$(basename "$file")
                create_symlink "$file" "$HOME/.config/$name/$base_name"
            fi
        done
    elif [ -f "$config" ]; then
        create_symlink "$config" "$HOME/.config/$name"
    fi
done

# Neovimの設定（vimrcを使用）
if [ -f "$DOTFILES/.vimrc" ]; then
    mkdir -p "$HOME/.config/nvim"
    echo "let g:python3_host_prog = '$(which python3)'" > "$HOME/.config/nvim/init.vim"
    echo "set runtimepath^=~/.vim runtimepath+=~/.vim/after" >> "$HOME/.config/nvim/init.vim"
    echo "let &packpath = &runtimepath" >> "$HOME/.config/nvim/init.vim"
    echo "source ~/.vimrc" >> "$HOME/.config/nvim/init.vim"
    echo "Neovimの設定を作成しました"
fi

echo "シンボリックリンクの作成が完了しました"