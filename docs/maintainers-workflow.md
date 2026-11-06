# Maintainer's Workflow

How to iterate on this kit without breaking the demo. Applies equally if you forked this repo.

### Branches

| Branch | Role | Discipline |
| :--- | :--- | :--- |
| `main` | The starter kit and the live demo. Its Tugboat Base Preview must always be demo-ready. | Changes arrive by merging `lms` (or an urgent fix branch). Never commit to it directly. |
| `lms` | Development and demo iteration. Every change lands here first. | Unrestricted, but keep it buildable. |

When `lms` is in a state you're happy with, merge it into `main`. Afterwards the two branches are identical, and the next round of work starts from there.

Early tags mark the pre-LMS Drupal baseline. To take the project in a different direction without starting over, branch from one: `git checkout -b new-direction 0.03`.

### When to use which install path

| Path | Use when | Notes |
| :--- | :--- | :--- |
| `gunzip -c .tugboat/database.sql.gz \| ddev import-db` | Fast local start; Tugboat previews; demo reset | Includes users, courses, enrollments. |
| `ddev drush site:install --existing-config -y` | Verifying config integrity; rebuilding after config changes | Config only — no content, no users. Run the user script and content import after. |
| `ddev drush recipe recipes/lms_demo_kit` | Adding LMS to a site that already exists | Additive; never deletes existing config. Test against vanilla `standard`. |
| `ddev snapshot restore <name>` | Resetting between local demo runs | Fastest of all; local only. |

### Daily iteration (on `lms`, local)

```shell
git switch lms && git pull
ddev snapshot restore lms-baseline       # database must match the branch (see below)
ddev snapshot --name=before-experiment   # before risky work

# work: make changes in the UI...

ddev drush config:export -y              # capture config as you go
git add config/sync/<files you changed>  # specific paths, never `git add .`
git commit -m "..."

ddev snapshot restore before-experiment  # bail out if needed
```

Then publish and check it on the `lms` preview:

```shell
git push
tugboat refresh 6aebcd14f3375230f31467d4   # lms branch preview; branch previews don't build on push
```

The database is the working copy; `config/sync/` is the source of truth. Export early, commit small, one logical change per commit. Content (courses, users, enrollments) is not config — it lives only in the database until captured by the refresh ritual.

**Match the database to the branch before exporting.** `config:export` writes whatever the database holds. Exporting on `main` against a database built on `lms` drags `lms`-only config into `main`. Restore `demo-ready` when on `main`, `lms-baseline` when on `lms`.

**Adding or updating modules:**

```shell
ddev composer require drupal/<module>      # or: ddev composer update drupal/<module>
ddev drush cr                              # Drupal won't see re-installed module code until caches rebuild
ddev drush updb -y
# enable the module in the UI if it's new
ddev drush config:export -y
git add composer.json composer.lock config/sync/<files>
```

Always export after `updb`. Updates often add new config keys; if `config/sync` doesn't have them, every Tugboat build runs `updb` and then `config:import` deletes them again.

### Merging `lms` into `main`

When `lms` is demo-ready:

1. Open a PR from `lms` to `main` on GitHub. Merge with a **merge commit**, not squash, so the individual commits survive.
2. Refresh the Base Preview: `tugboat refresh 6a5130b4ade5ea818708743e`. Check a course page.
3. Fast-forward `lms` to the merge commit so both branches point at the same place:

   ```shell
   git switch lms && git pull
   git merge --ff-only origin/main && git push
   ```

4. If it's a milestone, tag `main` and add a [changelog](changelog.md) row.

### Urgent fixes to `main`

If `main` itself is broken and `lms` has unfinished work, don't merge `lms` early. Branch from `main` instead:

```shell
git switch main && git pull
git switch -c fix-<name>
# fix, commit, push, open a PR to main, merge it
git switch lms && git merge origin/main   # bring the fix into lms
```

### Refresh ritual

When the demo-ready state changes, refresh the derived artifacts together:

