# Drupal LMS Demo Kit

A demo kit for [Drupal LMS](https://www.drupal.org/project/lms). Drupal LMS is a highly flexible, Group-based, open-source Learning Management System built natively for Drupal 10 and Drupal 11.

Learn more in the [official documentation](https://www.drupal.org/docs/extending-drupal/contributed-modules/contributed-module-documentation/drupal-lms).

## Choose your path

| You want to... | Do this |
| :--- | :--- |
| Try Drupal LMS quickly | [Quick Start](#quick-start) |
| Apply LMS to your own Drupal site | [Recipe](#recipe) |
| Build your own demo kit | [docs/build-this-kit.md](docs/build-this-kit.md) |
| Share a live preview link | [docs/tugboat.md](docs/tugboat.md) |
| Maintain or fork this kit | [docs/maintainers-workflow.md](docs/maintainers-workflow.md) |

## Quick Start

```shell
git clone https://github.com/markf3lton/drupal-lms-demo-kit.git
cd drupal-lms-demo-kit
ddev start
ddev composer install

# Fastest: import the seeded demo database
gunzip -c .tugboat/database.sql.gz | ddev import-db

# Or rebuild from config
ddev drush site:install --existing-config -y
./scripts/create-demo-users.sh

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
| John Smith, Diego Ramos | Students, Section A |
| Emma Chen, Nina Patel, Sam Carter | Students, Section B |

Course access is per-course via the [Group](https://www.drupal.org/project/group) module. The Teacher must be added as a member of each seeded course by the Admin.

## Verify

Anonymous homepage lists the seeded course → Molly can join and take it → Teacher sees her progress → `/admin/lms/activity_type` lists 12 types.

Reset a student's course progress:

```shell
ddev drush lms:reset-course <course_id> <user_id>
```

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

## Branches

| Branch | Purpose |
| :--- | :--- |
| `main` | Stable |
| `lms` | Development |


## Prerequisites

- Docker provider (OrbStack, Docker Desktop, Colima)
- [DDEV](https://ddev.readthedocs.io/) v1.24+
- git

## Credits

- [drupal_lms_ddev](https://github.com/graber-1/drupal_lms_ddev) — the maintainer's quickstart (ancestor of this kit's approach)
- [Drupal LMS documentation](https://www.drupal.org/docs/extending-drupal/contributed-modules/contributed-module-documentation/drupal-lms)
