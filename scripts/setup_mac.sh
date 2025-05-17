#!/bin/bash

echo "Macの設定を開始します..."

# Dockの設定
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock show-process-indicators -bool true
defaults write com.apple.dock tilesize -int 36

# Finderの設定
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder ShowStatusBar -bool true
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

# スクリーンショットの設定
defaults write com.apple.screencapture location -string "$HOME/Pictures/Screenshots"
defaults write com.apple.screencapture type -string "png"

# キーボードの設定
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15

# トラックパッドの設定
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true

# 変更を適用
killall Dock
killall Finder
killall SystemUIServer

echo "Macの設定が完了しました"
