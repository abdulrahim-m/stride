# Collaboration guide

Everything a human or AI collaborator needs to work on Stride (code name of the Rust core: NoteCore): how it is built, where things are, how to change them, and the rules. Read the root `README.md` first for what the app is.

## 0. The product principle (read this first)

Stride exists to sit between two kinds of apps: ones that are simple but poor in features, and ones so complex that just starting is hard. **It must stay simple to use, with minimal (if any) things to know, while being feature-rich.**

Before adding or changing anything, ask:
- Can a first-time user do the basic thing without being told how? If a feature needs explanation, it is too prominent or too complicated.
- Is the new capability hidden until the user reaches for it (a menu, a drawer, a long-press), rather than adding buttons to the main flow?
- Does it reuse an existing pattern instead of introducing a new concept?

A feature that raises the entry bar is a bad feature, however useful. Prefer sensible defaults over settings, and progressive disclosure over more controls.

## 1. The big picture

- **Rust is the brain, Flutter is the face.** Anything not UI-related (data, rules, search, scheduling, validation, settings storage) lives in the Rust `core`. Flutter only renders and forwards actions.
- **Three layers, one direction of dependency:** `mobile_client` → generated bindings → `bindings` crate → `core` crate. `core` knows nothing about Flutter or FFI. `bindings` knows nothing about widgets.
- **SQLite is the single source of truth.** The UI never keeps data the database doesn't have; after a change it reloads from the core.
- **Local-first.** No network calls in the app. Data stays in the app's storage directory.

## 2. Where everything is

| I want to... | Go to |
|---|---|
| Change data, queries, rules, schema | `core/` (Rust) |
| Change what Dart can call | `bindings/` (Rust), then regenerate (see §4) |
| Change a screen or widget | `mobile_client/lib/features/<feature>/presentation/` or `lib/shared/` |
| Add text | `mobile_client/lib/l10n/app_en.arb` **and** `app_ar.arb` |
| Add a theme / setting | `mobile_client/README.md` → Settings |
| Add a page-guide step | `mobile_client/lib/core/guide/page_guides.dart` |
| Understand the Flutter folders | `mobile_client/README.md` |

Public API handed to Dart: `NoteCore` (open/close, settings) with `notes()`, `shortNotes()`, `shortTasks()`, `tasks()`, `tags()` sub-APIs. All calls are async and can throw `ApiError` (with a `message`). Every API has `refresh()`.

## 3. The core in detail
 
### 3.1 Layers inside `core`
1. **Models** (`models/`) hold the entity structs *and* their database access in the same file (each entity implements the `Model` trait). There is no separate repository layer.
2. **UI structs** (`ui_*.rs`: `UINote`, `UINoteListItem`, `UITask`, `UITag`, ...) are what leaves the core: entities with tags resolved into `UITag`s, computed fields added (e.g. note `preview` = first line). The bindings turn these into the Dart DTOs (`NoteDto`, `TaskDto`, ...).
3. **Services** (`services/`) are the public face of the core and hold the business logic: they load entities, apply rules, call models and map to UI structs. Each service is built from a shared `Arc<SqlitePool>` and calls its `refrech()` in `new()`.
4. **`DatabaseManager::init(base_path)`** opens `<base_path>/notecore.db` (created if missing, foreign keys on), creates tables, and on a brand-new database inserts the default settings.
Request flow: `Dart call → bindings → Service method → Model(s) → SQLite → UI struct → Dart DTO`.
 
### 3.2 The `Model` trait (`models/repo.rs`)
Every entity implements: `get_count`, `get_all(list)`, `get_by_id`, `search(params, list)`, `create(&mut self)`, `update(&mut self)`, `delete(id)`. Conventions:
- `create` sets `created_at`/`updated_at`, writes the row and fills `self.id`; `update` bumps `updated_at`.
- `ListRequest { current_page (1-based), pages_count, limit }` is pagination; `None` means "all".
- `SearchParams { text, tags, created_before, created_after }` is the common search. Tag filtering is **AND**: an item must have *all* selected tags. Tasks add `TaskSearchParams` (priority, due-date range) used by `custom_search`.
- Lists are ordered by `created_at DESC` (note groups by `placing`; periodic tasks by time until their next occurrence).
- Queries are built with `sqlx::QueryBuilder` and **bound parameters**. Never format user input into SQL.
### 3.3 Data model
 
| Table | Notes |
|---|---|
| `app_settings` | `key`, `value` (text). Defaults: `language=default`, `theme=default`, `reset_time=0`, `font_size=14` (inserted only when the database is created) |
| `tags` | `id`, `name`, `created_at` |
| `notes` | `group_id` (nullable, `ON DELETE SET NULL`), `title`, `content`, `tags`, timestamps |
| `note_groups` | `name`, `placing` (order) |
| `short_note_sections` / `short_note_items` | thoughts: section (`name`, `tags`, timestamps) → items (`content`), items cascade on delete |
| `short_task_sections` / `short_task_items` | checklists: section (`title`, `tags`, timestamps) → items (`text`, `done`), cascade |
| `tasks` | `title`, `description`, `task_type` (`periodic`/`onetime`), `done`, `options`, `tags`, timestamps |
 
