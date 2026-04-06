# Design system (`emp_ai_ds_northstar`)

## Scope

This package is the **token + theme** layer for Northstar: semantic colors, Material 3 [ThemeData], typography helpers, and optional DTCG JSON assets. It intentionally avoids networking, auth, and feature flags.

## Giving Figma / tokens to humans or AI assistants

Assistants **cannot** open the Figma desktop app, log into your account, or parse binary `.fig` files. A **public web link** alone is often useless without an authenticated browser session.

What works well:

| Method | Best for |
|--------|-----------|
| **Screenshots / exports (PNG/PDF)** of Typography, Color, and component frames | Quick alignment (like the V3 NORTHSTAR Typography pages). |
| **Figma Variables → JSON** (plugins or [Figma API](https://www.figma.com/developers/api)) | Machine-readable colors, type, radii; paste or commit JSON and we map to Dart. |
| **Short written spec** in-repo (table: token name, hex, font/size/line height/weight) | Full control; easiest to review in PRs. |
| **Paste frame content** in chat (text + numbers) | Iterating on one section at a time. |

The [V3 NORTHSTAR file](https://www.figma.com/design/MkNTFYa9Pw4hlp8LgCtMsm/V3-NORTHSTAR_-DESIGNSYSTEM) can stay the visual source of truth; **canonical implementation values** live in Dart (`NorthstarBaseTokens`, `NorthstarFigmaTypography`, etc.) and should be updated when Figma changes.

## Atomic design (starter)

| Layer | Examples in package |
|-------|---------------------|
| **Token** | `NorthstarTextRole` → maps Figma names to `TextTheme` slots when using `NorthstarTypographyStyle.figmaNorthstarV3` |
| **Atom** | `NorthstarTextAtom` |
| **Molecule** | `NorthstarLabeledValueRow` |
| **Organism** | `NorthstarPageHeader` |

This is a **small** starter set. Extend with more organisms when Figma components are specified. Prefer `NorthstarTextRole` + `Theme.of(context).textTheme` instead of a giant `TypeUtilDs3`-style switch when the Figma scale is already encoded in the theme.

## Light / dark / system mode

1. Hold a [`NorthstarThemeModeController`](../../packages/emp_ai_ds_northstar/lib/src/northstar_theme_controller.dart) (extends `ChangeNotifier`).
2. Wrap the app root in [`ListenableBuilder`](https://api.flutter.dev/flutter/widgets/ListenableBuilder-class.html) and set [`MaterialApp.themeMode`](https://api.flutter.dev/flutter/material/MaterialApp/themeMode.html) from `controller.themeMode`.
3. Call `controller.cycleThemeMode()` or `controller.themeMode = ThemeMode.dark` from any button or settings screen.

The sample host uses [`northstarThemeModeControllerProvider`](../../apps/emp_ai_boilerplate_app/lib/src/theme/northstar_theme_mode_provider.dart) and a shell **AppBar** action to cycle modes.

To **persist** mode (e.g. `shared_preferences`), keep the controller in the host and restore the saved value when creating the provider.

## Using colors

| Need | API |
|------|-----|
| Material roles (primary, surface, error, …) | `Theme.of(context).colorScheme` |
| Northstar-only roles (success, warning, inverseSurface, …) | `NorthstarColorTokens.of(context)` (requires themes built with [`NorthstarTheme.buildThemeData`](../../packages/emp_ai_ds_northstar/lib/src/northstar_theme.dart)) |

Example:

```dart
final scheme = Theme.of(context).colorScheme;
final ns = NorthstarColorTokens.of(context);
// scheme.primary, ns.success, ns.onSuccess, …
```

## Typography (V3 NORTHSTAR Figma)

Default is **`NorthstarTypographyStyle.figmaNorthstarV3`**: [Lexend Deca](https://fonts.google.com/specimen/Lexend+Deca) (hero, title, Lexend page title) and [Inter](https://fonts.google.com/specimen/Inter) (Inter page title, subtitles, labels, body, subheadings). Fonts load via [`google_fonts`](https://pub.dev/packages/google_fonts). “Content Black” → `ColorScheme.onSurface`, “Content Gray” → `ColorScheme.onSurfaceVariant`.

Implementation: [`NorthstarFigmaTypography`](../../packages/emp_ai_ds_northstar/lib/src/northstar_figma_typography.dart) (mapping table in dartdoc). Semantic aliases: [`NorthstarTextRole`](../../packages/emp_ai_ds_northstar/lib/src/tokens/northstar_text_role.dart).

```dart
// Figma-aligned slots
Theme.of(context).textTheme.displayLarge   // Lexend Hero 40/40
Theme.of(context).textTheme.displayMedium // Lexend Title 24/24
Theme.of(context).textTheme.displaySmall   // Lexend Page Title 18/28
Theme.of(context).textTheme.headlineLarge  // Inter Page Title 18/28
// …see NorthstarFigmaTypography dartdoc

// Or named roles
NorthstarTextRole.hero.style(context)
```

**Legacy / generic M3 scale:** set `typographyStyle: NorthstarTypographyStyle.material3` on [`NorthstarTheme.buildThemeData`](../../packages/emp_ai_ds_northstar/lib/src/northstar_theme.dart) or [`NorthstarBranding`](../../packages/emp_ai_ds_northstar/lib/src/northstar_branding.dart). Then `fontFamily` on branding applies to that M3 theme.

**Offline / CI:** first `google_fonts` load may need network; the package caches font files on disk afterward. For strict air-gapped builds, bundle Lexend Deca + Inter as assets and swap the implementation later.

## White-label and different palettes (same token names)

1. **Subclassing / const sets** — Define new `NorthstarColorTokens` const values (see [`NorthstarDtcgPresets`](../../packages/emp_ai_ds_northstar/lib/src/northstar_dtcg_presets.dart)) or `NorthstarColorTokens.v3.copyWith(...)`.
2. **Host branding object** — Use [`NorthstarBranding`](../../packages/emp_ai_ds_northstar/lib/src/northstar_branding.dart) with your light/dark token instances and pass to `MaterialApp` as `theme:` / `darkTheme:` via `branding.theme(Brightness.light)`.
3. **Optional seed** — `seedColor` on `NorthstarBranding` / `NorthstarTheme.buildThemeData` runs [flex_seed_scheme](https://pub.dev/packages/flex_seed_scheme) for generated primaries while keeping the semantic extension for custom roles.

Keep **one** `ThemeData` pair per app build variant; swap `NorthstarBranding` per customer in the host, not inside the DS package.

## DTCG / Figma Variables

JSON exports live under `packages/emp_ai_ds_northstar/design_tokens/dtcg/`. Dart presets mirror them in `NorthstarDtcgPresets`. Re-export from Figma, diff JSON, then update the preset file or regenerate via a small script if you add automation.

## Widgets vs tokens (see also [design_system_widgets.md](design_system_widgets.md))

`emp_ai_ds_northstar` should stay **lean**: tokens + theme. Shared **widgets** (buttons, fields, page chrome) belong in a separate package (e.g. `emp_ai_ds_widgets` or `emp_ai_widgets_northstar`) that **depends on** the token package, so apps can adopt colors without pulling every molecule.

## How to hand off Figma (atoms / molecules / organisms)

When you want implementation help:

1. **Link or export** the Figma file (view access or `.fig` + Variables JSON export).
2. **List frame names** or component set names for each level (atom: `Button/Primary`, molecule: `Card/News`, organism: `Header/Global`).
3. **Map** each component to **token names** (color styles / variables) it must use — ideally identical strings to `NorthstarColorTokens` roles or a table in a short spec.
4. **Note states**: default, hover, disabled, error, dark mode.
5. **Target package**: say whether the widget belongs in **DS widgets** (generic) or a **feature module** (domain-specific).

Paste that spec in a ticket or markdown in the repo; no special Cursor syntax is required.
