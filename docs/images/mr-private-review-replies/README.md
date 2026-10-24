# Synthetic private reply captures

Dummy public discussion text and private notes render the real shared reply
composer/recovery dialog. Captures cover 390/800/1200 widths, light/dark themes,
initial composition and complete private/public-target inspection. SDK Roboto
and Material Icons preserve readable text and actual LabFox button styles.
These widget captures do not claim live GitLab or device validation.

Reproduce from `apps/labfox` with the repository Flutter SDK:

```sh
LABFOX_PRIVATE_REPLY_CAPTURE="$PWD/../../docs/images/mr-private-review-replies" \
  flutter test test/mr_pending_reply_widget_test.dart
```

| Width | Composition | Recovery inspection |
|---|---|---|
| 390 light | [Compose](390-light-compose.png) | [Inspect](390-light-recovery.png) |
| 390 dark | [Compose](390-dark-compose.png) | [Inspect](390-dark-recovery.png) |
| 800 light | [Compose](800-light-compose.png) | [Inspect](800-light-recovery.png) |
| 800 dark | [Compose](800-dark-compose.png) | [Inspect](800-dark-recovery.png) |
| 1200 light | [Compose](1200-light-compose.png) | [Inspect](1200-light-recovery.png) |
| 1200 dark | [Compose](1200-dark-compose.png) | [Inspect](1200-dark-recovery.png) |
