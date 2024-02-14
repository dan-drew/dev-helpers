# Development Helpers

This repository contains various command line shortcuts to simplify monotonous and/or overcomplicated development tasks

## Installation



## Git

The following tools simplify making frequent (1+ daily) interim commits so that a) important in-progress changes will not be lost and b) developer can easily rewind or reset to a recent commit.

Recommended workflow is as follows:

```shell
# Create a new working branch
branch:main$ gcl            # If working on a team, make sure your main is up to date
branch:main$ git checkout -b my-branch
branch:my-branch$

# Make some initial changes then commit and push
branch:my-branch$ ga && gc 'My new changes' && gp

# Keep making incremental changes and periodically commit
branch:my-branch$ ga && gcf && gp

# Periodically squash changes and force update remote branch
branch:my-branch$ gr && gpf

# Rebase if other devs have updated the main branch
branch:my-branch$ gr                  # Squash against local main first so only 1 commit to merge
branch:my-branch$ gcl                 # Update main
branch:my-branch$ gr                  # Now rebase against main
branch:my-branch$ gpf                 # Update remote branch

# When your changes are complete and ready to be merged
# As a sanity check, perform steps above to make sure you're up to date.
branch:my-branch$ git checkout main

branch:main$ git merge --ff-only my-branch      # Ensure linear history and that you're 
                                                # not out of sync

branch:main$ gp                                 # This will fail if you did anything wrong 
                                                # or didn't rebase latest changes

branch:main$ gcl                                # Perform any branch cleanup
```

### `ga`

Shortcut for `git add [DIRECTORY]`. By default adds from the current directory.

```shell
ga                    # Add changes in current directory and subdirectories
ga ../foo             # Add changes from a specific directory and subdirectories
```

### `gc`

Creates a new full commit. Shortcut for `git commit -m <MESSAGE>`. 

```shell
gc 'This is my new commit'
```

### `gcf`

Creates a new fixup commit. Shortcut for `git commit --fixup=HEAD`

```
$ gcf
$ git log --oneline
abcdef2 (HEAD -> my-branch, origin/my-branch) fixup! Initial commit
abcdef1 New commit
abcdef0 (HEAD -> main, origin/main) Initial commit
```

### `gr`

Performs a rebase, by default against the repo main branch. Shortcut for `git rebase -i --autosquash <base>`

```shell
gr                # Rebase against main/master
gr other-branch   # Rebase against other-branch
```

### `gp`

Shortcut for `git push origin HEAD`

### `gpf`

Shortcut for `git push --force-with-lease origin HEAD`

### `gcl`

Performs the following steps to be used before and after rebasing:
* Checks out the repos main branch if necessary
* Pulls updates
* Deletes local merged branches
* Returns to the previous working branch if it wasn't the main branch

## Terraform

*TODO*

### `ta`

### `tp`

### `tw`
