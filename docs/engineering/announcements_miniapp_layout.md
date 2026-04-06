# Announcements mini-app layout

This mini-app is a **reference slice** for **clean architecture**, **`cached_query`** for **read/list/detail** server state, **`Riverpod`** for DI and UI state, and **adaptive** mobile vs wide layouts.

Typography and colors should follow **`emp_ai_ds_northstar`**: `NorthstarTextRole` and `NorthstarColorTokens.of(context)`.

---

## Start here (juniors): you do not need every buzzword

The **same layering idea** as [`architecture.md`](architecture.md) (request flow diagram): _presentation_ depends on _domain_; _data_ implements _domain_. This mini-app adds **`cached_query`** for shared list/detail reads and calls **`AnnouncementsRepository`** directly from **`presentation/di/`** query factories and from **notifiers** (no extra domain classes between UI and the repository).

**Memorize only three folders:**

| Folder              | One sentence                                                                                                                   |
| ------------------- | ------------------------------------------------------------------------------------------------------------------------------ |
| **`domain/`**       | Names and rules for your feature: “what is an announcement?” and “what operations exist?” **No** HTTP, **no** Flutter widgets. |
| **`data/`**         | Talking to the server and local storage: JSON classes, URLs, building POST bodies, saving read IDs.                            |
| **`presentation/`** | Screens, widgets, Riverpod providers: what the user sees and what runs when they tap or type.                                  |

Everything else below is **detail** you look up when you need it, not vocabulary to cram.

---

## Cheat sheet: where does my code go?

Ask **one** question at a time (in order):

1. **Am I calling the network or reading/writing disk?** → **`data/`** (DTO, datasource, repository implementation, `*_request_body.dart` helpers).
2. **Am I defining what the app _means_ (types, rules, named data operations like “load page / mark read”)?** → **`domain/`** (entities and **`AnnouncementsRepository`** _interface_).
3. **Am I drawing UI or reacting to taps/typing?** → **`presentation/`** — then pick a subfolder using the next table.
4. **Am I only wiring Riverpod** (how to build repository, Dio, or a `Query` / `InfiniteQuery`)? → **`presentation/di/`** — not “business logic,” just **composition** so screens stay thin.

| You are writing…                                                                              | Put it in…                | Plain English                                                                                                                                                                                                                                                                                                  |
| --------------------------------------------------------------------------------------------- | ------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Riverpod providers** that construct repos, Dio, or **`cached_query` factories**             | `presentation/di/`        | “Glue objects together for `ref.watch` / `ref.read`.” Split by file: **`announcements_data_providers`**, **`announcements_cached_query_providers`**, **`announcements_ui_derived_providers`**. Re-export from `presentation/providers/announcements_providers.dart` when you want one import for the mini-app. |
| A full screen or route                                                                        | `presentation/screens/`   | “This is a page.”                                                                                                                                                                                                                                                                                              |
| A reusable chunk of UI (card, list panel)                                                     | `presentation/widgets/`   | “We might use this twice.”                                                                                                                                                                                                                                                                                     |
| **Flutter + design-system glue** (breakpoints, extensions on **`AsyncValue`**, layout tokens) | `presentation/ui/`        | **Pure Flutter-side** helpers: may use **`BuildContext`**, **`Theme`**, DS packages, **`flutter_riverpod`** only for **types** (e.g. `AsyncValue` extensions). **Do not** put `ref.watch` / `ref.read` here — see below.                                                                                       |
| **Dart-only** list/string logic (merge query pages, in-memory search filter)                  | `presentation/utils/`     | **Pure Dart** in spirit: **no** `BuildContext`, **no** `Widget`, **no** `Ref` / `WidgetRef`. Values in → values out. (This mini-app may import **`cached_query_*`** types used by queries; still **no** Riverpod `ref`.)                                                                                       |
| Something that runs **after a user action** and updates server/cache (e.g. mark read)         | `presentation/notifiers/` | “Like a controller for _this action_.” **`ref.read` / `ref.watch`** belong here or in **`di/`** provider bodies, not in `utils/` / `ui/`.                                                                                                                                                                      |

