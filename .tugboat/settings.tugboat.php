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

// Drupal Blueprint's config directory lives at the repo root, outside the
// web root. TUGBOAT_ROOT is equivalent to the git repo root.
$settings['config_sync_directory'] = getenv('TUGBOAT_ROOT') . '/config/sync';

// Prevent Drupal from making the sites/default directory unwritable.
$settings['skip_permissions_hardening'] = TRUE;
