# Drupal LMS Demo Kit

A demo kit for [Drupal LMS](https://www.drupal.org/project/lms). The installation and setup guide within [the official documentation](https://www.drupal.org/docs/extending-drupal/contributed-modules/contributed-module-documentation/drupal-lms) is canonical; this kit gets you up and running quickly.

## Choose your path

| You want to... | Do this |
| :--- | :--- |
| Try Drupal LMS quickly | [Quick Start](#quick-start) |
| Apply LMS to an existing Drupal site | [Recipe](#recipe) |
| Build your own demo like this one | [docs/build-this-kit.md](docs/build-this-kit.md) |
| Share a live preview link | [docs/tugboat.md](docs/tugboat.md) |
| Maintain or fork this demo kit | [docs/maintainers-workflow.md](docs/maintainers-workflow.md) |

## Repo layout

```
.
├── .ddev/                      # DDEV settings
├── .tugboat/                   # Tugboat preview setup
│   └── database.sql.gz         # Seeded demo database
├── assets/
│   └── courses/                # LMS course packages (YAML zip)
├── config/
│   └── sync/                   # Exported site config (source of truth)
├── docs/                       # Build, Tugboat, and maintainer guides
├── recipes/
│   └── lms_demo_kit/           # LMS layer as a Drupal recipe
│       ├── recipe.yml
│       ├── config/             # LMS config, portable (no UUIDs)
│       └── content/            # Starter course, class, lessons, activities
├── scripts/
│   └── create-demo-users.sh    # Demo user creation
└── web/                        # Drupal docroot (core/contrib gitignored)
```

## Prerequisites

- Docker provider (OrbStack, Docker Desktop, Colima)
- [DDEV](https://ddev.readthedocs.io/) v1.24+
- git

## Quick Start

```shell
git clone https://github.com/markf3lton/drupal-lms-demo-kit.git
cd drupal-lms-demo-kit
ddev start
ddev composer install

# Install from config and create the demo users
ddev drush site:install --existing-config -y
./scripts/create-demo-users.sh

# Log in as "LMS Admin" and import the demo course(s)
# Navigate to LMS > Import courses, and select the "course_creators_guide_en_v1.zip" from assets/courses
ddev drush uli --name="LMS Admin" /admin/lms

# Or, skip all of the above and import the seeded demo database
gunzip -c .tugboat/database.sql.gz | ddev import-db
ddev drush uli
ddev launch
```

Snapshot the pristine state to reset between demos:

```shell
ddev snapshot --name=fresh-demo
ddev snapshot restore fresh-demo
```

## Recipe

Apply the LMS layer (config + starter content) to any Drupal 11 site:

```shell
ddev drush recipe /var/www/html/recipes/lms_demo_kit
```

Tested against a vanilla `standard` profile install. See `recipes/lms_demo_kit/recipe.yml` for what it installs.

## Demo Accounts

All passwords: `123456` (local demo only). Emails use RFC-reserved `example.com`.

| Account | Role |
| :--- | :--- |
| *(user 1)* | LMS Admin |
| LMS Admin | LMS Admin |
| LMS Teacher | LMS Teacher |
| Molly Larkins | Student (designated demo student) |
| Jan Kowalski, Diego Ramos | Students, Section A |
| Emma Chen, Nina Patel, Sam Carter | Students, Section B |

Course access is per-course via the [Group](https://www.drupal.org/project/group) module. The Teacher must be added as a member of each seeded course by the Admin.

## Verify

Anonymous homepage lists the seeded course → Molly can join and take it → Teacher sees her progress → `/admin/lms/activity_type` lists 12 types. Problems: `/admin/reports/status`, `/admin/reports/dblog`.

Reset a student's course progress:

```shell
ddev drush lms:reset-course <course_id> <user_id>
```

## Branches

| Branch | Purpose |
| :--- | :--- |
| `main` | Stable |
| `lms` | Development |

## Credits

- [drupal_lms_ddev](https://github.com/graber-1/drupal_lms_ddev) — the maintainer's quickstart, ancestor of this kit's approach
- [Drupal LMS documentation](https://www.drupal.org/docs/extending-drupal/contributed-modules/contributed-module-documentation/drupal-lms)
