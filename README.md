# Stride

> *Notes and tasks that are simple to start and deep when you need them.*

Stride keeps your **notes, quick thoughts, tasks and checklists** in one fast app that works fully offline. Open it, tap **+**, write. Everything else (tags, groups, filters, repeating tasks, sub-tasks, themes) is there when you reach for it, and out of the way when you don't.

## Why Stride exists

Notes and task apps tend to land at one of two extremes:

- **Simple, but poor in features.** Easy on day one, then you outgrow them: no tags, no real search, no recurring tasks, nowhere to put longer writing.
- **Feature-rich, but unimaginably complex.** They can do everything, but you have to learn a system before you can write your first note. The bar for entry is high.

Stride was designed for one purpose: **to be the mediator between the two.** It is simple to use, with minimal (if any) things to know, and still feature-rich.

1. **Nothing to learn up front.** No setup, no account, no templates, no vocabulary to memorize.
2. **Depth that never gets in the way.** Powerful features appear only where and when you reach for them.
3. **Four tools, each shaped for its job.** Long writing, quick ideas, tasks with dates and repeats, and plain checkboxes. One app, no silos.
4. **Yours and fast.** Everything stays on your device and responds instantly.

## What you can do

Stride has four tabs. Each one is built for a different kind of thinking.

### Notes: for longer writing
Journals, meeting notes, drafts, documentation.
- Write with **Markdown** (a toolbar helps, so you don't need to know the syntax). Notes **save automatically**.
- Organize with **groups** (tabs above the list) and **tags**.
- Arabic and other right-to-left text just works, line by line.

### Thoughts: for quick ideas
A thought is a short one-liner, kept inside a **section** (a topic, a project, an area of life).
- Jot ideas down in seconds, on the chat-like interface, in the section where they belong.
- See your sections as a **grid or a list**.

### Tasks: for things to do
- **One-time tasks** with a title, notes, due date and priority.
- **Repeating tasks**: daily, every few days, weekly on the days you pick, monthly or yearly. A finished repeating task **comes back by itself** at the time you choose in Settings.
- **Sub-tasks** you can tick from the list without opening the task. Finishing a task does not require finishing its sub-tasks.
- An **Upcoming** strip at the top shows what is due soon.
- Switch between **unfinished and finished**, and between **all, one-time or repeating** tasks. Extra task filters (priority, due dates) sit in the filter panel.
- Tasks are saved when you confirm, and the app warns you before you leave with unsaved changes.

### Checklists: for quick lists
Shopping, packing, "before I leave the house": **collapsible sections of checkbox-only items**. Tick items right in the list. Finished items and sections hide themselves, and one switch brings them back.

### Everywhere
- **Search** from the top of every tab, as you type.
- **Filters:** tap the filter button to narrow by **tags** and **dates**. The search follows you between tabs.
- **Tags** work on notes, thought sections, checklist sections and tasks.
- **Select several items** by long-pressing, then tag, move, rename or delete them together.
- **Pull down** to refresh.
- **Guides:** the **?** button in the top bar gives a short visual tour of the tab you are on.

### Settings
Open the gear icon for **Settings**.

| Setting | Options |
|---|---|
| Language | Device default, English, Arabic |
| Theme | Rust, Aqua, Forest (more can be added easily) |
| Font size | 12 to 24 (14 is the default), with a live preview |
| Daily reset time | The hour when finished repeating tasks come back (default: midnight) |

Light and dark mode follow your device.

## Privacy

Your data lives in a single database on your device. Stride has no account, no sync server, no analytics and asks for no special permissions.

## Getting started

### Use it
Build and install the app on your device (see below). On first launch there is nothing to configure: tap **+** on any tab.

### Run it from source

You need [Rust](https://rustup.rs), the [Flutter SDK](https://docs.flutter.dev/get-started/install), and `flutter_rust_bridge_codegen` 2.13.0.

```bash
cargo install flutter_rust_bridge_codegen --version 2.13.0

flutter_rust_bridge_codegen generate     # generate the Dart bindings 

cd mobile_client
flutter pub get
flutter gen-l10n                         # generate translations
flutter run
```

Android builds also need the Android SDK/NDK and the Rust Android targets (`rustup target add aarch64-linux-android armv7-linux-androideabi x86_64-linux-android`).

## Project at a glance

```
.
├── core/            Rust: the brain. Data, search, rules. No UI.
├── bindings/        Rust: the API exposed to Flutter
├── mobile_client/   Flutter: the app's interface   (see mobile_client/README.md)
├── README.md        you are here
├── LICENSE
└── CONTRIBUTING.md  how the project works, where things are, rules for contributing
```

All the logic that is not UI lives in the Rust core, which makes it reusable on any platform. The Flutter app only shows data and forwards your actions.

## Contribution

**Want to contribute or understand the internals?** Read [CONTRIBUTING.md](CONTRIBUTING.md). It covers the architecture, the database, how to add features and the rules we follow.

Contributions and appreciated.

## Roadmap

- Backup & Restore
- Markdown vault import/export (e.g. Obsidian).
- More themes and settings; more clients on top of the same core.
- Guides for the editor pages and Settings.

## Naming

**Stride** is the app. **NoteCore** is the code name of the Rust core and its internals (crate `notecore`, database `notecore.db`, package `mobile_client`).

## License

Stride is licensed under the [Apache License 2.0](LICENSE).