# Synthetic private-inline review captures

Rendered with LabFox themes and SDK fonts using fake diff paths, text and
account identities. These are widget-test renders, not live GitLab/device
screenshots. No real credentials or confidential code are displayed.

`inline-<width>-<theme>-compose.png` shows a selected multiline private draft.
`inline-<width>-<theme>-inspection.png` shows explicit inspection after an
uncertain save, before acknowledgement of another manual save. Captures cover
390/800/1200 widths in light and dark themes.

Reproduce from `apps/labfox`:

```sh
LABFOX_INLINE_DRAFT_CAPTURE=/tmp/labfox-inline-captures flutter test test/mr_pending_inline_widget_test.dart
```

See [the behavior contract](../../mr-pending-review-inline.md).
