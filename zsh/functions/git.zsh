# git functions
gitsta() {
  if [ $# -eq 1 ]; then
    git stash apply stash@{$1} && git stash drop stash@{$1}
  else
    echo "Sorry. Please enter one argument for the stash index."
  fi
}

git-cleanup() {
  local base_branch="${1:-main}"

  # 1. 保護対象のブランチ（お好みで変更可能）
  local protected_branches=("main" "master" "develop" "staging" "sandbox" "feature/pre_release/rails_version_up")

  # 2. 現在のブランチを取得
  local current_branch=$(git branch --show-current)
  echo "現在のブランチ: $current_branch"

  # 3. 現在のブランチが保護対象かチェック
  local is_protected=false
  for branch in "${protected_branches[@]}"; do
    if [[ "$current_branch" == "$branch" ]]; then
      is_protected=true
      break
    fi
  done

  # 4. 保護対象ブランチまたはbase_branchにいない場合はエラー
  if [[ "$is_protected" == false && "$current_branch" != "$base_branch" ]]; then
    echo "⚠️  ${base_branch}ブランチまたは保護対象のブランチに切り替えてから実行してください"
    echo "保護対象: ${protected_branches[*]}"
    return 1
  fi

  # 5. 最新状態に更新
  echo "🔄 最新状態に更新中..."
  git fetch --prune

  # 6. マージ済みブランチを検索（保護対象を除外）
  echo "📝 マージ済みブランチを検索中..."
  local merged_branches=()
  while IFS= read -r branch; do
    # 空行や*付きをスキップ
    [[ -z "$branch" || "$branch" == *"*"* ]] && continue

    # 先頭の空白を削除
    branch=$(echo "$branch" | sed 's/^[[:space:]]*//')

    # 保護対象をスキップ
    local skip=false
    for protected in "${protected_branches[@]}"; do
      if [[ "$branch" == "$protected" ]]; then
        skip=true
        break
      fi
    done

    if [[ "$skip" == false ]]; then
      merged_branches+=("$branch")
    fi
  done < <(git branch --merged "$base_branch")

  # 7. 全てのローカルブランチを取得（保護対象を除外）
  echo "📋 全てのローカルブランチを検索中..."
  local all_local_branches=()
  while IFS= read -r branch; do
    # 空行や*付きをスキップ
    [[ -z "$branch" || "$branch" == *"*"* ]] && continue

    # 先頭の空白を削除
    branch=$(echo "$branch" | sed 's/^[[:space:]]*//')

    # 保護対象をスキップ
    local skip=false
    for protected in "${protected_branches[@]}"; do
      if [[ "$branch" == "$protected" ]]; then
        skip=true
        break
      fi
    done

    if [[ "$skip" == false ]]; then
      all_local_branches+=("$branch")
    fi
  done < <(git branch)

  # 8. マージ済みローカルブランチを一括削除
  local deleted_merged=()
  if [[ ${#merged_branches[@]} -gt 0 ]]; then
    echo ""
    echo "🔒 保護対象ブランチ: ${protected_branches[*]}"
    echo "📝 マージ済み削除対象ブランチ:"
    for branch in "${merged_branches[@]}"; do
      echo "  $branch"
    done

    read "confirm?これらのマージ済みブランチを削除しますか？ [y/N]: "
    if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
      for branch in "${merged_branches[@]}"; do
        if git branch -d "$branch" 2>/dev/null; then
          deleted_merged+=("$branch")
          echo "  ✅ 削除: $branch"
        else
          echo "  ❌ 削除失敗: $branch"
        fi
      done
    else
      echo "❌ マージ済みブランチの削除をキャンセルしました"
    fi
  else
    echo "✅ マージ済みブランチはありません"
  fi

  # 9. 未マージのローカルブランチを1つずつ確認（マージ済みローカルブランチは既に処理済みなので除外）
  local unmerged_branches=()
  for branch in "${all_local_branches[@]}"; do
    local is_merged=false
    for merged in "${merged_branches[@]}"; do
      if [[ "$branch" == "$merged" ]]; then
        is_merged=true
        break
      fi
    done

    if [[ "$is_merged" == false ]]; then
      unmerged_branches+=("$branch")
    fi
  done

  local deleted_unmerged=()
  if [[ ${#unmerged_branches[@]} -gt 0 ]]; then
    echo ""
    echo "🔍 未マージのローカルブランチを個別確認します:"

    for branch in "${unmerged_branches[@]}"; do
      # リモートブランチの存在確認
      local remote_status=""
      if git branch -r | grep -q "origin/$branch"; then
        remote_status="(リモートあり)"
      else
        remote_status="(リモートなし)"
      fi

      echo ""
      read "confirm?ブランチ '$branch' $remote_status (未マージ) を削除しますか？ [y/N/q]: "
      case "$confirm" in
        [Yy]*)
          # 10. 未マージのローカルブランチは2重で確認を入れる
          echo "⚠️  未マージのブランチです。"
          read "force_confirm?本当に強制削除しますか？ [y/N]: "
          if [[ "$force_confirm" == "y" || "$force_confirm" == "Y" ]]; then
            if git branch -D "$branch" 2>/dev/null; then
              deleted_unmerged+=("$branch")
              echo "  ✅ 強制削除: $branch"
            else
              echo "  ❌ 削除失敗: $branch"
            fi
          else
            echo "  スキップ: $branch"
          fi
          ;;
        [Qq]*)
          echo "❌ 処理を中断しました"
          break
          ;;
        *)
          echo "  スキップ: $branch"
          ;;
      esac
    done
  else
    echo "✅ 未マージのローカルブランチはありません"
  fi

  # 11. 削除したブランチの一覧等の情報を出力
  echo ""
  echo "📊 削除結果:"
  echo "  マージ済み削除: ${#deleted_merged[@]}個"
  if [[ ${#deleted_merged[@]} -gt 0 ]]; then
    for branch in "${deleted_merged[@]}"; do
      echo "    - $branch"
    done
  fi

  echo "  未マージ削除: ${#deleted_unmerged[@]}個"
  if [[ ${#deleted_unmerged[@]} -gt 0 ]]; then
    for branch in "${deleted_unmerged[@]}"; do
      echo "    - $branch"
    done
  fi

  local total_deleted=$((${#deleted_merged[@]} + ${#deleted_unmerged[@]}))
  echo "  合計削除: ${total_deleted}個"

  # 12. 完了
  echo ""
  echo "✅ git-cleanup 処理完了!"
}