Important storage details:
- **`tags` columns are JSON arrays of tag ids** (e.g. `[1,4]`), filtered with SQLite `json_each`. There is no join table.
- **`tasks.options` is JSON** (`TaskOptions { priority, due_date, schedule, check_list }`). Sub-tasks are `check_list: [{text, checked}]`. `due_date` is a string (`YYYY-MM-DD` or ISO).
- `listed_items` / `listed_notes` are computed counts (subqueries), not stored.
- Schedules: `Daily`, `EveryNDays`, `Weekly { days_of_week, hour }`, `Monthly`, `Yearly`; `Schedule::time_until_next` powers ordering and "upcoming".
### 3.4 Business rules worth knowing
- **Periodic reset:** `TasksService::refrech()` → `Task::update_periodic_status` finds finished periodic tasks and, when the (reset-hour-shifted) day has changed since `updated_at`, sets them unfinished and unchecks their sub-tasks. It runs when the service is created and whenever the UI calls `refresh()`. The reset hour comes from the `reset_time` setting.
- **Deleting non-empty containers is guarded:** `delete_group` fails with `Forbidden` if the group still has notes; `delete_section(id, force)` for thoughts and checklists fails unless `force` is true when the section has items. (The `notes.group_id` foreign key is `ON DELETE SET NULL` as a safety net.)
- `toggle_done` / `toggle_item_done` return the new state.
- New notes start with the title `untitled`.
### 3.5 Errors
`utils/app_error.rs`: `AppError { message, error_type }` with `ErrorType::{Internal, Forbidden, Validation}`, `From<sqlx::Error>`, and `type Result<T> = Result<T, AppError>`. Services return `Result`; `bindings` converts it to the `ApiError` Dart sees (it has a `message`). Use `Forbidden` for "not allowed by a rule", `Validation` for bad input, `Internal` for infrastructure failures.
 
### 3.6 Public API handed to Dart
`NoteCore` (open/close, `getSetting(s)`, `setSetting`, `resetSettings`) with sub-APIs `notes()`, `shortNotes()` (thoughts), `shortTasks()` (checklists), `tasks()`, `tags()`. All calls are async; every API has `refresh()`.

## 4. Setup

See "Requirements" and "Getting started" in the root README. Short version:

```bash
cargo build && cargo test
flutter_rust_bridge_codegen generate
cd mobile_client && flutter pub get && flutter gen-l10n && flutter run
```

Use the codegen version **2.13.0**, matching the `flutter_rust_bridge` crate and Dart package. Mismatched versions are the #1 cause of baffling build errors.

## 5. Changing the Rust API (the full loop)

1. Implement the logic in `core` (with tests).
2. Expose it in `bindings` (DTOs + methods on the API structs). Keep DTOs plain and small; map core models to DTOs in `bindings`, never leak core internals.
3. From the root run `flutter_rust_bridge_codegen generate`.
4. Fix Dart call sites; run `flutter analyze`.
5. Commit the Rust change **and** the regenerated Dart files together, so the repo always builds.

Never edit generated files (`mobile_client/lib/core/rust/**`, `*.freezed.dart`, `*.g.dart`, `app_localizations*.dart`).

## 6. Recipes
 
**A new field on an existing entity**
1. Add the column to `DatabaseManager::init_tables` **and** handle existing databases (see §9, there is no migration system yet).
2. Add it to the model struct and every `SELECT`/`INSERT`/`UPDATE` in that file.
3. Add it to the `ui_*` struct and the service mapping, then to the bindings DTO. Regenerate. Use it in Flutter.
4. Test in the model file's `#[cfg(test)]` module.
**A new entity**
1. `models/<area>/<name>.rs`: struct (`#[derive(FromRow)]`) + `impl Model` (+ `ui_<name>.rs`); register in the area's `mod.rs`.
2. Table in `init_tables`.
3. `services/<name>.rs` with `new` + `refrech`, getters, creates, updates, deletes, `map_ui_*`; register in `services/mod.rs`.
4. Wire into `NoteCore` and a new `*Api` in `bindings`; regenerate.
5. Flutter: a feature folder, register the API in `main.dart`.
**A new setting:** add the key to `Settings::setup_defaults` (new databases) *and* give the Flutter `Setting<T>` a default (existing databases return no value). Then add the tile (see `mobile_client/README.md`).
 
**A new tab:** see `mobile_client/README.md` (feature folder on `SearchableListPage`, route, nav item, `GuideScope`, strings in both languages, guide steps).
 

## 7. Rules

