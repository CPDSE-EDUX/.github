---
name: course-repo-conventions
description: Conventions for organizing CPDSE-EDUX course repositories — repository naming and the yearly branching workflow. Use whenever creating, naming, or managing branches in a course repository (e.g. "what should I name this repo", "archive this year", "make a branch for [year]", "switch to the 2024 branch", "start the new course year").
source: https://github.com/CPDSE-EDUX/.github/blob/main/profile/README.md
---

# Course Repository Conventions

The authoritative conventions for course repositories — repository naming
and the yearly branching workflow — are maintained in one place:

**https://github.com/CPDSE-EDUX/.github/raw/refs/heads/main/profile/README.md**

Before naming a repository, creating a year branch, or otherwise acting on
these conventions, fetch that URL and follow the "Conventions" section
found there. Do not rely on a cached or remembered copy of the rules —
always fetch fresh, since the README is the single source of truth and may
have been updated.

If the fetch fails (no network access, URL changed, etc.), say so plainly
rather than guessing at the conventions from memory, and ask the user for
the naming pattern or branching rule needed to proceed.

## Why this file has no rules written into it

Keeping the conventions in exactly one place (the README) means there is
nothing here to fall out of sync when that README changes. This file exists
only to point an assistant to that source and to describe when to look.

## Related tooling

The yearly branching workflow described in the README is implemented in
`course-manager.sh` (kept alongside this file, or clone it from
`https://github.com/CPDSE-EDUX/.github.git`). See the README's "Branching
for Different Years" section for setup and usage — it documents the git
alias (`git course-manager`) that runs this script from any repository.
