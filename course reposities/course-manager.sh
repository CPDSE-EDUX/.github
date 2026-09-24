#!/usr/bin/env bash
#
# course-manager.sh provides a standardized branch workflow for course reposities.
#

set -euo pipefail

ORG_URL="https://github.com/CPDSE-EDUX"

usage() {
  local self
  self="$(basename "$0")"
  sed -n '2,4p' "$0" | sed 's/^# \{0,1\}//' | sed "s/course-manager\.sh/$self/g"
}

open_url() {
  local url="$1"
  # Try common ways to open a browser
  if command -v xdg-open &>/dev/null; then
    xdg-open "$url" &>/dev/null &
  elif command -v open &>/dev/null; then
    open "$url" &>/dev/null &
  elif command -v start &>/dev/null; then
    start "$url" &>/dev/null &
  elif command -v cmd.exe &>/dev/null; then
    cmd.exe /c start "" "$url" &>/dev/null &
  else
    return 1
  fi
  return 0
}

get_remote() {
  local remote
  remote=$(git remote | head -n1)
  if [[ -z "$remote" ]]; then
    echo "Error: no git remote configured for this repo." >&2
    return 1
  fi
  echo "$remote"
}

get_default_branch() {
  local remote branch
  remote=$(get_remote) || return 1
  # Try to read it from the remote's HEAD ref
  branch=$(git symbolic-ref "refs/remotes/$remote/HEAD" 2>/dev/null | sed "s@^refs/remotes/$remote/@@") || true
  if [[ -z "$branch" ]]; then
    # Fall back to whichever of main/master exists locally
    if git show-ref --verify --quiet refs/heads/main; then
      branch="main"
    elif git show-ref --verify --quiet refs/heads/master; then
      branch="master"
    else
      echo "Error: could not determine default branch. Pass it explicitly if needed." >&2
      return 1
    fi
  fi
  echo "$branch"
}

require_clean_worktree() {
  if [[ -n "$(git status --porcelain)" ]]; then
    echo "Error: you have uncommitted changes. Commit or stash them first." >&2
    return 1
  fi
}

require_git_repo() {
  if ! git rev-parse --is-inside-work-tree &>/dev/null; then
    echo "" >&2
    echo "This option needs to be run from inside a course repository's folder," >&2
    echo "but that doesn't look like where you are right now." >&2
    echo "" >&2
    echo "How to fix this:" >&2
    echo "  1. Open File Explorer and find the course repo's folder on your computer." >&2
    echo "  2. In Git Bash, type 'cd ' (with a space after it), then drag that folder" >&2
    echo "     into the Git Bash window and it will fill in the path for you." >&2
    echo "  3. Press Enter, then run 'git course-manager' again." >&2
    echo "" >&2
    exit 1
  fi
}

confirm() {
  local prompt="$1"
  local reply
  read -r -p "$prompt [y/N] " reply
  [[ "$reply" =~ ^[Yy]$ ]]
}

cmd_org() {
  echo "CPDSE-EDUX GitHub organization page:"
  echo "  $ORG_URL"
  open_url "$ORG_URL" || echo "(couldn't auto-open a browser — copy the link above)"
}