**Reads (list/detail)** in this mini-app mostly use **`cached_query`** + **`QueryBuilder`** instead of a custom notifier — the **`Query` / `InfiniteQuery` setup** still lives under **`presentation/di/`** (`announcements_cached_query_providers.dart`), not inside widgets.

### `Ref` / `ref.watch`: where it is allowed

| Need                                                                                         | Put it in                                                                                                                               |
| -------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------- |
| **Subscribe** to providers (`ref.watch`) or **one-off read** (`ref.read`) for wiring queries | **`presentation/di/`** (provider callbacks)                                                                                             |
| **Subscribe** during a user flow / mutation                                                  | **`presentation/notifiers/`** or **`ConsumerWidget` / `Consumer` in `widgets/` or `screens/`**                                          |
| **Free functions** in `utils/` or extensions in `ui/`                                        | **No `Ref`.** Pass **already-resolved** values as parameters (colors, tokens, `AsyncValue`, etc.) from a widget that _does_ have `ref`. |

### Semantic colors (e.g. `switch` on status) when the DS needs `ref` or a provider

Do **not** hide `ref.watch(designSystemFooProvider)` inside `presentation/utils/` or `presentation/ui/` helpers.

1. **Default:** implement the `switch` in a **`ConsumerWidget` / `ConsumerStatefulWidget`** under **`widgets/`** (or directly in **`screens/`**): `final tokens = ref.watch(...);` then `switch (status) { ... return ColorToken(...); }`.
2. **Reusable across screens:** add a **`Provider`** (or `.family`) in **`presentation/di/`** that computes **`Color` / style data** from watched deps; widgets only `ref.watch(thatProvider)`.
3. **Pure mapping:** if you can express colors from **only** `BuildContext` / `Theme` / `NorthstarColorTokens.of(context)` with **no** provider, a **static** function in **`ui/`** that takes `BuildContext` (and enums) is fine — still **no `Ref`**.

This keeps **`utils/`** testable without Riverpod and avoids “mystery” subscriptions hidden in extensions.

---

## Mental model (same three layers, more words)

