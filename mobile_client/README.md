# mobile_client: the Stride Flutter app

The UI of Stride (the Rust core behind it is called NoteCore). It presents data from the Rust core (through generated `flutter_rust_bridge` bindings) and sends user actions back. **No business logic lives here.**

## Stack

- Flutter, Material 3, light/dark follows the device
- `go_router`: navigation (`StatefulShellRoute.indexedStack` for the four tabs)
- `get_it`: dependency injection (the Rust APIs, shared filters, settings)
- `flutter_rust_bridge` 2.13: Dart ↔ Rust (generated code in `lib/core/rust/`)
- `ChangeNotifier` controllers + `ListenableBuilder` for state (no extra state package)
- `flutter_localizations` + `gen-l10n` (English, Arabic)
- `path_provider` to find the storage directory

## Run

```bash
# from the repo root, if the Rust API changed
flutter_rust_bridge_codegen generate

cd mobile_client
flutter pub get
flutter gen-l10n
flutter run
```

## Startup (`lib/main.dart`)

1. `RustLib.init()`, then `NoteCore.open(basePath: <app support dir>)`.
2. Registers in GetIt: `NoteCore`, `NotesApi`, `ShortNotesApi`, `ShortTasksApi`, `TasksApi`, `SearchFilters`, `SettingsController` (settings are loaded before the first frame).
3. `setupLocator()` for the remaining services, then `runApp(MyApp())`.

`MyApp` listens to `SettingsController` and rebuilds with the chosen theme, locale and font scale.

## Folder structure (`lib/`)

```
app/            app.dart (MaterialApp), app_shell.dart (top bar + bottom nav), router.dart
core/
  context/      app_context.dart (router refresh listenable)
  di/           injection.dart (getIt)
  guide/        page-guide system: GuideScope, GuideTarget, overlay, steps per page
  rust/         GENERATED bindings. Never edit by hand.
  settings/     Setting<T> definitions (AppSettings) + SettingsController
  storage/      secure storage service
  theme/        app_theme.dart, text styles, themes/ (one file per theme + theme_registry.dart)
features/
  notes/ thoughts/ checklists/ tasks/ settings/
    presentation/{controllers,pages,widgets,dialogs}   (tasks also has domain/)
l10n/           app_en.arb, app_ar.arb (+ generated localizations)
shared/
  controllers/  paged_list_controller, searchable_list_controller, section_list_controller,
                section_editor_controller, filterable_controller
  dialogs/      dialogs.dart (text input, confirm, ...)
  utils/        api_guard.dart, text_direction_utils.dart
  views/        searchable_list_page, section_list_page, section_editor_view
  widgets/      search bar, tags drawer, selection bar, tag picker, cards, text fields, ...
```

Imports always use the package form: `package:mobile_client/shared/widgets/...`.

## Main building blocks

- **`SearchableListPage<C, T>`**: the whole tab page (search bar, filter drawer, FAB, selection bar, paging, pull-to-refresh). A tab only provides its controller and how rows look. **`SectionListPage`** specializes it for sections (Thoughts, Checklists).
- **Controllers** extend `PagedListController` → `SearchableListController` → `SectionListController`, and use the `ApiGuard` mixin (`guard`, `report`, `onError`) so Rust errors become snackbars instead of crashes.
- **`SearchFilters`** (singleton in GetIt): the shared search text, tag and date filters used by every tab.
- **`SectionEditorView`**: page of one open section (Thoughts, Checklists): name, tags, items, composer.
- **Auto-save**: notes and section items save themselves (`AutoSaveTextField`). Tasks are the exception: explicit save with a discard warning.

## Settings

`core/settings/app_settings.dart` declares typed `Setting<T>`s; `SettingsController` (GetIt) reads/writes them through `NoteCore.getSetting/setSetting`. Read anywhere with `getIt<SettingsController>().get(AppSettings.x)`.

- **Add a setting:** declare it in `AppSettings`, add a tile (`ChoiceSettingTile`, `SliderSettingTile` or your own) to a `SettingsSection` in `settings_page.dart`.
- **Add a theme:** create a class implementing `AppColors` (copy `themes/forest.dart`) and add one line to `appThemeOptions` in `themes/theme_registry.dart`.
- Font size is applied app-wide through the `MediaQuery` text scaler in `MyApp.builder`.

## Localization

Strings live in `lib/l10n/app_en.arb` and `app_ar.arb`. **Every key must exist in both files.** After editing, run `flutter gen-l10n`. Use `AppLocalizations.of(context)!`. Never hard-code user-visible text.

## Page guides

The `?` button runs a spotlight tour of the open tab. Wrap a widget with `GuideTarget(id: 'x', child: ...)` and describe it in `core/guide/page_guides.dart` with a `GuideStep(target: 'x', icon, title, body)`. Tab pages are wrapped in `GuideScope(id: ...)` in `router.dart`. Don't place a `GuideTarget` directly under an `Expanded`.

## Conventions worth knowing

- Reuse shared widgets and controllers before writing new ones.
- Every tab's FAB uses `heroTag: null` (several FABs live in the same shell).
- RTL: use `AlignmentDirectional` / `EdgeInsetsDirectional`; text fields detect direction from their content (`text_direction_utils.dart`).
- `int.clamp` returns `num`: use explicit min/max for ints.
- Generated files (`lib/core/rust/**`, `*.freezed.dart`, `app_localizations*.dart`) are never edited by hand.

More rules and the workflow for adding features are in the root [CONTRIBUTING.md](../CONTRIBUTING.md).
