---
name: pr
description: GitHub Pull Request creation
arguments:
  optional:
    - name: base_branch
      description: Base branch for merging (defaults to main/master if not specified)
    - name: draft
      description: Create as draft PR (true/false)
---

# PR Creation Command

Automatically creates a Pull Request from current changes.

## Usage

```bash
# Basic usage
claude "/pr"

# Draft PR
claude "/pr --draft"

# Change base branch
claude "/pr --base_branch develop"

# Short form
claude "Create a PR with current changes"
```

## PR Creation Process

1. **Change Confirmation**

   - git status
   - git diff

2. **Quality Assurance**

   - Type check
   - Lint
   - Format
   - Build

3. **Branch Operations**

   - Create/switch branch
   - Create commit
   - Push

4. **PR Creation**

   - Add labels