# Drupal LMS Demo Kit

Try out [Drupal LMS](https://www.drupal.org/project/lms) in a live [demo environment](https://main-tygknmd1g7emlvtb1h4mkfu5nt8ii5hl.tugboatqa.com/).

Or follow the [Quick Start](https://github.com/markf3lton/drupal-lms-demo-kit#quick-start) instructions to install it locally.


## Demo Accounts

The demo is a public sandbox: don't enter anything realm and expect it to be reset from time to time.

Demo user accounts below (they all use `123456`):

| Account | Role |
| :--- | :--- |
| LMS Admin | LMS Admin |
| LMS Teacher | LMS Teacher |
| Molly Larkins | Student (designated demo student) |
| Jan Kowalski, Diego Ramos | Students, Section A |
| Emma Chen, Nina Patel, Sam Carter | Students, Section B |

Drupal LMS course access is managed by the [Group](https://www.drupal.org/project/group) module.

The LMS Admin and LMS Teacher roles can manage courses.

## What you should see

- Anonymous users see a course on the front page
- Molly (demo student) can enroll and take the course
- `/admin/lms/activity_type` lists 12 activity types
- The LMS Teacher can view Molly's progress through the course

## Reset

To reset a studen'ts progress (local environment):

```shell
ddev drush lms:reset-course <course_id> <user_id>
```

## About this kit

My setup follows the installation guide at (https://www.drupal.org/docs/extending-drupal/contributed-modules/contributed-module-documentation/drupal-lms).

See [Tugboat notes](docs/tugboat.md) and other resources in the project [docs](https://github.com/markf3lton/drupal-lms-demo-kit/tree/main/docs).

## Changelog

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
```

To import the demo course:

```
# Import the demo course (assets/courses) at LMS > Import courses:
ddev drush uli --name="LMS Admin" /admin/lms
```

Alternatively, import a seeded database from `.tugboat/database.sql.gz` 

Once you're up an running, snapshot the baseline with DDEV:

```shell
ddev snapshot --name=lms-baseline
ddev snapshot restore lms-baseline
```

## Recipe

This kit includes a Drupal recipe: https://www.drupal.org/project/lms_demo_kit

You should be able to apply it to any Drupal 11 site, but it has not been widely tested.

See the recipe [README](https://git.drupalcode.org/project/lms_demo_kit/-/blob/1.0.x/README.md).

## A note about the admin theme

This kit assumes the **Claro** admin theme is enabled. The admin toolbar from Claro is familiar to Drupal site builders; I plan to transition this to use Gin.

If you applied the [Recipe](#recipe) to a Drupal CMS site (which uses Gin), these commands should switch you back back to Claro:

```shell
ddev composer require drupal/admin_toolbar
ddev drush en admin_toolbar admin_toolbar_tools -y
ddev drush cset system.theme admin claro -y
ddev drush pmu gin_toolbar gin_login -y
ddev drush cr
```

## Credits

- [drupal_lms_ddev](https://github.com/graber-1/drupal_lms_ddev) — The inspiration for this kit's approach
- [Drupal LMS documentation](https://www.drupal.org/docs/extending-drupal/contributed-modules/contributed-module-documentation/drupal-lms)
