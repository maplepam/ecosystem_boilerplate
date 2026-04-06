# Where reusable UI should live

## Recommendation

| Package | Contents |
|---------|----------|
| **`emp_ai_ds_northstar`** | Color/text **tokens**, `ThemeData` builders, theme mode controller, DTCG JSON assets. **No** business widgets. |
| **`emp_ai_ds_widgets`** | Shared chrome: navigation drawer, dashboard **layout presets** (`DashboardLayoutBuilder`), **reorderable slot** editor (`ReorderableDashboardSlotList`), catalog page. Atoms that are purely presentational may also live here. |
| **Feature / mini-app** | Screens composed of DS widgets + local state; **no** duplication of primitive components. |

## Why split?

- Apps can **theme** without adopting the full widget library (e.g. legacy screens).
- DS releases stay **small** and easy to review.
- You avoid circular dependencies (widgets → tokens, never tokens → widgets).

## Atomic design in code

- **Atoms** — private or public widgets in `lib/src/atoms/` (e.g. `NorthstarPrimaryButton`).
- **Molecules** — compose atoms: `lib/src/molecules/search_field.dart`.
- **Organisms** — larger sections: `lib/src/organisms/app_page_scaffold.dart`.
- **Templates** — optional layout-only widgets with slots (`child`, `actions`).

Mirror Figma’s naming where possible so designers and engineers share vocabulary.

## Informing implementation from Figma

See **“How to hand off Figma”** in [design_system.md](design_system.md): export variables, list component names, map to token roles, specify states and target package.
