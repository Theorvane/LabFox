---
name: responsive-screen
description: Use when branching a screen across Mobile / Tablet / Desktop, or when working on Desktop-only UI (Multi-pane, Command Palette, keyboard shortcuts).
---

# Responsive screens

## Principle

Do not build separate screens per platform. Branch **a single feature codebase** on width.
Features and business logic are fully shared; only the layout differs.

## Breakpoints

| Width | Mode | Layout |
|---|---|---|
| < 600 | Mobile | Bottom Navigation (`Home · Settings · Search · Me`), single pane, push navigation |
| 600–1000 | Tablet / Compact Desktop | Navigation Rail, 2 panes |
| > 1000 | Desktop | Navigation Rail + Multi-pane, Command Palette, Split Diff |

## Do not use `Platform.isX`

The deciding factor is **screen width**.

```dart
// X
if (Platform.isAndroid) { ... }

// O
LayoutBuilder(
  builder: (context, constraints) => constraints.maxWidth < 600
      ? _MobileLayout()
      : _WideLayout(),
)
```

Why: it has to work correctly on tablets, foldables, desktop window resizing, and split screen.
Use `Platform.isX` only where **the OS genuinely differs**, such as file system access or platform integration.

## Navigation flow

```
Mobile    Projects → Project → MR → Diff        (push)
Desktop   Projects │ Merge Requests │ Diff       (shown at once)
```

On Desktop, selection state across panes is managed by a provider.
Mobile routing and Desktop pane selection must **share the same state** so the transition is seamless when the window is resized.

## Desktop only

Attach these only at wide widths. Do not put them in the Mobile code path.

- Navigation Rail
- Multi-pane
- Keyboard Shortcuts
- Right Click Menu
- Drag & Drop
- Command Palette (`⌘K` / `Ctrl+K`)
- Multi Window
- Split Diff (`DiffViewer`'s split mode)

Command Palette results mix Project / Issue / MR into one list and
reuse the same search path as the `Search` screen.

## Verification

After the work, check at a minimum of two widths.

- Narrow (< 600) — overflow, clipping, whether the bottom nav covers content
- Wide (> 1000) — whether text stretches excessively (cap the body max width)

Resize the window live and watch for layouts breaking or state resetting.

## Definition of done

- [ ] Layout is not split by `Platform.isX`
- [ ] Mobile / Desktop layouts share the same Controller/Repository
- [ ] Both narrow and wide widths checked
- [ ] State is preserved when the window is resized
