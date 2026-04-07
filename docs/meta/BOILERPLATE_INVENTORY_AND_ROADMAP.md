# Enhancement ideas (optional roadmap)

**What the template already includes** (repositories, packages, and ownership) is described in **[repositories_overview.md](../engineering/repositories_overview.md)**. Use this file only for **backlog / planning**: patterns you might add on top of the host and platform stack.

**New team onboarding:** [getting_started.md](../onboarding/getting_started.md).

---

## Product and UX (common next steps)

- Offline-first persistence for queries; conflict handling for writes.
- Biometric re-auth for sensitive flows (mobile).
- In-app update prompts; remote-config-driven messaging.
- Deeper A/B wiring between feature flags and analytics.
- PWA-oriented web improvements (install, share targets).

## Engineering

- CI matrix per flavor; golden tests for design-system widgets.
- More codegen (`go_router_builder`, `freezed` for DTOs, OpenAPI clients).
- Expanded observability (structured logging, RUM, performance traces).
- Push notifications end-to-end (FCM, background handlers, platform capabilities).
- Accessibility audits against design tokens; RTL and large-text tests.
- Internationalization (`flutter gen-l10n`, locale from profile).

## Security

- Certificate pinning patterns for mobile, if required by policy.
- Secrets only via CI vault and compile-time defines — never in Git.

Prioritize against your product needs; the template keeps **vendor-heavy** code in the **host** or thin adapters while **contracts** stay in **`emp_ai_foundation`** / **`emp_ai_core`** on **ecosystem-platform**.