cmd_archive() {
  require_git_repo || return 1
  local year="${1:-}"
  if [[ -z "$year" ]]; then
    echo "Error: missing year. Usage: $(basename "$0") archive <year>" >&2
    return 1
  fi

  local remote default_branch
  remote=$(get_remote) || return 1
  default_branch=$(get_default_branch) || return 1

  require_clean_worktree || return 1

  echo "Switching to '$default_branch' and pulling latest..."
  if ! git checkout "$default_branch"; then
    echo "Error: could not switch to '$default_branch'." >&2
    return 1
  fi
  if ! git pull "$remote" "$default_branch"; then
    echo "Error: pull failed. See the git output above for details." >&2
    return 1
  fi

  if git show-ref --verify --quiet "refs/heads/$year"; then
    echo "Error: local branch '$year' already exists." >&2
    return 1
  fi
  if git ls-remote --exit-code --heads "$remote" "$year" &>/dev/null; then
    echo "Error: branch '$year' already exists on remote '$remote'." >&2
    return 1
  fi

  echo "Creating branch '$year' from '$default_branch'..."
  if ! git checkout -b "$year"; then
    echo "Error: could not create branch '$year'." >&2
    return 1
  fi
  if ! git push -u "$remote" "$year"; then
    echo "Error: could not push '$year' to '$remote'." >&2
    return 1
  fi

  echo "Switching back to '$default_branch'..."
  if ! git checkout "$default_branch"; then
    echo "Error: created and pushed '$year', but could not switch back to '$default_branch'." >&2
    return 1
  fi

  cat <<EOF

Done. '$default_branch' has been snapshotted into branch '$year' and pushed to '$remote'.

You are now back on '$default_branch', ready to edit for the next year.
EOF
}

cmd_switch() {
  require_git_repo || return 1
  local target="${1:-}"
  if [[ -z "$target" ]]; then
    echo "Error: missing target. Usage: $(basename "$0") switch <year|main>" >&2
    return 1
  fi
  require_clean_worktree || return 1
  if ! git fetch --all --quiet; then
    echo "Error: fetch failed." >&2
    return 1
  fi
  if ! git checkout "$target"; then
    echo "Error: could not switch to '$target'." >&2
    return 1
  fi
  echo "Now on branch '$target'."
}

cmd_list() {
  require_git_repo || return 1
  echo "Local and remote branches:"
  if ! git branch -a; then
    echo "Error: could not list branches." >&2
    return 1
  fi
}

cmd_new_year() {
  require_git_repo || return 1
  local default_branch remote
  default_branch=$(get_default_branch) || return 1
  require_clean_worktree || return 1
  if ! git checkout "$default_branch"; then
    echo "Error: could not switch to '$default_branch'." >&2
    return 1
  fi
  remote=$(get_remote) || return 1
  if ! git pull "$remote" "$default_branch"; then
    echo "Error: pull failed. See the git output above for details." >&2
    return 1
  fi
  echo "On '$default_branch', up to date. Ready to start editing for the new year."
}

cmd_save() {
  require_git_repo || return 1
  local message="${1:-}"

  local changes
  changes=$(git status --porcelain)
  if [[ -z "$changes" ]]; then
    echo "No changes to save. Your local copy already matches your last commit."
    return 0
  fi

  echo "Changes found:"
  git status --short
  echo ""
  if ! confirm "Stage and commit ALL of these changes?"; then
    echo "Cancelled. Nothing was changed."
    return 0
  fi

  if ! git add -A; then
    echo "Error: could not stage changes." >&2
    return 1
  fi

  if [[ -z "$message" ]]; then
    read -r -p "Short description of what you changed: " message
  fi
  if [[ -z "$message" ]]; then
    message="Update course materials"
  fi
  if ! git commit -m "$message"; then
    echo "Error: commit failed." >&2
    return 1
  fi

  local remote branch
  remote=$(get_remote) || return 1
  branch=$(git rev-parse --abbrev-ref HEAD) || return 1

  echo "Pushing '$branch' to '$remote'..."
  if git push "$remote" "$branch"; then
    echo "Done. Your changes are committed and pushed."
  else
    echo "" >&2
    echo "Push was rejected. Someone else likely pushed changes first." >&2
    echo "Run 'pull' (or menu option to get the latest changes), then try saving again." >&2
    return 1
  fi
}

cmd_pull() {
  require_git_repo || return 1
  require_clean_worktree || return 1
  local remote branch
  remote=$(get_remote) || return 1
  branch=$(git rev-parse --abbrev-ref HEAD) || return 1
  echo "Pulling latest changes for '$branch' from '$remote'..."
  if ! git pull "$remote" "$branch"; then
    echo "Error: pull failed. See the git output above for details." >&2
    return 1
  fi
  echo "Up to date."
}

