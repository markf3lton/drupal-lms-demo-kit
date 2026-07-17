#!/bin/bash

ddev drush eval '
$db = \Drupal::database();
$activities = $db->select("lms_activity_field_data", "a")
  ->fields("a", ["id", "vid", "type", "langcode"])
  ->execute()
  ->fetchAll();

$inserted = 0;
foreach ($activities as $activity) {
  $exists = $db->select("lms_activity__text_format", "t")
    ->condition("entity_id", $activity->id)
    ->condition("deleted", 0)
    ->countQuery()->execute()->fetchField();

  if (!$exists) {
    $db->insert("lms_activity__text_format")
      ->fields([
        "bundle" => $activity->type,
        "deleted" => 0,
        "entity_id" => $activity->id,
        "revision_id" => $activity->vid,
        "langcode" => $activity->langcode,
        "delta" => 0,
        "text_format_target_id" => "full_html",
      ])
      ->execute();
    $inserted++;
  }
}
print "lms_activity__text_format: $inserted rows inserted.\n";

$updated = $db->update("lms_activity__field_information")
  ->fields(["field_information_format" => "basic_html"])
  ->isNull("field_information_format")
  ->execute();
print "lms_activity__field_information: $updated rows updated.\n";

$updated_rev = $db->update("lms_activity_revision__field_information")
  ->fields(["field_information_format" => "basic_html"])
  ->isNull("field_information_format")
  ->execute();
print "lms_activity_revision__field_information: $updated_rev rows updated.\n";

print "\nVerification — lms_activity__text_format:\n";
$results = $db->select("lms_activity__text_format", "t")
  ->fields("t")
  ->execute()
  ->fetchAll();
foreach ($results as $row) {
  print "  entity_id={$row->entity_id} bundle={$row->bundle} format={$row->text_format_target_id}\n";
}
'
