# Mini-app vs feature: how to choose (emapta-aligned thinking)

The boilerplate follows the same **super-app** idea as **emapta**: several **products in one shell**, each with its own **route subtree** and optional **tab** / **flag**. This page helps decide **new `MiniApp`** vs **feature inside an existing mini-app**.

**Where to put code in the repo:** product mini-apps live under **`lib/src/miniapps/`**; host-wide capabilities (flags, analytics, push, `MiniAppGate`) under **`lib/src/platform/`**; router, scaffold, and auth under **`lib/src/shell/`**. See [host_structure.md](host_structure.md).

---

## Prefer a **new mini-app** when

| Signal                       | Why                                                                                                                                                       |
| ---------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Own top-level nav**        | It should appear as its own **shell tab** (e.g. Main shell, Samples) or its own **major** hub tile with a distinct **entry path** (`/announcements/...`). |
| **Team / release ownership** | A different squad ships it on a **different cadence** or toggles it with **feature flags** without dragging the whole “main” app.                         |
| **Clear boundary**           | Routes, analytics prefix, and deep links are naturally **`/<miniAppId>/...`**.                                                                            |
| **Optional product**         | Some white-label or B2B tenants **disable** the whole module — map that to **no `MiniApp` registration** or **`MiniAppGate`**.                            |

Scaffold with **`melos run create:miniapp`**, register in **`miniapps_registry.yaml`**, run **`generate:miniapps`**. See [miniapps.md](miniapps.md).

---

## Prefer a **feature inside an existing mini-app** when

| Signal                | Why                                                                                                                          |
| --------------------- | ---------------------------------------------------------------------------------------------------------------------------- | ---- | --------------- |
| **Same user journey** | It is another **screen or flow** under the same product (e.g. “Settings” inside Main shell, “Order detail” inside Commerce). |
| **Shared state**      | Heavy use of the **same** Riverpod graph, same repositories, same `FLAVOR` catalog — splitting would duplicate wiring.       |
| **No separate tab**   | Users never “switch apps”; they stay inside **Overview → drill-down**.                                                       |
| **Small surface**     | A single **repository + screen** (and wiring) under `lib/src/miniapps/<existing>/domain                                      | data | presentation/`. |

Keep **clean architecture** inside the slice ([architecture.md](architecture.md)).

---

## Grey area: “announcements”, “inbox”, “CMS”

Treat as a **mini-app** if:

- It has a **dedicated** area in the org’s **emapta** app (own tab or own root stack), **or**
- You want **independent** enable/disable, **or**
- **Deep links** are stable under a dedicated prefix.

Treat as a **feature** if:

- It is **one feed** or **banner** on an existing home/dashboard you already own in **Main shell**.

**Porting “announcements” from emapta into this boilerplate**: yes — implement a **`MiniApp`** (or start as a **feature** under `main` mini-app) that mirrors **routes + API contracts** from emapta. The boilerplate does not ship emapta’s backend URLs; you wire **environment catalog** + **Dio** like any other product. No automatic sync from emapta’s repo — **copy/adapt** routes and data layer intentionally.

---

## Emapta parity: login and `emp_ai_auth`

**Login flow**

- This host uses **`emp_ai_auth`** for sign-in: configure the **[flavor catalog](../../apps/emp_ai_boilerplate_app/lib/src/config/boilerplate_environment_catalog.dart)** or optional **`AUTH_*`** defines (see [`emp_ai_auth_bootstrap`](../../apps/emp_ai_boilerplate_app/lib/src/shell/auth/bootstrap/emp_ai_auth_bootstrap.dart), [`boilerplate_auth_config.dart`](../../apps/emp_ai_boilerplate_app/lib/src/config/boilerplate_auth_config.dart)). The UI body is **`EmpAuth().login`** ([`login_screen.dart`](../../apps/emp_ai_boilerplate_app/lib/src/screens/login_screen.dart)).
- **Parity with emapta’s main app** means: same **`emp_ai_auth` Git ref**, same **Keycloak / OAuth client config** (`AUTH_CLIENT_ID`, redirect URIs, etc.), and any **custom branding** emapta adds **outside** `EmpAuth().login` must be **ported into this host** (wrapper widgets, theme, or upstream changes to `emp_ai_auth` if shared).

**Don’t expect** the boilerplate to **clone emapta-only screens** automatically; treat **emapta** as the reference product and **this repo** as the **integration sample**.

**Further reading**

- [integrations/auth.md](../integrations/auth.md)
- [integrations/emp_ai_auth_dependency.md](../integrations/emp_ai_auth_dependency.md)
- [environment.md](../integrations/environment.md) for `AUTH_*` / flavors

---

## Quick decision

- **New tab or new `/productId` root with its own lifecycle?** → **Mini-app**.
- **Another screen in the same product?** → **Feature** in that mini-app’s folder.
- **Unsure?** Start as a **feature**; extract to a **`MiniApp`** when a **second consumer** or **separate tab** appears.
