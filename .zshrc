# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# sheldon - plugin manager
if command -v sheldon &> /dev/null; then
  eval "$(sheldon source)"
fi

# git
alias gitb="git branch"
alias gitch="git checkout"
alias gits="git status"
alias gitpo="git push origin"
alias gitp="git pull"
alias gitf="git fetch"
alias gitcm="git commit -m "
alias gitst="git stash"
alias gitstl="git stash list"
alias gitstm="git stash -u -m "

gitsta() {
if [ $# -eq 1 ]; then
  git stash apply stash@{$1} && git stash drop stash@{$1}
else
  echo "Sorry. Please enter one argument for the stash index."
fi
}

# 不要なブランチ削除
# 不要なブランチ削除
git-cleanup() {
    local base_branch="${1:-main}"
    # 保護対象のブランチ（お好みで変更可能）
    local protected_branches=(
        "main"
        "master"
        "develop"
        "staging"
        "sandbox"
    )
    
    # 現在のブランチを取得
    local current_branch=$(git branch --show-current)
    
    # 現在のブランチが保護対象かチェック
    local is_protected=false
    for branch in "${protected_branches[@]}"; do
        if [[ "$current_branch" == "$branch" ]]; then
            is_protected=true
            break
        fi
    done
    
    # 保護対象ブランチまたはbase_branchにいない場合はエラー
    if [[ "$is_protected" == false && "$current_branch" != "$base_branch" ]]; then
        echo "⚠️  ${base_branch}ブランチまたは保護対象のブランチに切り替えてから実行してください"
        return 1
    fi
    
    # 最新状態に更新
    git fetch --prune
    
    # 保護対象のブランチを正規表現に変換
    local protected_pattern=$(printf "%s|" "${protected_branches[@]}")
    protected_pattern="${protected_pattern%|}"  # 最後の|を削除
    
    # マージ済みブランチを検索（保護対象を除外）
    local merged_branches=$(git branch --merged "$base_branch" | grep -v "\*" | grep -vE "^\s*(${protected_pattern})\s*$")
    
    # リモートにないブランチを検索（保護対象を除外）
    local no_remote_branches=$(git branch | grep -v "\*" | grep -vE "^\s*(${protected_pattern})\s*$" | sed 's/^[[:space:]]*//' | while read -r branch; do
        if ! git branch -r | grep -q "origin/$branch"; then
            echo "$branch"
        fi
    done)
    
    local deleted_count=0
    local skipped_count=0
    
    # マージ済みブランチを一括削除
    if [[ -n "$merged_branches" ]]; then
        echo "🔒 保護対象のブランチ: ${protected_branches[*]}"
        echo "📝 マージ済み削除対象のブランチ:"
        echo "$merged_branches" | sed 's/^/  /'
        
        read "confirm?これらのマージ済みブランチを削除しますか？ [y/N]: "
        if [[ "$confirm" =~ ^[Yy]$ ]]; then
            local count=$(echo "$merged_branches" | wc -l)
            echo "$merged_branches" | xargs -n 1 git branch -d
            echo "✅ マージ済みブランチ ${count} 個を削除しました"
            deleted_count=$((deleted_count + count))
        else
            echo "❌ マージ済みブランチの削除をキャンセルしました"
        fi
        echo ""
    fi
    
    # リモートにないブランチを1つずつ確認
    if [[ -n "$no_remote_branches" ]]; then
        echo "🌐 リモートにないブランチを確認します:"
        echo ""
        
        while IFS= read -r branch; do
            if [[ -n "$branch" ]]; then
                # マージ状態を確認
                local merge_status=""
                if git branch --merged "$base_branch" | grep -q "^\s*$branch\s*$"; then
                    merge_status="(マージ済み)"
                else
                    merge_status="(未マージ)"
                fi
                
                read "confirm?ブランチ '$branch' $merge_status (リモートにない) を削除しますか？ [y/N/q]: "
                case "$confirm" in
                    [Yy]*)
                        if [[ "$merge_status" == "(マージ済み)" ]]; then
                            git branch -d "$branch"
                        else
                            echo "⚠️  未マージのブランチです。強制削除しますか？"
                            read "force_confirm?強制削除 [y/N]: "
                            if [[ "$force_confirm" =~ ^[Yy]$ ]]; then
                                git branch -D "$branch"
                            else
                                echo "  スキップしました: $branch"
                                ((skipped_count++))
                                continue
                            fi
                        fi
                        echo "  ✅ 削除しました: $branch"
                        ((deleted_count++))
                        ;;
                    [Qq]*)
                        echo "❌ 処理を中断しました"
                        break
                        ;;
                    *)
                        echo "  スキップしました: $branch"
                        ((skipped_count++))
                        ;;
                esac
            fi
        done <<< "$no_remote_branches"
    fi
    
    if [[ -z "$merged_branches" && -z "$no_remote_branches" ]]; then
        echo "✅ 削除対象のブランチはありません"
        return 0
    fi
    
    echo ""
    echo "📊 結果: 削除 $deleted_count 個、スキップ $skipped_count 個"
    echo "✅ 処理完了!"
}

# docker
alias d="docker"
alias dc="docker compose"
alias dce="docker compose exec"
alias dei="docker exec -it "
alias da="docker attach"

dbash() {
if [ $# -eq 1 ]; then
  docker compose exec -it $1 /bin/bash
else
  echo "Sorry. Please enter one argument."
fi
}

#help
alias reload="source ~/.zshrc"
alias vz="vim ~/.zshrc"
alias cz="cat ~/.zshrc"
alias cur="cursor"

# asdf - version manager
if [ -f /usr/local/opt/asdf/libexec/asdf.sh ]; then
  . /usr/local/opt/asdf/libexec/asdf.sh
fi


if type brew &>/dev/null; then
    FPATH=$(brew --prefix)/share/zsh-completions:$FPATH

    autoload -Uz compinit
    compinit
fi


#test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
