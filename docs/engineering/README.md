# Engineering docs — read these first

Narrow topic files live in this folder; **start with these four** to understand the host app and how to extend it:

| Order | Doc | Why |
|------|-----|-----|
| 1 | [**host_structure.md**](host_structure.md) | Where code goes under `apps/emp_ai_boilerplate_app/lib/src/` (`shell` / `platform` / `miniapps` / …). |
| 2 | [**architecture.md**](architecture.md) | Clean architecture layers **inside** each mini-app (`data` / `domain` / `presentation`). |
| 3 | [**miniapps.md**](miniapps.md) | Registry, codegen, flags, **remote registry stub** (server allow-list). |
| 4 | [**mini_app_vs_feature.md**](mini_app_vs_feature.md) | New `MiniApp` vs a screen inside an existing one. |
| — | [**miniapp_packages_and_extract.md**](miniapp_packages_and_extract.md) | Mini-apps from **other repos** (`packages/`) and **extracting** a huge mini-app out. |

**Then:** [packages.md](packages.md), [dependencies.md](dependencies.md), [contributing.md](contributing.md), and the [integrations hub](../README.md#integrations-hub) for auth, navigation, and env. **Shell routes & configurable main-shell menu:** [navigation.md](../integrations/navigation.md).

Back to [documentation index](../README.md).
