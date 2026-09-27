# Drupal LMS Demo Kit

You can try out [Drupal LMS](https://www.drupal.org/project/lms) in my [live preview](https://main-tygknmd1g7emlvtb1h4mkfu5nt8ii5hl.tugboatqa.com/).

## Demo Accounts

The preview site is a public sandbox, so don't enter anything real, and expect it to be reset from time to time.

Demo user accounts are provided (all use `123456`):

| Account | Role |
| :--- | :--- |
| LMS Admin | LMS Admin |
| LMS Teacher | LMS Teacher |
| Molly Larkins | Student (designated demo student) |
| Jan Kowalski, Diego Ramos | Students, Section A |
| Emma Chen, Nina Patel, Sam Carter | Students, Section B |

Access to LMS courses is managed by the [Group](https://www.drupal.org/project/group) module.

When teachers are added to existing courses by an LMS Admin, they can manage them and make changes.

## Basic verifications

- Anonymous users should see a course on the front page
- Molly (a demo student) can enroll and take the course
- `/admin/lms/activity_type` lists 12 activity types
- A Teacher can view Molly's progress in a course

## Reset

To reset a student's progress in a course (local install):

```shell
ddev drush lms:reset-course <course_id> <user_id>
```

## About this kit

To make this kit, I simply followed the installation guide in [the project's documentation](https://www.drupal.org/docs/extending-drupal/contributed-modules/contributed-module-documentation/drupal-lms).

This GitHub repo saves me a lot of time: there's a [Quick Start](#quick-start), step-by-step instructions for local development, [Tugboat preview docs](docs/tugboat.md), etc.

More docs:

- [How this kit was built](docs/build-this-kit.md), step by step
- [Maintainer's workflow](docs/maintainers-workflow.md), for forking or maintaining the kit
- [Tugboat previews](docs/tugboat.md)
- [Changelog](docs/changelog.md)

## Prerequisites

- A Docker provider (OrbStack, Docker Desktop, Colima)
- [DDEV](https://ddev.readthedocs.io/) v1.24+
- git

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
ddev drush updb -y
ddev drush cr
ddev drush uli
ddev launch
```

Do yourself a favor and snapshot the baseline database:

```shell
ddev snapshot --name=my-baseline
ddev snapshot restore my-baseline
```

## Recipe

This kit includes a Drupal recipe: https://www.drupal.org/project/lms_demo_kit

You should be able to apply it to any Drupal 11 site, but it's not been widely tested.

```shell
ddev drush recipe /var/www/html/recipes/lms_demo_kit
```

See the recipe's [README](https://git.drupalcode.org/project/lms_demo_kit/-/blob/1.0.x/README.md).

Note: Starting with Drupal LMS 1.2.x, the recipe needs the patch from [#3626214](https://www.drupal.org/i/3626214). This kit already applies it (see `patches/`).

## A note about the admin theme

For now, this kit assumes the **Claro** admin theme is enabled. Its admin toolbar is familiar to long-time Drupal site builders; however, I will transition this to use Gin, see [#3611274](https://www.drupal.org/project/lms_demo_kit/issues/3611274).

If you apply the [Recipe](#recipe) to a Drupal CMS site (which uses Gin), these commands switch it back to Claro:

```shell
ddev composer require drupal/admin_toolbar
ddev drush en admin_toolbar admin_toolbar_tools -y
ddev drush cset system.theme admin claro -y
ddev drush pmu gin_toolbar gin_login -y
ddev drush cr
```

## Credits

- [drupal_lms_ddev](https://github.com/graber-1/drupal_lms_ddev) — The ancestor of this kit's approach
- [Drupal LMS documentation](https://www.drupal.org/docs/extending-drupal/contributed-modules/contributed-module-documentation/drupal-lms)
