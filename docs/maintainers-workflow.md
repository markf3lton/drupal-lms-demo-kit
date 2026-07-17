# Maintainer's Workflow

How to iterate on this kit without degrading the starter kit. Applies equally if you forked this repo.

### Branches

| Branch | Role | Discipline |
| :--- | :--- | :--- |
| `main` | The starter kit. | Curated. Changes pass the merge gate. |
| `lms` | Development and demo iteration. | Unrestricted. |
| `recipe` | Drupal recipe. | Kept simple, for recipe development. |


Early tags mark the pre-LMS Drupal baseline. To take the project in a different direction without starting over, branch from one: `git checkout -b new-direction 0.03`.

### Merge gate (`lms` → `main`)

- Does the starter kit need this, or only my demo? Recipe fixes and genuinely better defaults: kit. Modules or themes added for a specific audience: demo.
- Does it add a setup step, credential, or prerequisite to the Quick Start? If yes, it probably stays on `lms`.
- If long-lived divergence accumulates on `lms` (modules never merging, audience-specific themes/courses), move the demo to a private downstream repo and keep this repo as the lean upstream.

### When to use which install path

| Path | Use when | Notes |
| :--- | :--- | :--- |
| `gunzip -c .tugboat/database.sql.gz \| ddev import-db` | Fast local start; Tugboat previews; demo reset | Includes users, courses, enrollments. |
| `ddev drush site:install --existing-config -y` | Verifying config integrity; rebuilding after config changes | Config only — no content, no users. Run the user script and content import after. |
| `ddev drush recipe recipes/lms_demo_kit` | Adding LMS to a site that already exists | Additive; never deletes existing config. Test against vanilla `standard`. |
| `ddev snapshot restore <name>` | Resetting between local demo runs | Fastest of all; local only. |

### Daily iteration (on `lms`, local)

```shell
ddev snapshot --name=before-experiment   # before risky work

# work: modules, courses, config changes...

ddev drush config:export -y              # capture config as you go
git add config/sync && git commit -m "..."

ddev snapshot restore before-experiment  # bail out if needed
```

The database is the working copy; `config/sync/` is the source of truth. Export early, commit small. Content (courses, users, enrollments) is not config — it lives only in the database until captured by the refresh ritual.

### Refresh ritual

When the demo-ready state changes, refresh the derived artifacts together:

```shell
# 1. Config
ddev drush config:export -y

# 2. Sanitize, then dump db to .tugboat directory
ddev drush user:information --uid=1          # check for real email/password
ddev drush user:password admin '123456'      # neutralize if needed
ddev drush sql:query "TRUNCATE sessions;"    # clear live sessions (see note)
ddev drush sql:dump --structure-tables-key=common | gzip > .tugboat/database.sql.gz


# 3. Snapshot the new baseline
ddev snapshot --name=demo-ready

# 4. Commit
git add config/sync .tugboat/database.sql.gz
git commit -m "Refresh demo baseline: <what changed>"
```

The `--structure-tables-key=common` dump keeps the schema for the transient tables — sessions, cache*, watchdog, search_*, history — but drops their rows. Smaller dump, and no session rows to go stale that might cause `drush uli` errors.

Recipe `content/` is not part of this ritual — it carries a minimal starter set, revised deliberately and rarely, not as a side effect of demo iteration.

### Which artifact updates when

| Changed | Update | Notes |
| :--- | :--- | :--- |
| Site config | `config/sync/` via `config:export`, commit | Every time |
| Demo course content | `.tugboat/database.sql.gz` via refresh ritual | Recipe content stays frozen |
| Demo users / roster | `scripts/create-demo-users.sh` and re-dump DB | Script is source of truth for credentials |
| Modules/themes | `composer.json` + `composer.lock`; export config after enabling | Merge gate applies before `main` |
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

### Tugboat

Previews import `.tugboat/database.sql.gz` during `init` — see [tugboat.md](tugboat.md), including the Gotchas on stale previews.

- Preview freshness equals dump freshness. Config or content changes without a re-dump produce stale previews.
- Base Previews clone from `main`'s preview; `main` must stay demo-ready.

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

Tag the  milestones on `main`. See [changelog](changelog.md).
