#!/bin/bash

ddev drush sql:query "UPDATE lms_activity__field_information SET field_information_format = 'basic_html' WHERE field_information_format IS NULL;"
ddev drush sql:query "UPDATE lms_activity_revision__field_information SET field_information_format = 'basic_html' WHERE field_information_format IS NULL;"
ddev drush cr