cmd_web() {
  require_git_repo || return 1
  local remote url branch
  remote=$(get_remote) || return 1
  url=$(git remote get-url "$remote") || return 1

  # Normalize SSH form (git@github.com:org/repo.git) to a browsable https URL
  if [[ "$url" =~ ^git@([^:]+):(.+)$ ]]; then
    url="https://${BASH_REMATCH[1]}/${BASH_REMATCH[2]}"
  fi
  url="${url%.git}"

  branch=$(git rev-parse --abbrev-ref HEAD) || return 1
  local full_url="${url}/tree/${branch}"

  echo "Web page for this repo (branch '$branch'):"
  echo "  $full_url"
  open_url "$full_url" || echo "(couldn't auto-open a browser — copy the link above)"
}

# --- Interactive menu --------------------------------------------------------

interactive_menu() {
  while true; do
    echo "=================================="
    echo " CPDSE Course Manager"
    echo "=================================="
    echo "Repo: $(basename "$(git rev-parse --show-toplevel 2>/dev/null || echo 'not in a repo')")"
    echo ""
    echo "What would you like to do?"
    echo "  1) Open the CPDSE-EDUX GitHub organization page"
    echo "  2) Open this repo's page on GitHub.com"
    echo "  3) Save my changes online (commit + push)"
    echo "  4) Get the latest changes (pull)"
    echo "  5) Archive the current year at the end of the semester (branching)"
    echo "  6) List branches / switch to a different one"
    echo "  7) Quit"
    echo ""
    read -r -p "Enter a number [1-7]: " choice

    local action_taken=true
    case "$choice" in
      1)
        cmd_org || true
        ;;
      2)
        cmd_web || true
        ;;
      3)
        cmd_save || true
        ;;
      4)
        cmd_pull || true
        ;;
      5)
        require_git_repo
        read -r -p "Which year are you archiving (e.g. 2025)? " year
        default_branch_preview=$(get_default_branch 2>/dev/null || echo "unknown")
        echo ""
        echo "This will:"
        echo "  - switch to '$default_branch_preview' and pull the latest changes"
        echo "  - create a new branch called '$year' from it"
        echo "  - push '$year' to the remote"
        echo "  - switch back to '$default_branch_preview'"
        if confirm "Continue?"; then
          cmd_archive "$year" || true
        else
          echo "Cancelled. Nothing was changed."
        fi
        ;;
      6)
        cmd_list || true
        echo ""
        read -r -p "Type a branch name to switch to (or press Enter to skip): " target
        if [[ -n "$target" ]]; then
          cmd_switch "$target" || true
        fi
        ;;
      7|"")
        echo "Bye."
        break
        ;;
      *)
        echo "Not a valid option, please choose a number from 1 to 7." >&2
        action_taken=false
        ;;
    esac

    # Only ask after a real, completed action — not after a mistyped choice
    # (which should just let the person try again right away).
    if $action_taken; then
      echo ""
      if ! confirm "Would you like to do another action?"; then
        echo "Bye."
        break
      fi
      echo ""
      echo "----------------------------------"
      echo ""
    fi
  done
}

main() {
  local command="${1:-}"

  if [[ -z "$command" ]]; then
    interactive_menu
    return
  fi

  shift || true
  case "$command" in
    org)      cmd_org "$@" ;;
    save)     cmd_save "$@" ;;
    pull)     cmd_pull "$@" ;;
    archive)  cmd_archive "$@" ;;
    switch)   cmd_switch "$@" ;;
    list)     cmd_list "$@" ;;
    web)      cmd_web "$@" ;;
    new-year) cmd_new_year "$@" ;;
    -h|--help) usage ;;
    *)
      echo "Unknown command: $command" >&2
      usage
      exit 1
      ;;
  esac
}

main "$@"
