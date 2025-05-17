#!/bin/bash

# 現在のディレクトリを取得
DOTFILES=$(cd $(dirname $0) && pwd)

# 必要なスクリプトを実行
source $DOTFILES/scripts/setup_mac.sh
source $DOTFILES/scripts/setup_brew.sh
source $DOTFILES/scripts/setup_symlinks.sh

echo "セットアップが完了しました！"
