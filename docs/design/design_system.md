# Design system (`emp_ai_ds_northstar`)

## Scope

This package is the **token + theme** layer for Northstar: semantic colors, Material 3 [ThemeData], typography helpers, **spacing scale** (`NorthstarSpacing`), and optional DTCG JSON assets. It intentionally avoids networking, auth, and feature flags.

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
| **Token** | `NorthstarTextRole` → maps Figma names to `TextTheme` slots when using `NorthstarTypographyStyle.figmaNorthstarV3`; **`NorthstarSpacing`** → Figma `space-*` as logical pixels |
| **Atom** | `NorthstarTextAtom` |
| **Molecule** | `NorthstarLabeledValueRow` |
| **Organism** | `NorthstarPageHeader` |

This is a **small** starter set. Extend with more organisms when Figma components are specified. Prefer `NorthstarTextRole` + `Theme.of(context).textTheme` instead of a giant `TypeUtilDs3`-style switch when the Figma scale is already encoded in the theme.

## Light / dark / system mode

1. Hold a [`NorthstarThemeModeController`](https://github.com/maplepam/ecosystem-platform/blob/main/packages/emp_ai_ds_northstar/lib/src/northstar_theme_controller.dart) (extends `ChangeNotifier`).
2. Wrap the app root in [`ListenableBuilder`](https://api.flutter.dev/flutter/widgets/ListenableBuilder-class.html) and set [`MaterialApp.themeMode`](https://api.flutter.dev/flutter/material/MaterialApp/themeMode.html) from `controller.themeMode`.
3. Call `controller.cycleThemeMode()` or `controller.themeMode = ThemeMode.dark` from any button or settings screen.

The sample host uses [`northstarThemeModeControllerProvider`](../../apps/emp_ai_boilerplate_app/lib/src/theme/northstar_theme_mode_provider.dart) and a shell **AppBar** action to cycle modes.

To **persist** mode (e.g. `shared_preferences`), keep the controller in the host and restore the saved value when creating the provider.

## Using colors

| Need | API |
|------|-----|
| Material roles (primary, surface, error, …) | `Theme.of(context).colorScheme` |
| Northstar-only roles (success, warning, inverseSurface, …) | `NorthstarColorTokens.of(context)` (requires themes built with [`NorthstarTheme.buildThemeData`](https://github.com/maplepam/ecosystem-platform/blob/main/packages/emp_ai_ds_northstar/lib/src/northstar_theme.dart)) |

Example:

```dart
final scheme = Theme.of(context).colorScheme;
final ns = NorthstarColorTokens.of(context);
// scheme.primary, ns.success, ns.onSuccess, …
```

## Typography (V3 NORTHSTAR Figma)

Default is **`NorthstarTypographyStyle.figmaNorthstarV3`**: [Lexend Deca](https://fonts.google.com/specimen/Lexend+Deca) (hero, title, Lexend page title) and [Inter](https://fonts.google.com/specimen/Inter) (Inter page title, subtitles, labels, body, subheadings). Fonts load via [`google_fonts`](https://pub.dev/packages/google_fonts). “Content Black” → `ColorScheme.onSurface`, “Content Gray” → `ColorScheme.onSurfaceVariant`.

Implementation: [`NorthstarFigmaTypography`](https://github.com/maplepam/ecosystem-platform/blob/main/packages/emp_ai_ds_northstar/lib/src/northstar_figma_typography.dart) (mapping table in dartdoc). Semantic aliases: [`NorthstarTextRole`](https://github.com/maplepam/ecosystem-platform/blob/main/packages/emp_ai_ds_northstar/lib/src/tokens/northstar_text_role.dart).

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

**Legacy / generic M3 scale:** set `typographyStyle: NorthstarTypographyStyle.material3` on [`NorthstarTheme.buildThemeData`](https://github.com/maplepam/ecosystem-platform/blob/main/packages/emp_ai_ds_northstar/lib/src/northstar_theme.dart) or [`NorthstarBranding`](https://github.com/maplepam/ecosystem-platform/blob/main/packages/emp_ai_ds_northstar/lib/src/northstar_branding.dart). Then `fontFamily` on branding applies to that M3 theme.

**Offline / CI:** first `google_fonts` load may need network; the package caches font files on disk afterward. For strict air-gapped builds, bundle Lexend Deca + Inter as assets and swap the implementation later.

## Spacing (V3 NORTHSTAR)

Northstar spacing is **not** on `ThemeData`; it is a **static scale** aligned with the Figma **Spacing** page (`space-2` … `space-96`). Implementation: [`NorthstarSpacing`](https://github.com/maplepam/ecosystem-platform/blob/main/packages/emp_ai_ds_northstar/lib/src/tokens/northstar_spacing.dart) and [`NorthstarSpacingToken`](https://github.com/maplepam/ecosystem-platform/blob/main/packages/emp_ai_ds_northstar/lib/src/tokens/northstar_spacing.dart).

### What the tokens mean

| Concept | Detail |
|--------|--------|
| **Units** | Values are **logical pixels** (Flutter `dp` / `double`) — same idea as the Figma **px** column at 1×. |
| **rem** | Figma rem uses a **16px root** (e.g. `space-16` → `1rem` → 16 logical px). The ordered list `NorthstarSpacing.scale` carries `name`, `rem`, and `logicalPixels` for specs and tooling. |
| **Named steps** | `NorthstarSpacing.space2` … `space96` — prefer these over raw literals so diffs map to design tokens. |
| **Negative spacing** | V3 allows negative values for breakout/overlap in design; the Dart table is **positive-only**. Use explicit negative `EdgeInsets` / transforms only when design calls for it, and extend the token layer if you need **named** negative steps. |

### Usage in Flutter

Use constants anywhere you would pass a `double` for layout:

| Pattern | Example |
|---------|---------|
| Padding / margin | `EdgeInsets.all(NorthstarSpacing.space16)`, `EdgeInsets.symmetric(horizontal: NorthstarSpacing.space24)` |
| Fixed gaps | `SizedBox(height: NorthstarSpacing.space8)`, `SizedBox(width: NorthstarSpacing.space12)` |
| `Row` / `Column` **`spacing`** | `Column(spacing: NorthstarSpacing.space8, children: [...])` (Flex spacing between children) |
| `Wrap` | `spacing:` / `runSpacing:` with the same constants |
| Dividers / separators | `Divider(height: NorthstarSpacing.space32)` when a token-sized band matches the spec |

**Do not** invent ad-hoc spacing (e.g. `13`, `18`) unless design adds those tokens; stick to the scale so host and mini-apps stay visually consistent.

### Live reference in the app

The package exports [`NorthstarSpacingScaleTable`](https://github.com/maplepam/ecosystem-platform/blob/main/packages/emp_ai_ds_northstar/lib/src/showcase/northstar_spacing_scale_table.dart) — a visual table of token / rem / px used on the **Design system showcase** (`NorthstarDesignSystemShowcasePage`). Wire that route in your host if you want designers and engineers to compare implementation to Figma side by side.

## White-label and different palettes (same token names)

For the **sample host** file map and step-by-step (Acme tokens, `BoilerplateApp`, accent seed), see **[Boilerplate host: theming checklist](#boilerplate-host-theming-checklist)** below.

1. **Subclassing / const sets** — Start from [`NorthstarBaseTokens`](https://github.com/maplepam/ecosystem-platform/blob/main/packages/emp_ai_ds_northstar/lib/src/northstar_base_tokens.dart) (`light` / `dark` / `whiteLabeledLight`) and use `copyWith`, or add a new `const NorthstarColorTokens(...)` in the host when you need a fully custom palette.
2. **Host branding object** — Use [`NorthstarBranding`](https://github.com/maplepam/ecosystem-platform/blob/main/packages/emp_ai_ds_northstar/lib/src/northstar_branding.dart) with your light/dark token instances and pass to `MaterialApp` as `theme:` / `darkTheme:` via `branding.theme(Brightness.light)`.
3. **Optional seed** — `seedColor` on `NorthstarBranding` / `NorthstarTheme.buildThemeData` runs [flex_seed_scheme](https://pub.dev/packages/flex_seed_scheme) for generated primaries while keeping the semantic extension for custom roles.

Keep **one** `ThemeData` pair per app build variant; swap `NorthstarBranding` per customer in the host, not inside the DS package.

<a id="boilerplate-host-theming-checklist"></a>

## Boilerplate host: theming checklist (`emp_ai_boilerplate_app`)

Use this after you clone or fork when you want **default brand colors**, **user-tunable accent**, or **new semantic colors** to line up everywhere (shell rail, drawer, `ColorScheme`, and `NorthstarColorTokens.of`).

### 1. Default light / dark palettes (no runtime accent)

| Step | File / type | What to do |
|------|-------------|------------|
| **A. Host preset** | [`apps/emp_ai_boilerplate_app/lib/src/theme/acme_brand_tokens.dart`](../../apps/emp_ai_boilerplate_app/lib/src/theme/acme_brand_tokens.dart) | Point `light` / `dark` at const sets you own. Easiest: `static const NorthstarColorTokens light = NorthstarBaseTokens.light;` → swap for `NorthstarColorTokens(...)` or `NorthstarBaseTokens.whiteLabeledLight.copyWith(primary: …)` ([`NorthstarBaseTokens`](https://github.com/maplepam/ecosystem-platform/blob/main/packages/emp_ai_ds_northstar/lib/src/northstar_base_tokens.dart)). Rename the file/class to match your product if you drop the “Acme” sample name. |
| **B. Optional: shared package preset** | [`packages/emp_ai_ds_northstar/lib/src/northstar_base_tokens.dart`](https://github.com/maplepam/ecosystem-platform/blob/main/packages/emp_ai_ds_northstar/lib/src/northstar_base_tokens.dart) | Edit only if several apps should share the **same** canonical Dart numbers; otherwise keep product-specific values in the host (A). |
| **C. Wire `MaterialApp`** | [`apps/emp_ai_boilerplate_app/lib/src/app/boilerplate_app.dart`](../../apps/emp_ai_boilerplate_app/lib/src/app/boilerplate_app.dart) | Build [`NorthstarBranding`](https://github.com/maplepam/ecosystem-platform/blob/main/packages/emp_ai_ds_northstar/lib/src/northstar_branding.dart) with `lightTokens` / `darkTokens` from (A) and pass `seedColor` from the optional accent provider (below). |

With **`seedColor: null`**, [`NorthstarTheme.buildThemeData`](https://github.com/maplepam/ecosystem-platform/blob/main/packages/emp_ai_ds_northstar/lib/src/northstar_theme.dart) uses `tokens.toColorScheme` and installs your **`NorthstarColorTokens`** instance unchanged in `ThemeData.extensions`.

### 2. Optional user accent (seed color)

| Piece | File | Role |
|-------|------|------|
| Persisted seed | [`user_accent_seed_notifier.dart`](../../apps/emp_ai_boilerplate_app/lib/src/theme/user_accent_seed_notifier.dart) | `Color?` in `shared_preferences`; `null` = brand default. |
| Root theme | [`boilerplate_app.dart`](../../apps/emp_ai_boilerplate_app/lib/src/app/boilerplate_app.dart) | `ref.watch(userAccentSeedNotifierProvider)` → `NorthstarBranding(..., seedColor: accent)`. |
| Demo UI | [`theme_settings_screen.dart`](../../apps/emp_ai_boilerplate_app/lib/src/screens/theme_settings_screen.dart) | Swatches + “Brand default”; not required in production. |

When **`seedColor` is non-null**, the theme builder runs [flex_seed_scheme](https://pub.dev/packages/flex_seed_scheme) to produce a full **`ColorScheme`**, then **merges** primary/surface/outline (and related Material roles) back into the **`NorthstarColorTokens`** extension so **`NorthstarColorTokens.of(context)`** stays aligned with **`Theme.of(context).colorScheme`** (shell, overview cards, DS widgets). Semantic-only fields (**success**, **warning**, …) stay from your base token set until you override them in Dart.

### 3. New or renamed color **roles** on `NorthstarColorTokens`

This is a **package** change in `emp_ai_ds_northstar` (all apps that depend on it should agree):

1. Add fields on [`NorthstarColorTokens`](https://github.com/maplepam/ecosystem-platform/blob/main/packages/emp_ai_ds_northstar/lib/src/northstar_color_tokens.dart) (`const` constructor, `copyWith`, `lerp`, `==` / `hashCode`).
2. Extend [`toColorScheme`](https://github.com/maplepam/ecosystem-platform/blob/main/packages/emp_ai_ds_northstar/lib/src/northstar_color_tokens.dart) only if the role maps to a **Material** slot consumers expect in `ColorScheme`.
3. If the role must track **seed-derived** schemes, extend the merge step in [`NorthstarTheme.buildThemeData`](https://github.com/maplepam/ecosystem-platform/blob/main/packages/emp_ai_ds_northstar/lib/src/northstar_theme.dart) (`_tokensAlignedWithScheme` or equivalent) so seeded themes do not drop your new field.
4. Document the role in dartdoc and use **`NorthstarColorTokens.of(context)`** (or `ColorScheme` if you mapped it) in widgets — see **[Using colors](#using-colors)** above.

Prefer **`copyWith`** on an existing preset for one-off brand tweaks before forking the whole class.

### 4. Where to look in the host

| Concern | Location |
|---------|----------|
| Theme mode (light / dark / system) | [`northstar_theme_mode_provider.dart`](../../apps/emp_ai_boilerplate_app/lib/src/theme/northstar_theme_mode_provider.dart) + shell AppBar cycle action |
| Shell colors (rail, app bar strip, drawer uses same tokens via widgets) | [`boilerplate_shell_scaffold.dart`](../../apps/emp_ai_boilerplate_app/lib/src/shell/navigation/boilerplate_shell_scaffold.dart), `shell/navigation/widgets/` |
| “Look & feel” route | [`theme_settings_screen.dart`](../../apps/emp_ai_boilerplate_app/lib/src/screens/theme_settings_screen.dart) |

Folder map: **[`docs/engineering/host_structure.md`](../engineering/host_structure.md)** (`theme/` = branding glue).

## DTCG / Figma Variables

Re-export color variables from Figma as DTCG JSON (e.g. `Light.tokens.json`, `Dark.tokens.json`, `White Labeled.tokens.json`). Copy hex values into [`northstar_base_tokens.dart`](https://github.com/maplepam/ecosystem-platform/blob/main/packages/emp_ai_ds_northstar/lib/src/northstar_base_tokens.dart) (`NorthstarBaseTokens`); the package does not load JSON at runtime. Add a `design_tokens/` folder in the repo if you want committed JSON for diffing.

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
