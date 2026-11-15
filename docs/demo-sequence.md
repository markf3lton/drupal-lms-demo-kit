# Demo sequence 1.0

This sequence runs on the [lms preview](https://lms-oid7hrdhuogclkekr94bmbr12kqz3rvi.tugboatqa.com/) when it's built from main's database. Complete the [Prep](#prep) steps first.

## Steps

1. **LMS Admin** imports [`nedcamp_demo_course.zip`](https://github.com/markf3lton/drupal-lms-demo-kit/blob/lms/assets/courses/nedcamp_demo_course.zip) (from the lms branch) at LMS → Import courses. It becomes **course 3**.
2. **Molly** tries to enroll and can't, because the course has no class yet.
3. **LMS Admin** adds a class to course 3.
4. **LMS Admin** adds the teacher: Members → Add member → LMS Teacher, with **Select target class: "None (Course membership)"**.
5. **LMS Admin** edits course 3, sets **Certificate** to "Certificate of completion demo", and saves. If LMS Admin's autocomplete finds nothing, do this step as admin.
6. **Molly** enrolls and takes the course.
7. **LMS Teacher** grades her written answers.
8. **Molly** goes back to course 3, clicks **"Download your certificate (PDF)"**, and gets the PDF with her name, the course title, and the date.

After the demo, reset the preview again.

## Prep

### Before each run

Reset the lms preview in the Tugboat dashboard: ⋮ → Reset.

To check it worked, run this in the preview's shell. You should see only course 1 ("Course Creator's Guide") and class 2.

```shell
vendor/bin/drush sql:query "SELECT id, label FROM groups_field_data"
```

### Setup, as admin

Log in via `tugboat shell 6af702207a342e6778bcd20d`, then `vendor/bin/drush uli`.

Create the certificate at `/admin/structure/fillpdf`:

1. Upload [`certificate-of-completion_fill_form_fields.pdf`](https://github.com/markf3lton/drupal-lms-demo-kit/blob/lms/assets/certificate-of-completion_fill_form_fields.pdf) (from the lms branch's `assets/`).
2. Title it "Certificate of completion demo".
3. Map the fields:
   - `recipient_name` → `[user:display-name]`
   - `course_name` → `[group:title]`
   - `date` → `[current-date:custom:F j, Y]`
