# Drupal LMS Demo Kit

A demo kit for [Drupal LMS](https://www.drupal.org/project/lms). Gets you up and running quickly. Follows the installation guide within [the official documentation](https://www.drupal.org/docs/extending-drupal/contributed-modules/contributed-module-documentation/drupal-lms).

## Choose your path

| You want to... | Do this |
| :--- | :--- |
| Try Drupal LMS | [Quick Start](#quick-start) |
| Apply LMS to an existing  site | [Drupal Recipe](#recipe) |
| Build this kit | [docs/build-this-kit.md](docs/build-this-kit.md) |
| Get a [preview link](https://main-tygknmd1g7emlvtb1h4mkfu5nt8ii5hl.tugboatqa.com/) | [docs/tugboat.md](docs/tugboat.md) |
| Fork this kit | [docs/maintainers-workflow.md](docs/maintainers-workflow.md) |

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

# Import the demo course (assets/courses) at LMS > Import courses:
ddev drush uli --name="LMS Admin" /admin/lms

# Or, skip all of the above and import the seeded demo database
gunzip -c .tugboat/database.sql.gz | ddev import-db
ddev drush cr
ddev drush uli
ddev launch
```

Snapshot the pristine state:

```shell
ddev snapshot --name=fresh-demo
ddev snapshot restore fresh-demo
```

## Demo Accounts

The kit provides demo user accounts. All passwords: `123456` (local demo only).

| Account | Role |
| :--- | :--- |
| *(user 1)* | LMS Admin |
| LMS Admin | LMS Admin |
| LMS Teacher | LMS Teacher |
| Molly Larkins | Student (designated demo student) |
| Jan Kowalski, Diego Ramos | Students, Section A |
| Emma Chen, Nina Patel, Sam Carter | Students, Section B |

Course access is managed via the [Group](https://www.drupal.org/project/group) module. (To manage existing courses, a Teacher must be added to the course by an LMS Admin.)

## Recipe

This kit is also available as a standalone recipe: https://www.drupal.org/project/lms_demo_kit

Apply it to any Drupal 11 site:

```shell
ddev drush recipe /var/www/html/recipes/lms_demo_kit
```

The recipe has been tested against vanilla sites with a `standard` profile install. See the recipe's [README](https://git.drupalcode.org/project/lms_demo_kit/-/blob/1.0.x/README.md).

## A quick note about the admin theme

This kit assumes the **Claro** admin theme is enabled. This provides a familiar admin toolbar experience to long-standing Drupal site builders; however, Drupal is transitioning to **Gin** as its default admin theme.

The first-run experience may not be as smooth with Gin (see[#3611274](https://www.drupal.org/project/lms_demo_kit/issues/3611274)). If you apply the [Recipe](#recipe) onto a Drupal CMS base site, you can restore the intended first-run experience with these commands:

```
ddev composer require drupal/admin_toolbar
ddev drush en admin_toolbar admin_toolbar_tools -y
ddev drush cset system.theme admin claro -y
ddev drush pmu gin_toolbar gin_login -y
ddev drush cr
```

## Verify

Anonymous users will a course on the front page → Molly (a student) can enroll and take the course → Teacher sees her progress → `/admin/lms/activity_type` lists 12 activity types.

To reset a student's course progress:

```shell
ddev drush lms:reset-course <course_id> <user_id>
```


## Branches

| Branch | Purpose |
| :--- | :--- |
| `main` | Stable |
| `lms` | Development |

## Credits

- [drupal_lms_ddev](https://github.com/graber-1/drupal_lms_ddev) — the LMS module maintainer's quickstart, and ancestor of this kit's approach
- [Drupal LMS documentation](https://www.drupal.org/docs/extending-drupal/contributed-modules/contributed-module-documentation/drupal-lms)