```shell
# 1. Config
ddev drush config:export -y

# 2. Sanitize, then dump db to .tugboat directory
ddev drush user:information --uid=1          # check for real email/password
ddev drush user:password admin "$(openssl rand -base64 32)"   # random, never the demo password
ddev drush sql:query "TRUNCATE sessions;"    # clear live sessions (see note)
ddev drush sql:dump --structure-tables-list='cache,cache_*,history,search_*,sessions,watchdog,key_value_expire,flood,semaphore' | gzip > .tugboat/database.sql.gz


# 3. Snapshot the new baseline
ddev snapshot --name=demo-ready

# 4. Commit
git add config/sync .tugboat/database.sql.gz
git commit -m "Refresh demo baseline: <what changed>"
```

The `--structure-tables-list` dump keeps the schema for the transient tables — caches, sessions, the log, temporary key-value data — but drops their rows. Smaller dump, and no session rows to go stale that might cause `drush uli` errors. Spell the list out: `--structure-tables-key=common` excludes nothing unless Drush config defines a `common` list, which this project doesn't.

Do this rarely. Code and config reach previews without a new dump (see Tugboat below); only changes to demo content, users, or enrollments need one.

Recipe `content/` is not part of this ritual — it carries a minimal starter set, revised deliberately and rarely, not as a side effect of demo iteration.

### Which artifact updates when

| Changed | Update | Notes |
| :--- | :--- | :--- |
| Site config | `config/sync/` via `config:export`, commit | Every time |
| Demo course content | `.tugboat/database.sql.gz` via refresh ritual | Recipe content stays frozen |
| Demo users / roster | `scripts/create-demo-users.sh` and re-dump DB | Script is source of truth for credentials |
| Modules/themes | `composer.json` + `composer.lock`; `cr`, `updb`, then export config | See "Adding or updating modules" |
| Patches | `composer.json` `extra.patches`, then `ddev composer patches-relock` | Commit `patches.lock.json` too — composer-patches applies from the lock, not `composer.json` |
| Course packages | `assets/courses/*.zip` | The `.yml` files must sit at the zip root; Finder's Compress nests them in a folder and the import fails |
| Recipe (config or content) | `recipes/lms_demo_kit/`; re-test against clean install | See below |

### Recipe maintenance

The recipe must apply cleanly to a vanilla site, not just this repo. After any recipe change:

```shell
ddev snapshot --name=before-recipe-test
ddev drush site:install standard -y
ddev drush recipe /var/www/html/recipes/lms_demo_kit
./scripts/create-demo-users.sh
# verify, then restore:
ddev snapshot restore before-recipe-test
```

Recipe config is sanitized — no `uuid:`, no `_core:` blocks. Strip them again when copying fresh files from `config/sync/`.

Recipe work happens in `recipes/lms_demo_kit/` on any branch. Once it reaches `main`, publish it to [drupal.org/project/lms_demo_kit](https://www.drupal.org/project/lms_demo_kit).

### Tugboat

Previews import `.tugboat/database.sql.gz` during `init` — see [tugboat.md](tugboat.md), including the Gotchas on stale previews.

- Every build runs `composer install`, `updb`, and `config:import`, so code and config changes reach a preview with a plain **refresh**. Only demo-content changes need a new dump.
- **Refresh** (routine): keeps the preview's database and runs the build. **Rebuild** (rare): re-runs `init` and re-imports the dump. Rebuild only when the dump changed.
- Base Previews clone from `main`'s preview; `main` must stay demo-ready. Tugboat won't rebuild `main` while other previews depend on it — delete those first, then recreate them.

### Testing a fresh clone alongside your working copy

```shell
# In a fresh directory
git clone https://github.com/markf3lton/drupal-lms-demo-kit.git lms-test
cd lms-test

# To avoid ddev name conflicts, change the name of the project
ddev config --project-name=lms-test

ddev start
ddev composer install

# Seeded demo database (fastest path)
gunzip -c .tugboat/database.sql.gz | ddev import-db
ddev drush cr

ddev drush uli
ddev launch
```

### Tags

Tag milestones on `main`. See [changelog](changelog.md).