1. **Domain** — what the feature _is_ (entities, **`AnnouncementsRepository`** contract). No Flutter, no Dio.
2. **Data** — HTTP + local storage + DTOs + repository implementation.
3. **Presentation** — **`Query` / `InfiniteQuery`** call the **repository** directly ([`cached_query`](https://pub.dev/packages/cached_query)), **Riverpod** for wiring in **`presentation/di/`**, **`QueryBuilder`** on screens, one **mutation-style** notifier for mark-read.

**Rule of thumb:** I/O and parsing live in **data**. **Reads** that should be cached and shared use **`cached_query`**, not a hand-rolled `AsyncNotifier` list loader.

---

## Layman’s guide: server JSON vs app model vs POST map (entity / DTO / request body)

You will hear three names for **data shapes**. They are **not** three copies of the same class — they are **three jobs**:

| Name (jargon)           | Same idea in simple words                                        | Job                                                                                        |
| ----------------------- | ---------------------------------------------------------------- | ------------------------------------------------------------------------------------------ |
| **Entity**              | **App model** — what screens and the repository API use          | Stable Dart types (`Announcement`, `AnnouncementsListPageQuery`).                          |
| **DTO**                 | **Wire-in model** — “what the JSON looks like”                   | `AnnouncementDto`: `fromJson` / `fromEmaptaPublishedItem`, then **`toDomain()`** → entity. |
| **Request body helper** | **Wire-out map** — “exact keys the server expects for this POST” | `announcementsPublishedListBody(query)` → `Map<String, dynamic>` for Dio.                  |

**Incoming:** server sends `{ "message": "…", "announcement_id": "42" }` → **DTO** parses it → **`toDomain()`** → **entity** your widgets understand.

**Outgoing:** you have **`AnnouncementsListPageQuery`** (offset, limit, category) → **request body helper** turns it into the real POST JSON (field names, nulls, `categories` list, etc.).

### How UI filters reach the request body

- **Category chips / rail** → `announcementsCategoryFilterProvider` → included in **`AnnouncementsListPageQuery.categoryFilter`** → `announcementsPublishedListBody` sets **`categories`** on the server when not null.
- **Search field** → `announcementsSearchQueryProvider` → applied only in **Dart** via `applyAnnouncementsSearchFilter` on the **already-fetched** rows (title/summary/body). It does **not** change the POST body unless you add a `title` / search parameter to the API and wire it in `announcements_list_request_body.dart`.

So: **category = server filter**; **search = client filter** (in this reference implementation).

### `AnnouncementsListPageQuery` vs the request body helper — still not duplicate code

- **`AnnouncementsListPageQuery`** = app vocabulary: offset, limit, optional category. Repository and tests use it **without** knowing JSON keys.
- **`announcements_list_request_body.dart`** = “turn that into the real POST.” Same pattern as **DTO → entity**, but **outbound**: domain says _what you want_; data says _how the server wants it spelled_.

Keeping the POST map in its own file matches how larger Emapta modules keep HTTP payloads readable; you _could_ inline it in the datasource, but diffs get noisier.

---

## Where “real” business rules live (optional detail)

If the **cheat sheet** above is enough, skip this.

- **Product rules** that would still be true in a non-Flutter app → **`domain/`** (and **`data/`** only where they touch storage/API contracts).
- **“Make this list pretty for the screen”** (merge pages, search already-loaded rows) → **`presentation/utils/`** — not because it is “less important,” but because it **does not** change what the server returns.
- **User tapped something; now persist and refresh cache** → **`presentation/notifiers/`** (in other modules this is often a small **StateNotifier** / **AsyncNotifier** next to `presentation/providers`).

---

## Repository as the “verb” layer

|                | Simple words                                                                                                                                                                                                    | In this mini-app                                           |
| -------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------- |
| **Repository** | The **door** to data **and** the **named operations** the UI needs: `loadPublishedAnnouncementsPage`, `loadPublishedAnnouncementById`, `markAsRead`. **Interface** in `domain/`; **implementation** in `data/`. | `AnnouncementsRepository` + `AnnouncementsRepositoryImpl`. |

**`cached_query` `queryFn`s** and **`MarkAnnouncementReadNotifier`** call **`ref.watch` / `ref.read`(`announcementsRepositoryProvider`)** directly. If an operation later needs orchestration across **several** repositories or policies, add a **small domain service** (still no Flutter) and keep the repository as the IO boundary — see [`architecture.md`](architecture.md#request-flow).

---

## Repository methods (descriptive names)

| Method                                                           | Meaning                                                                                                                                                                                              |
| ---------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **`loadPublishedAnnouncementsPage(AnnouncementsListPageQuery)`** | One **page** of the **published list** API (`offset` / `limit` / optional **category**). Used by **infinite scroll** (mobile) and **paged** UI (web). **Not** “load the entire catalog into memory.” |
| **`loadPublishedAnnouncementById(String id)`**                   | One **item** for the detail screen: **detail POST** first; if missing, scans a **small list window** as fallback.                                                                                    |
| **`markAsRead(String id)`**                                      | Writes the id to **local** read storage only; **UI cache** is refreshed via **`CachedQuery.invalidateCache`** after mark-read.                                                                       |

---

## Pagination UX

| Surface                                      | Behavior                                                                                                                                                                                                                                        |
| -------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Mobile** (`AnnouncementsHomeMobileScreen`) | **`InfiniteQuery`** — initial page, then **`getNextPage()`** when the user scrolls near the bottom (`AnnouncementsFeedPanel` + `NotificationListener`). Page size: **`kAnnouncementsMobilePageSize`** (20).                                     |
| **Web** (`AnnouncementsHomeWebScreen`)       | **`Query`** keyed by **page index**, **page size**, and **category**. **Dropdown** for rows per page (10 / 25 / 50). **Prev / Next**; **Next** disabled when the current page returned **fewer than `limit`** rows (heuristic for “last page”). |

---

## Cached query (default for reads)

- **List (mobile):** `announcementsInfiniteListQueryProvider` → `InfiniteQuery<List<Announcement>, int>`.
- **List (web):** `announcementsPublishedPagedListQueryProvider(AnnouncementsPagedCacheKey)` → `Query<List<Announcement>>`.
- **Detail:** `announcementsDetailQueryProvider(id)` → `Query<Announcement>`.

Global cache config: `loadBoilerplateStartupOverrides` → `CachedQuery.instance.config(…)`.

**Mark read:** `MarkAnnouncementReadNotifier` calls **`ref.read(announcementsRepositoryProvider).markAsRead`**, then **`CachedQuery.instance.invalidateCache(filterFn: announcementsCachedQueryFilter)`** so list/detail refetch with updated read flags.

---

## UI states: loading, loaded (with data), empty, failed

Yes — **list** and **detail** both surface all four ideas. Wording maps to **`cached_query`** types as follows.

| User-visible idea | When it happens (list)                                                      | When it happens (detail)                                              |
| ----------------- | --------------------------------------------------------------------------- | --------------------------------------------------------------------- |
| **Loading**       | First fetch, **no** rows yet (`isInitialLoading && items.isEmpty`)          | `QueryLoading` **and** no cached `data` yet                           |
| **Loaded**        | `ListView` of cards; **pull-to-refresh** on the list                        | `QuerySuccess` → `AnnouncementDetailContent`                          |
| **Empty**         | Fetch succeeded (or stale data) but **visible list** is empty after filters | N/A as a dedicated layout today (detail errors instead if id missing) |
| **Failed**        | `error != null` **and** no rows to show                                     | `QueryError` → centered message                                       |

### List: `AnnouncementsFeedPanel` (single place for list UX)

Mobile and web **`QueryBuilder`** callbacks flatten pages, apply **client search**, extract **`InfiniteQueryError` / `QueryError`**, and pass **`isInitialLoading`**, **`isFetchingMore`**, and **`error`** into **`AnnouncementsFeedPanel`**. That widget implements the branching:

```31:54:apps/emp_ai_boilerplate_app/lib/src/miniapps/announcements/presentation/widgets/announcements_feed_panel.dart
    if (isInitialLoading && items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (error != null && items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Could not load announcements.\n$error',
            style: NorthstarTextRole.body.style(context),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    if (items.isEmpty) {
      return Center(
        child: Text(
          'No announcements match your filters.',
          style: NorthstarTextRole.body.style(context),
          textAlign: TextAlign.center,
        ),
      );
    }
```

**Loaded** state is the **`RefreshIndicator` + `ListView`** below that (cards + optional **bottom spinner** when **`isFetchingMore`** on mobile infinite scroll).

**Empty vs failed:** if the server returned rows but **search** removed all of them, the user still sees the **empty** copy (“No announcements match…”), not the **error** panel — because **`error`** is only shown when there are **no items** to fall back on.

### List: how screens set `isInitialLoading` and `error`

**Mobile** (`InfiniteQuery`): initial load vs “load more” is split so the full screen is not replaced on pagination.

```86:111:apps/emp_ai_boilerplate_app/lib/src/miniapps/announcements/presentation/screens/mobile/announcements_home_mobile_screen.dart
                final bool initialLoading =
                    state is InfiniteQueryLoading<List<Announcement>, int> &&
                        state.isInitialFetch &&
                        flat.isEmpty;
                final bool fetchingMore =
                    state is InfiniteQueryLoading<List<Announcement>, int> &&
                        state.isFetchingNextPage;
                final Object? err = switch (state) {
                  InfiniteQueryError<List<Announcement>, int>(:final error) =>
                    error,
                  _ => null,
                };

                return AnnouncementsFeedPanel(
                  items: visible,
                  isInitialLoading: initialLoading,
                  isFetchingMore: fetchingMore,
                  error: err,
                  onRefresh: () => query.refetch(),
                  onOpenDetail: (Announcement a) =>
                      context.push('/announcements/detail/${a.id}'),
                  hasNextPage: query.hasNextPage(),
                  onLoadMore: query.hasNextPage()
                      ? () => unawaited(query.getNextPage())
                      : null,
                );
```

**Web** (`Query` per page): same pattern with **`QueryLoading`** / **`QueryError`**.

```126:132:apps/emp_ai_boilerplate_app/lib/src/miniapps/announcements/presentation/screens/web/announcements_home_web_screen.dart
                final bool loading = state is QueryLoading<List<Announcement>> &&
                    state.isInitialFetch &&
                    rows.isEmpty;
                final Object? err = switch (state) {
                  QueryError<List<Announcement>>(:final error) => error,
                  _ => null,
                };
```

### Detail: `switch` on `QueryStatus<Announcement>`

The detail route uses **`QueryBuilder`** with an explicit **`switch`** so **cached data** can still show while a refetch runs (**stale-while-revalidate**):

```55:88:apps/emp_ai_boilerplate_app/lib/src/miniapps/announcements/presentation/screens/announcement_detail_screen.dart
              return switch (state) {
                QuerySuccess<Announcement>(:final data) => Builder(
                    builder: (BuildContext context) {
                      if (!data.isRead && !_markReadDispatched) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (!mounted) {
                            return;
                          }
                          _markReadDispatched = true;
                          unawaited(
                            ref
                                .read(markAnnouncementReadNotifierProvider
                                    .notifier)
                                .markRead(data.id),
                          );
                        });
                      }
                      return AnnouncementDetailContent(announcement: data);
                    },
                  ),
                QueryError<Announcement>(:final error) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'Could not open this announcement.\n$error',
                        style: NorthstarTextRole.body.style(context),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                QueryLoading<Announcement>(:final data) when data != null =>
                  AnnouncementDetailContent(announcement: data),
                _ => const Center(child: CircularProgressIndicator()),
              };
```

- **Loading:** default branch → **`CircularProgressIndicator`** when there is no cached `data`.
- **Loaded:** **`QuerySuccess`** → full content.
- **Failed:** **`QueryError`** → friendly error text.
- **Empty** is not modeled separately on detail; a missing id surfaces as **error** from the repository/query.

---

## Parallel list vs detail loading

**List** and **detail** use **different `Query` keys** → **independent** loading and cache entries. Opening detail does not block the home list from showing cached pages, and vice versa.

---

## Providers: do’s and don’ts (juniors)

**Do**

- Put **constructors / singletons** (repository, Dio, base URL) in **`announcements_data_providers.dart`**.
- Put **cached_query** `Query` / `InfiniteQuery` factories in **`announcements_cached_query_providers.dart`**.
- Use **`StateProvider`** only for **real UI state** (search text, web page index, category).
- Use **`QueryBuilder`** (or stream listeners) to **paint** loading/error/data from `cached_query`.

**Don’t**

- Add a new `Provider` for every field — prefer **one** query + **local** `TextEditingController` / `StateProvider` where enough.
- Put **HTTP** or **JSON parsing** inside **notifiers** — belongs in **data** + **repository**.
- Duplicate the same fetch in a **notifier** and a **query** for the same key — pick **one** source of truth (`cached_query` for reads).

### Screens vs widgets vs `presentation/ui`

Same breakdown as the **cheat sheet** table; this is the implementation reminder:

| Folder                 | Typical contents                                                                                                                                             |
| ---------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| **`screens/`**         | `Scaffold`, `AppBar`, `QueryBuilder`, navigation — **almost no logic**.                                                                                      |
| **`widgets/`**         | Cards, feed panel, filters — **reusable** pieces with callbacks.                                                                                             |
| **`presentation/ui/`** | Breakpoints, **`AsyncValue` → Northstar** extensions; list/detail prefer **`QueryBuilder`**. **Flutter / DS side** — see **`Ref` rules** in the cheat sheet. |

---

## Folder map (what lives where)

| Path                      | Purpose                                                                                                          |
| ------------------------- | ---------------------------------------------------------------------------------------------------------------- |
| `domain/entities/`        | `Announcement`, enums, **`AnnouncementsListPageQuery`** (paged list **input** to the repository).                |
| `domain/repositories/`    | `AnnouncementsRepository` contract (**named methods** are the app’s verbs).                                      |
| `data/dtos/`              | `AnnouncementDto`.                                                                                               |
| `data/datasources/`       | Remote + local read IDs.                                                                                         |
| `data/repositories/`      | `AnnouncementsRepositoryImpl`.                                                                                   |
| `data/` root              | `announcements_api_paths.dart`, `announcements_list_request_body.dart` — paths + POST maps.                      |
| `presentation/di/`        | `announcements_data_providers`, `announcements_cached_query_providers`, `announcements_ui_derived_providers`.    |
| `presentation/notifiers/` | **`MarkAnnouncementReadNotifier`** only (mutation + cache invalidation).                                         |
| `presentation/utils/`     | **Pure Dart** list helpers: `flattenAnnouncementInfinitePages`, `applyAnnouncementsSearchFilter` (**no `Ref`**). |
| `presentation/screens/`   | Adaptive shell + mobile/web home + detail.                                                                       |
| `presentation/widgets/`   | Cards, feed, filters.                                                                                            |
| `presentation/ui/`        | **Flutter / DS glue** — breakpoints, optional `AsyncValue` helpers (**no `ref` in helpers**; see cheat sheet).   |

---

## Data layer helpers

See previous sections: **paths** vs **request body** keep the HTTP class small.

---

## Glossary: BFF

**Backend-for-frontend** — an API tailored to a client. Payload may differ from the raw microservice; **DTOs** still map whatever JSON you receive.

---

## Riverpod / UI primitives (junior cheat sheet)

- **`QueryStatus<T>` / `InfiniteQueryStatus<T, A>`** — `cached_query` states; use **`switch`** in **`QueryBuilder`**.
- **`AsyncValue<T>`** — Riverpod’s three-state wrapper; common with **`AsyncNotifier`**; announcements **reads** prefer **`QueryBuilder`** here.
- **`NorthstarTriStateBody`** — maps tri-state to DS layouts; still useful where you expose **`AsyncValue`** (e.g. other mini-apps).
- **`AppResult` / `AppFailure`** — typed errors from the **repository**; `queryFn` **throws** `AppFailure` after `fold` so `cached_query` surfaces errors.

---

## Network (emapta announcement-bl V2)

- **Base URL:** `announcementServiceBaseUrl` / `ANNOUNCEMENT_SERVICE_BASE_URL`.
- **Client:** **`boilerplateDioProvider`** in [`boilerplate_api_client.dart`](../../apps/emp_ai_boilerplate_app/lib/src/network/boilerplate_api_client.dart) (bearer + 401 refresh + retry).
- **List POST:** `announcementsPublishedListBody` with **pagination** and optional **categories**.
- **Detail POST:** `announcementsPublishedDetailBody(id)`.

---

## Design system & catalog

**`emp_ai_ds_widgets`** + **`emp_ai_ds_northstar`**. Widget catalog includes **typography roles** and **icons**.

---

## Tests

Override **`announcementsRemoteDataSourceProvider`** with [`stub_announcements_remote_datasource.dart`](../../apps/emp_ai_boilerplate_app/test/support/stub_announcements_remote_datasource.dart) (`fetchPublishedListPage`, `fetchPublishedDetail`).

---

## Checklist

- [ ] New list field? → DTO + `toDomain` + entity if needed.
- [ ] New query param? → `announcements_list_request_body` + `AnnouncementsListPageQuery` + repository method.
- [ ] New read screen? → New **`Query`** key + `QueryBuilder`.
- [ ] Mark-read side effect? → Repository **`markAsRead`** + notifier + **`invalidateCache`** for `scope == announcements`.
