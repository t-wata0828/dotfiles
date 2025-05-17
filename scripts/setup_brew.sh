#!/bin/bash

echo "Homebrewのセットアップを開始します..."

# Homebrewがインストールされているか確認
if ! command -v brew &> /dev/null; then
    echo "Homebrewをインストールします..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Homebrewのパスを設定
    if [[ $(uname -m) == "arm64" ]]; then
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> $HOME/.zprofile
        eval "$(/opt/homebrew/bin/brew shellenv)"
    else
        echo 'eval "$(/usr/local/bin/brew shellenv)"' >> $HOME/.zprofile
        eval "$(/usr/local/bin/brew shellenv)"
    fi
else
    echo "Homebrewは既にインストールされています"
fi

# Homebrewをアップデート
brew update
brew upgrade

# Brewfileが存在する場合は、それを使用してパッケージをインストール
DOTFILES=$(cd $(dirname $0)/.. && pwd)
if [ -f "$DOTFILES/Brewfile" ]; then
    echo "Brewfileからパッケージをインストールします..."
    brew bundle --file="$DOTFILES/Brewfile"
else
    echo "Brewfileが見つかりません。基本的なパッケージをインストールします..."

    # 基本的なパッケージをインストール
    brew install git
    brew install vim
    brew install neovim
    brew install tmux
    brew install zsh
    brew install ripgrep
    brew install fd
    brew install fzf
    brew install jq

    # アプリケーションをインストール
    brew install --cask visual-studio-code
    brew install --cask iterm2
    brew install --cask alfred
    brew install --cask google-chrome
    brew install --cask karabiner-elements
    brew install --cask rectangle
    brew install --cask alacritty
fi

echo "Homebrewのセットアップが完了しました"
