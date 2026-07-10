# Tugboat Previews

[Tugboat](https://www.tugboatqa.com) builds a live, shareable preview site for every pull request. You can hand a URL to someone non-technical and they can click around a full Drupal LMS demo without installing anything.

This page covers only what's specific to this kit. For everything else refer to Tugboat's own docs:

- [Tugboat documentation](https://docs.tugboatqa.com/)
- [Connecting a GitHub repo](https://docs.tugboatqa.com/setting-up-tugboat/select-a-git-provider/)
- [config.yml reference](https://docs.tugboatqa.com/setting-up-services/)
- [Drupal starter configs](https://docs.tugboatqa.com/starter-configs/)

## Setup

1. Create a [Tugboat](https://www.tugboatqa.com) account and a project.
2. Connect it to your GitHub repo (Tugboat installs a GitHub app; grant it access to this repo). Tugboat reads `.tugboat/config.yml` from the repo — no dashboard configuration needed.
3. Set the branch you demo from (e.g. `main`) as a **Base Preview** so PR previews clone from it and build fast.

## How this config works

`.tugboat/config.yml` provisions previews in two phases: **`init`** runs once when a preview's containers are first created, while **`build`** runs on every push and brings code and config up to date.

- **Database settings via symlink.** Drupal needs Tugboat's database credentials. `init` symlinks `.tugboat/settings.tugboat.php` to `web/sites/default/settings.local.php`, which the stock `settings.php` includes if present. Hosting concerns stay in the hosting config.
- **Seeded database when available.** `init` imports `.tugboat/database.sql.gz` if it exists, so previews boot with demo users, courses, and rosters in place. For simplicity.
- **From-config fallback.** On branches without a database dump, `build` detects the missing install and runs `site:install --existing-config` instead.

The two files in full — `.tugboat/config.yml`:

```yaml
# Tugboat configuration for the Drupal LMS Demo Kit.
# https://docs.tugboatqa.com/starter-configs/tutorials/drupal-10/
#
# Previews import the baseline demo database from .tugboat/database.sql.gz
# on every full rebuild (init), then bring code/config up to date on every
# build. To refresh the baseline: ddev export-db --file=.tugboat/database.sql.gz
services:
  database:
    image: tugboatqa/mariadb:11.8
  php:
    image: tugboatqa/php:8.4-apache
    default: true
    depends: database
    commands:
      init:
        - docker-php-ext-install opcache
        - a2enmod headers rewrite
        # MariaDB's TLS defaults break the mysql CLI client otherwise.
        # https://docs.tugboatqa.com/troubleshooting/mysql-ssl-disabled/index.html
        - |
          cat > /etc/my.cnf <<'EOF'
          [client]
          skip-ssl = true
          EOF
        - ln -snf "${TUGBOAT_ROOT}/web" "${DOCROOT}"
        # Make Drupal read the Tugboat database settings:
        - ln -snf "${TUGBOAT_ROOT}/.tugboat/settings.tugboat.php" "${TUGBOAT_ROOT}/web/sites/default/settings.local.php"
        # Wait for the database container before importing.
        - |
          echo "Waiting for database..."
          until mysql -h database -u tugboat -ptugboat -e "SELECT 1;" &>/dev/null; do
            sleep 2
          done
          echo "Database is ready!"
        # Only runs on a full rebuild (init), not on every routine build/update.
        - |
          if [ -f "${TUGBOAT_ROOT}/.tugboat/database.sql.gz" ]; then
            echo "Importing seeded demo database..."
            zcat "${TUGBOAT_ROOT}/.tugboat/database.sql.gz" | mysql -h database -u tugboat -ptugboat --ssl=false tugboat
            echo "Seeded demo database imported."
          else
            echo "No database dump found - site will be installed from config during build."
          fi
      build:
        - composer install --optimize-autoloader
        - |
          if vendor/bin/drush status --field=bootstrap 2>/dev/null | grep -q Successful; then
            vendor/bin/drush updatedb -y
            vendor/bin/drush config:import -y
          else
            vendor/bin/drush site:install --existing-config -y
          fi
        - vendor/bin/drush cache:rebuild
```

And `.tugboat/settings.tugboat.php` (all values are Tugboat's standard non-secrets; the hash salt derives from the repo ID):

```php
<?php
$databases['default']['default'] = array (
  'database' => 'tugboat',
  'username' => 'tugboat',
  'password' => 'tugboat',
  'prefix' => '',
  'host' => 'database',
  'port' => '3306',
  'driver' => 'mysql',
);

// Use the TUGBOAT_REPO_ID to generate a hash salt for Tugboat sites.
$settings['hash_salt'] = hash('sha256', getenv('TUGBOAT_REPO_ID'));

// Drupal LMS Demo Kit's config directory lives at the repo root, outside the
// web root. TUGBOAT_ROOT is equivalent to the git repo root.
$settings['config_sync_directory'] = getenv('TUGBOAT_ROOT') . '/config/sync';

// Prevent Drupal from making the sites/default directory unwritable.
$settings['skip_permissions_hardening'] = TRUE;
```

## Gotchas

**Stale-database UUID mismatch after changing build strategy.** `init` does *not* re-run on a routine push — only on first build or an explicit **Rebuild**. If a preview existed before the seeded-database setup landed, its next push will fail `config:import` with a site-UUID mismatch: the config and the committed database agree with each other, but the preview is still running an old database. Fix: trigger a full **Rebuild** (not a retry) from the Tugboat dashboard; further previews are unaffected.

**Base Preview staleness.** If PR previews clone from a Base Preview, the same stale-database problem appears on *every* preview until the Base Preview itself is rebuilt. Rebuild the Base Preview whenever the seeded database changes meaningfully.
