#!/usr/bin/env bash
#
# course-manager.sh — standardized branch workflow for course repos.
#
# Works with any git host (GitHub, GitLab, Bitbucket, self-hosted) since it
# only uses plain `git` commands. No host-specific CLI (gh, glab, etc.).
#
# Convention this script enforces:
#   - The default branch (main/master) always holds the CURRENT year's material.
#   - At the end of a course run, the default branch is snapshotted into a
#     branch named after that year (e.g. "2025") and pushed to the remote.
#   - The default branch then continues to be edited for the next year.
#
# Usage:
#   ./course-manager.sh archive <year>       Snapshot current default branch into <year>, push it
#   ./course-manager.sh switch <year|main>   Switch to an existing year branch, or back to the default branch
#   ./course-manager.sh list                 List all local and remote branches
#   ./course-manager.sh new-year             Return to the default branch and pull latest (start of a new run)
#
# Examples:
#   ./course-manager.sh archive 2025
#   ./course-manager.sh switch 2024
#   ./course-manager.sh list

set -euo pipefail

usage() {
  sed -n '2,20p' "$0" | sed 's/^# \{0,1\}//'
}

get_remote() {
  local remote
  remote=$(git remote | head -n1)
  if [[ -z "$remote" ]]; then
    echo "Error: no git remote configured for this repo." >&2
    exit 1
  fi
  echo "$remote"
}

get_default_branch() {
  local remote branch
  remote=$(get_remote)
  # Try to read it from the remote's HEAD ref (accurate, works on any host)
  branch=$(git symbolic-ref "refs/remotes/$remote/HEAD" 2>/dev/null | sed "s@^refs/remotes/$remote/@@") || true
  if [[ -z "$branch" ]]; then
    # Fall back to whichever of main/master exists locally
    if git show-ref --verify --quiet refs/heads/main; then
      branch="main"
    elif git show-ref --verify --quiet refs/heads/master; then
      branch="master"
    else
      echo "Error: could not determine default branch. Pass it explicitly if needed." >&2
      exit 1
    fi
  fi
  echo "$branch"
}

require_clean_worktree() {
  if [[ -n "$(git status --porcelain)" ]]; then
    echo "Error: you have uncommitted changes. Commit or stash them first." >&2
    exit 1
  fi
}

cmd_archive() {
  local year="${1:-}"
  if [[ -z "$year" ]]; then
    echo "Error: missing year. Usage: course-manager.sh archive <year>" >&2
    exit 1
  fi

  local remote default_branch
  remote=$(get_remote)
  default_branch=$(get_default_branch)

  require_clean_worktree

  echo "Switching to '$default_branch' and pulling latest..."
  git checkout "$default_branch"
  git pull "$remote" "$default_branch"

  if git show-ref --verify --quiet "refs/heads/$year"; then
    echo "Error: local branch '$year' already exists." >&2
    exit 1
  fi
  if git ls-remote --exit-code --heads "$remote" "$year" &>/dev/null; then
    echo "Error: branch '$year' already exists on remote '$remote'." >&2
    exit 1
  fi

  echo "Creating branch '$year' from '$default_branch'..."
  git checkout -b "$year"
  git push -u "$remote" "$year"

  echo "Switching back to '$default_branch'..."
  git checkout "$default_branch"

  cat <<EOF

Done. '$default_branch' has been snapshotted into branch '$year' and pushed to '$remote'.

Next step (do this on your git host's website, this can't be scripted portably):
  Protect the '$year' branch so it can't be edited or deleted by accident.
  - GitHub:    Settings > Branches > Add rule
  - GitLab:    Settings > Repository > Protected branches
  - Bitbucket: Repository settings > Branch permissions

You are now back on '$default_branch', ready to edit for the next year.
EOF
}

cmd_switch() {
  local target="${1:-}"
  if [[ -z "$target" ]]; then
    echo "Error: missing target. Usage: course-manager.sh switch <year|main>" >&2
    exit 1
  fi
  require_clean_worktree
  git fetch --all --quiet
  git checkout "$target"
  echo "Now on branch '$target'."
}

cmd_list() {
  echo "Local and remote branches:"
  git branch -a
}

cmd_new_year() {
  local default_branch
  default_branch=$(get_default_branch)
  require_clean_worktree
  git checkout "$default_branch"
  git pull "$(get_remote)" "$default_branch"
  echo "On '$default_branch', up to date. Ready to start editing for the new year."
}

confirm() {
  local prompt="$1"
  local reply
  read -r -p "$prompt [y/N] " reply
  [[ "$reply" =~ ^[Yy]$ ]]
}

interactive_menu() {
  echo "=================================="
  echo " Course Repo — Year Branch Helper"
  echo "=================================="
  echo "Repo: $(basename "$(git rev-parse --show-toplevel 2>/dev/null || echo unknown)")"
  echo ""
  echo "What would you like to do?"
  echo "  1) Archive the current year into a branch (end of a course run)"
  echo "  2) Switch to a different branch (e.g. view an old year)"
  echo "  3) List all branches"
  echo "  4) Start fresh on the current branch (pull latest, get ready to edit)"
  echo "  5) Quit"
  echo ""
  read -r -p "Enter a number [1-5]: " choice

  case "$choice" in
    1)
      read -r -p "Which year are you archiving (e.g. 2025)? " year
      echo ""
      echo "This will:"
      echo "  - switch to '$(get_default_branch)' and pull the latest changes"
      echo "  - create a new branch called '$year' from it"
      echo "  - push '$year' to the remote"
      echo "  - switch back to '$(get_default_branch)'"
      if confirm "Continue?"; then
        cmd_archive "$year"
      else
        echo "Cancelled. Nothing was changed."
      fi
      ;;
    2)
      cmd_list
      echo ""
      read -r -p "Type the branch name to switch to: " target
      cmd_switch "$target"
      ;;
    3)
      cmd_list
      ;;
    4)
      cmd_new_year
      ;;
    5|"")
      echo "Bye."
      ;;
    *)
      echo "Not a valid option. Please run again and choose 1-5." >&2
      exit 1
      ;;
  esac
}

main() {
  local command="${1:-}"

  # No arguments at all -> friendly interactive menu (for double-click launchers
  # and anyone who doesn't want to memorize command syntax).
  if [[ -z "$command" ]]; then
    interactive_menu
    echo ""
    read -r -p "Press Enter to close this window..." _ignore || true
    return
  fi

  shift || true
  case "$command" in
    archive)  cmd_archive "$@" ;;
    switch)   cmd_switch "$@" ;;
    list)     cmd_list "$@" ;;
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
