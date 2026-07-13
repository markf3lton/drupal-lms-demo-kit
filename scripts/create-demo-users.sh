#!/usr/bin/env bash
# Creates the demo accounts for the Drupal LMS demo kit.
# Roles lms_admin / lms_teacher come from config/sync.

echo "Creating: LMS Admin (lms_admin role), LMS Teacher (lms_teacher role), six demo students. Grant the lms_admin role to user 1."

set -e

if command -v ddev >/dev/null 2>&1 && [ -f .ddev/config.yaml ]; then
  DRUSH="ddev drush"
else
  DRUSH="drush"
fi

create_user() {
  local NAME="$1" MAIL="$2"
  if $DRUSH user:information "$NAME" >/dev/null 2>&1; then
    echo "User '$NAME' already exists — skipping."
  else
    $DRUSH user:create "$NAME" --mail="$MAIL" --password="123456"
  fi
}

# 1. Give user 1 the LMS Admin role (required — LMS screens misbehave without it)
ADMIN_NAME=$($DRUSH user:information --uid=1 --field=name)
$DRUSH user:role:add lms_admin "$ADMIN_NAME"

# 2. Demo accounts you'll log in as during the presentation
create_user "LMS Admin" "lms.admin@example.com"
$DRUSH user:role:add lms_admin "LMS Admin"

create_user "LMS Teacher" "lms.teacher@example.com"
$DRUSH user:role:add lms_teacher "LMS Teacher"

# 3. Student roster (authenticated users; Group handles course access)
for NAME in "Molly Larkins" "Jan Kowalski" "Diego Ramos" "Emma Chen" "Nina Patel" "Sam Carter"; do
  MAIL=$(echo "$NAME" | tr '[:upper:] ' '[:lower:].')
  create_user "$NAME" "${MAIL}@example.com"
done

echo "Demo accounts ready. Password for all: 123456"
