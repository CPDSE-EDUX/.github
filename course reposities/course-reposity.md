# Git Bash Cheatsheet: Course Reposity with Yearly Branches

Example repo used throughout: `https://github.com/CPDSE-EDUX/CPDSE-Course-Repository-Template/`

When creating a new repository, this repository should also be used as template. A new repository should also follow the naming conventions mentioned here:

[https://github.com/CPDSE-EDUX/.github/edit/main/profile/README.md](https://github.com/CPDSE-EDUX/.github/edit/main/profile/README.md)

**This guide assumes that a repository was already created remotely.**

## Standardized Workflow
Use the standardized branch workflow for course repos based on [this shell script file](https://github.com/CPDSE-EDUX/.github/blob/main/course%20reposities/course-year.sh).

Open Git Bash and clone the repository containing the shell script:

`git clone https://github.com/CPDSE-EDUX/.github.git ~/course-tools`

Set a global Git alias that lets you create a shortcut for a Git command that works across all repositories on your system:

`git config --global alias.course-year '!'"bash "'"$HOME/course-tools/course reposities/course-year.sh"'`

Navigate to a course repository folder. Inside, use

`git course-year`

to automatically run the standardized workflow to generate a new branch at the end of a semester.

---

## Manual Workflow

### 1. Clone the repo

Open Git Bash, navigate to where you want the project folder, then:

```bash
cd ~/Documents/GitHub          # or wherever you keep projects
git clone https://github.com/CPDSE-EDUX/CPDSE-Course-Repository-Template.git
cd CPDSE-Course-Repository-Template
```

Check it worked:

```bash
git status        # should say "On branch main, nothing to commit"
git branch -a     # lists local + remote branches
```

---

### 2. Make changes and commit them

```bash
# edit some files with your editor of choice, then:
git status                     # see what changed
git add .                      # stage everything changed
git add path/to/file.md        # or stage a specific file
git commit -m "Update week 3 exercise instructions"
git push                       # send to GitHub (origin main, if on main)
```

Useful checks:

```bash
git log --oneline -10   # last 10 commits, short form
git diff                # see unstaged changes before adding
```

---

### 3. Create a branch for a course year

At the end of a course run (e.g. finishing 2025), snapshot `main` into a year branch:

```bash
git checkout main               # make sure you're on main
git pull                        # make sure it's up to date
git checkout -b 2025            # create + switch to new branch "2025"
git push -u origin 2025         # push it to GitHub, set upstream
```

`-u origin 2025` links your local `2025` branch to `origin/2025`, so future `git push`/`git pull` on this branch work without extra arguments.

Now protect it on GitHub (do this in the browser, not Git Bash):
`Repo → Settings → Branches → Add branch protection rule → branch name "2025" → check "Restrict deletions" and "Block force pushes"`

This freezes `2025` so no one (including future-you) accidentally edits archived material.

---

### 4. Switch between branches

```bash
git branch -a              # list all branches (local + remote)
git checkout main          # switch to main (current year)
git checkout 2025          # switch to the 2025 archive
git checkout 2024          # switch to 2024 archive
```

Modern Git also accepts `git switch`, which is a bit clearer since `checkout` does many things:

```bash
git switch main
git switch 2025
```

If a year branch only exists on GitHub and not locally yet:

```bash
git fetch                  # pulls down branch info without merging
git checkout 2024          # Git auto-creates a local tracking branch
```

---

### 5. Continue working on `main` for the new year

After archiving `2025`, go back to `main` and keep editing it for the next course run:

```bash
git checkout main
# edit files for 2026...
git add .
git commit -m "Update slides for 2026 run"
git push
```

`main` always represents "the current year." History for old years lives untouched on their own branches.

---

### 6. Quick reference table

| Task | Command |
|---|---|
| Clone repo | `git clone <url>` |
| See current branch | `git branch` |
| See all branches | `git branch -a` |
| Create + switch to new branch | `git checkout -b <name>` |
| Switch to existing branch | `git checkout <name>` or `git switch <name>` |
| Stage changes | `git add .` |
| Commit changes | `git commit -m "message"` |
| Push branch (first time) | `git push -u origin <branch>` |
| Push branch (after that) | `git push` |
| Pull latest changes | `git pull` |
| Fetch remote branches without merging | `git fetch` |
