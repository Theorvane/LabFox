# Synthetic selected-note publication captures

Dummy private notes and public discussion text render the real pending review
panel and shared confirmation/recovery dialog. Captures cover 390/800/1200
widths, light/dark themes and initial publication/two-sided inspection. SDK
Roboto and Material Icons preserve readable text and actual LabFox button styles.
These widget captures do not claim live GitLab or device validation.

Reproduce from `apps/labfox` with the repository Flutter SDK:

```sh
LABFOX_SINGLE_PUBLICATION_CAPTURE="$PWD/../../docs/images/mr-pending-single-publication" \
  flutter test test/mr_pending_review_single_publish_widget_test.dart
```

| Width | Initial confirmation | Recovery inspection |
|---|---|---|
| 390 light | [Publish](publish-390-light.png) | [Inspect](inspection-390-light.png) |
| 390 dark | [Publish](publish-390-dark.png) | [Inspect](inspection-390-dark.png) |
| 800 light | [Publish](publish-800-light.png) | [Inspect](inspection-800-light.png) |
| 800 dark | [Publish](publish-800-dark.png) | [Inspect](inspection-800-dark.png) |
| 1200 light | [Publish](publish-1200-light.png) | [Inspect](inspection-1200-light.png) |
| 1200 dark | [Publish](publish-1200-dark.png) | [Inspect](inspection-1200-dark.png) |
