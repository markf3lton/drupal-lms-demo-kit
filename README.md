# Drupal LMS Demo Kit

Try out [Drupal LMS](https://www.drupal.org/project/lms) in a live [demo environment](https://main-tygknmd1g7emlvtb1h4mkfu5nt8ii5hl.tugboatqa.com/).

The [main](https://main-tygknmd1g7emlvtb1h4mkfu5nt8ii5hl.tugboatqa.com/) branch of this repo aligns with the [LMS Demo Kit recipe](https://www.drupal.org/project/lms_demo_kit) on Drupal.org. The [lms](https://lms-oid7hrdhuogclkekr94bmbr12kqz3rvi.tugboatqa.com/) branch is a demo (created for New England Drupal Camp 2026) demonstrating activity types, certificates, xAPI import, and AI-graded answers (see [demo sequence](docs/demo-sequence.md)).

## Prerequisites

- Docker provider (OrbStack, Docker Desktop, Colima)
- [DDEV](https://ddev.readthedocs.io/) v1.24+
- git

PHP, Composer and Drush run inside DDEV, so you don't need them installed locally.

## Quick Start

```shell
git clone https://github.com/markf3lton/drupal-lms-demo-kit.git
cd drupal-lms-demo-kit
ddev start
ddev composer install

# Install from config
ddev drush site:install --existing-config -y

# Add the demo users
./scripts/create-demo-users.sh
```

To import the demo course, log in (as an "LMS Admin") and navigate to LMS > Import courses.

```shell
# Log in
ddev drush uli --name="LMS Admin" /admin/lms

# Manually upload the file at assets/courses/course_creators_guide_en_v1.zip
```

### LMS admin steps

A course imported from an archive has no class; therefore students will see "No open classes" instead of "Enroll." Drupal LMS builds courses and classes on the [Group](https://www.drupal.org/project/group) module.

To set up the class, perform the following steps as an LMS Admin:

1. From the **Groups** menu, choose **Add group**, then **Class**. Give it a title and choose **Create Class and become a member**.
2. From the **LMS** menu, edit the course and select the **All entities** tab. Choose **Add existing entity**, then **LMS Class**, select your class, and save.

Students now see **Enroll** on the course.

### DDEV snapshots

Take snapshots of your demo environment to make it easy to replay your demo sequences:

```shell
ddev snapshot --name=demo-ready
```

To return to that snapshot later:

```shell
ddev snapshot restore demo-ready
```

## Demo Accounts

The live demo is a public sandbox: don't enter anything real, and expect it to be reset.

Demo user accounts below (they all use `123456`):

| Account | Role |
| :--- | :--- |
| LMS Admin | LMS Admin |
| LMS Teacher | LMS Teacher |
| Molly Larkins | Student (designated demo student) |
| Jan Kowalski, Diego Ramos, Emma Chen, Nina Patel, Sam Carter | Students |

Drupal LMS course access is managed by the [Group](https://www.drupal.org/project/group) module.

The LMS Admin and LMS Teacher roles can manage courses.

## What you should see

After the LMS admin steps:

- Anonymous users see a course on the front page
- Molly (demo student) can enroll and take the course
- `/admin/lms/activity_type` lists 12 activity types

## Reset

To reset a student's progress (DDEV):

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
│   ├── certificates/           # Fillable certificate PDF
│   └── courses/                # Course packages for LMS > Import courses
├── config/
│   └── sync/                   # Exported site config
├── docs/                       # Guides, demo sequence, changelog
├── recipes/
│   └── lms_demo_kit/           # LMS layer as a Drupal recipe
│       ├── recipe.yml
│       ├── config/             # LMS config, portable (no UUIDs)
│       ├── content/            # Starter course, class, lessons, activities
│       └── scripts/            # Copy of create-demo-users.sh
├── scripts/
│   └── create-demo-users.sh    # Demo user creation (plus maintenance scripts)
└── web/                        # Drupal docroot (core/contrib gitignored)
```

## Changelog

- [Changelog](docs/changelog.md)

## Recipe

This kit includes a Drupal recipe: https://www.drupal.org/project/lms_demo_kit

### A note about Drupal CMS

This kit has not been tested extensively with Drupal CMS yet, and it uses the Claro admin theme by default (not Gin). To switch from Gin to Claro:

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