### General
1. **Logic in the core, presentation in Flutter.** If you are writing business rules in Dart, stop and move them to Rust.
2. **Reuse before you write.** Look in `lib/shared/` first (list pages, controllers, search bar, tag picker, dialogs, selection bar). Extend a shared piece instead of copying it. Duplicated code is a bug in review.
3. **Keep changes small and focused**: one concern per commit/PR.
4. **Don't break the build**: `cargo fmt`, `cargo clippy`, `cargo test`, `flutter analyze` and `dart format` pass before pushing.
5. **No secrets, no network calls, no new permissions** without discussion.

### Rust
- Errors go through the shared error type; no `unwrap()`/`expect()` on user data or I/O in library code.
- Schema changes are migrations; never edit an old migration that has shipped.
- Add or update tests for every behavior change in `core`.
- Search/list queries are paginated (`ListRequestDto`); don't return unbounded lists.

### Flutter
- Features live in `features/<name>/presentation/{controllers,pages,widgets,dialogs}` (a `domain/` folder only for pure Dart helpers).
- State: `ChangeNotifier` controllers listened to with `ListenableBuilder`. Controllers use the `ApiGuard` mixin so errors surface as a snackbar. Don't add another state-management package.
- DI: GetIt (`getIt<T>()`). Register new APIs/services in `main.dart` / `injection.dart`. Don't use `provider`.
- New tab/list screens build on `SearchableListPage` / `SectionListPage` and the shared controllers; new section editors on `SectionEditorView`.
- Imports use `package:mobile_client/...`, following the folder structure (`shared/controllers`, `shared/dialogs`, `shared/utils`, `shared/views`, `shared/widgets`).
- **Localization:** no hard-coded user text. Add the key to **both** `app_en.arb` and `app_ar.arb`, then `flutter gen-l10n`.
- **RTL/Arabic must work:** use `*Directional` alignments/paddings, test screens in Arabic, keep per-text direction detection in text inputs.
- **Theming:** read colors from `Theme.of(context).colorScheme`, never hard-code colors in widgets. New themes implement `AppColors`.
- Every FAB uses `heroTag: null`.
- **Guides:** if you add a visible control to a tab page, add a `GuideTarget` + `GuideStep` for it, and the strings in both languages.
- Auto-save vs explicit save: notes/section items auto-save; tasks save explicitly and warn before discarding changes. Follow the pattern of the feature you touch.
- Keep widgets small; extract a widget when a `build` grows past a screen.

### Git
- Branch from `dev`: `feature/<short-name>`, `fix/<short-name>`.
- Commit messages: imperative, short subject (`Add periodic task weekday picker`), body explains *why* when not obvious.
- PRs: describe what/why, list manual test steps, include screenshots for UI changes (light, dark, and Arabic if relevant).
- Don't force-push shared branches. Rebase or merge `dev` before opening a PR.

## 7. Adding things: quick recipes

**A new setting:** `AppSettings` (declare) → tile in `settings_page.dart` → read via `getIt<SettingsController>()` → strings in both `.arb`.

**A new theme:** class implementing `AppColors` → one line in `appThemeOptions`.

**A new tab:** feature folder + page on `SearchableListPage` → controller extending the shared ones → register its API in `main.dart` → route + `GuideScope` in `router.dart` → nav item in `app_shell.dart` and `guideScopes` → strings (+ guide steps) in both languages.

**A new field on an entity:** migration + core model/query/tests → DTO in `bindings` → regenerate → UI.

## 8. Testing and checks

| Check | Command |
|---|---|
| Rust tests | `cargo test` |
| Rust lint/format | `cargo clippy --all-targets` / `cargo fmt --check` |
| Dart analysis | `cd mobile_client && flutter analyze` |
| Dart format | `dart format lib` |
| Dart tests | `flutter test` |

Manual smoke test before a PR touching UI: create/edit/delete in each tab, search + a tag filter, pull-to-refresh, switch language to Arabic, switch theme, change font size, run the `?` guide on the tab you changed.

## 9. Working with AI agents

- Point the agent to this file and the READMEs first.
- Keep the same rules: logic in Rust, reuse shared widgets, both `.arb` files, no hand edits of generated code.
- Agents often cannot build Flutter; treat their output as unverified until `flutter analyze` and a manual run pass.
- Ask for diffs against the files you actually have; share the current version of any file before asking for changes to it.

## 10. Known gotchas

- Codegen/crate/package version mismatch → regenerate and align versions.
- Forgetting to regenerate bindings after changing `bindings` → Dart doesn't see new methods.
- Missing key in one `.arb` file → build error after `gen-l10n`.
- `GuideTarget` directly under `Expanded` → "ParentData" error; wrap inside instead.
- Several FABs without `heroTag: null` → "multiple heroes share the same tag".
- Periodic task `reset_time` is stored in settings; make sure scheduling logic reads it from the core.

## 11. Open items / TODO for maintainers

- Fill in exact toolchain versions and the codegen config location in the README.
- Add CI (cargo fmt/clippy/test, flutter analyze/test).
- Add a migration system (§9).