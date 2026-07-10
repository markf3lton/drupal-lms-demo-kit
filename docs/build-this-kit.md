# Build This Kit

The commands that produced this repo, in order.

## Set up Drupal

```shell
composer create-project drupal/recommended-project:^11.4 drupal-lms-demo-kit
cd drupal-lms-demo-kit
```

Create `.gitignore` at the repo root:

```
# Composer-managed
/vendor/
/web/core/
/web/modules/contrib/
/web/themes/contrib/
/web/profiles/contrib/
/web/libraries/

# Sensitive
/web/sites/*/*settings*.php
!/web/sites/*/default.settings.php
/web/sites/*/*services*.yml
!/web/sites/*/default.services.yml

# User-generated content
/web/sites/*/files/
/web/sites/*/private/

# Test environments
/web/sites/simpletest/
```

Launch DDEV and add Drush

```shell
ddev config --project-type drupal --docroot web --auto
ddev start
ddev composer require --dev drush/drush

git init
git add .
git commit -m "Initial commit"
```

Uncomment `config_sync_directory` in `web/sites/default/settings.php` and set it:

```php
$settings['config_sync_directory'] = '../config/sync';
```

Only non-sensitive config in `settings.php`; secrets go in the gitignored `settings.local.php`. Commit it now:

```shell
git add -f web/sites/default/settings.php
git commit -m "Update settings.php for config/sync"
```

Site install

```shell
ddev drush site:install standard -y
ddev drush cex
git add config
git commit -m "Drupal default config:export"
```

Remove core navigation (not used in this demo)

```shell
ddev drush pmu -y navigation
ddev drush cex
git add config
git commit -m "Uninstall navigation module"
```

## Add Drupal LMS

(This is a set of recommended starter modules)

```shell
ddev composer require \
  drupal/lms:^1.1 \
  drupal/lms_certificate:@dev \
  drupal/lms_certificate_entity:@dev \
  drupal/lms_xapi:@alpha \
  drupal/lms_yaml:@beta \
  'drupal/lms_membership_request:*@alpha' \
  'drupal/grequest:*@RC' \
  drupal/admin_toolbar:^3.6 \
  drupal/views_bulk_operations:^4.4

ddev drush en -y lms lms_certificate lms_certificate_entity lms_xapi lms_yaml \
  lms_membership_request grequest admin_toolbar admin_toolbar_tools \
  views_bulk_operations
```
The per-package `@dev`/`@alpha`/`@beta`/`@RC` flags override stability for those packages only.

Lock it in:

```shell
ddev drush cex
git add composer.json composer.lock config/sync
git commit -m "Add Drupal LMS and ecosystem modules, config:export"
```


## Import LMS-specific config for the quick start

Bring in LMS config (activity types with their fields and displays, group types and roles, LMS views, course navigation blocks) into `config/sync/`.

This set was adopted from https://github.com/graber-1/drupal_lms_ddev/

```shell
ddev drush site:install --existing-config -y
ddev drush config:status    # must report no differences
git add config/sync
git commit -m "Import LMS-specific config"
```

## Create demo users

See the script for this

```shell
./scripts/create-demo-users.sh
```

## Import demo course

From the Drupal LMS admin UI, go to `/admin/lms/yaml/import` to import your demo course.

See `assets/courses` in this repo.

```shell
ddev drush user:information --uid=1     # confirm no real email/password
ddev export-db --file=.tugboat/database.sql.gz
ddev snapshot --name=demo-ready

git add scripts/ assets/ .tugboat/
git commit -m "Demo users, courses, and database dump"
```

## Recipe

The LMS layer is packaged as a Drupal recipe for application to any existing Drupal 11 site.

`recipes/lms_demo_kit/`:

- `recipe.yml` — module install list plus config import
- `config/` — the LMS config set, with `uuid:` and `_core:` lines stripped from every file
- `content/` — starter course, exported with Default Content:

```shell
ddev composer require drupal/default_content
ddev drush pm:enable default_content -y
ddev drush default-content:export-references group <id> --folder=recipes/lms_demo_kit/content
```

Apply it:

```shell
ddev drush site:install standard -y
ddev drush recipe /var/www/html/recipes/lms_demo_kit
./scripts/create-demo-users.sh
```

## Tugboat preview

An essential part of this demo kit is sharing Drupal LMS with evaluators via preview links. A Tugboat config is provided — see [tugboat.md](tugboat.md). Note that Tugboat imports the latest `.tugboat/database.sql.gz` when it builds the preview.


## Changelog

See [here](changelog.md)
