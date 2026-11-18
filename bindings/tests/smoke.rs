//! End-to-end smoke tests: every API object against a real SQLite file in a temp dir.
//!
//! Run with `cargo test -p notecore_bindings`.

use notecore_bindings::api::NoteCore;
use notecore_bindings::dto::query::{ListRequestDto, SearchParamsDto};
use notecore_bindings::dto::task::{PriorityDto, ScheduleDto, SubTaskDto, TaskOptionsDto, TaskTypeDto, WeekdayDto};
use notecore_bindings::error::ApiErrorKind;

async fn open() -> (NoteCore, tempfile::TempDir) {
    let dir = tempfile::tempdir().unwrap();
    let core = NoteCore::open(dir.path().to_str().unwrap().to_string())
        .await
        .unwrap();
    (core, dir)
}

fn page(current_page: i64, limit: i64) -> ListRequestDto {
    ListRequestDto { current_page, limit }
}

#[tokio::test]
async fn notes_and_groups() {
    let (core, _dir) = open().await;
    let notes = core.notes();
    let tags = core.tags();

    let tag = tags.create_tag("work".into()).await.unwrap();
    let note = notes.create_note().await.unwrap();
    assert_eq!(note.title, "untitled");

    notes
        .update_note(note.id, "Plan".into(), "hello world\nsecond line".into())
        .await
        .unwrap();
    notes.update_tags(note.id, vec![tag.id]).await.unwrap();

    let got = notes.get_note(note.id).await.unwrap();
    assert_eq!(got.title, "Plan");
    assert_eq!(got.tags.len(), 1);
    assert_eq!(got.tags[0].name, "work");

    let list = notes.get_list(page(1, 10)).await.unwrap();
    assert_eq!(list.len(), 1);
    assert_eq!(list[0].preview, "hello world"); // first line only

    let found = notes
        .search(SearchParamsDto {
            text: Some("hello".into()),
            tags: Some(vec![tag.id]),
            created_before: None,
            created_after: None,
        }, page(1, 10))
        .await
        .unwrap();
    assert_eq!(found.len(), 1);

    // Groups: non-empty group cannot be deleted.
    let group = notes.create_note_group("Inbox".into(), 0).await.unwrap();
    notes.add_to_group(Some(group.id), vec![note.id]).await.unwrap();
    let err = notes.delete_group(group.id).await.unwrap_err();
    assert_eq!(err.kind, ApiErrorKind::Forbidden);

    let in_group = notes.get_list_in_group(page(1, 10), group.id).await.unwrap();
    assert_eq!(in_group.len(), 1);

    notes.add_to_group(None, vec![note.id]).await.unwrap();
    notes.delete_group(group.id).await.unwrap();
    notes.delete_note(note.id).await.unwrap();
    assert!(notes.get_list(page(1, 10)).await.unwrap().is_empty());
}

#[tokio::test]
async fn invalid_pagination_is_a_validation_error() {
    let (core, _dir) = open().await;

    let err = core.notes().get_list(page(0, 10)).await.unwrap_err();
    assert_eq!(err.kind, ApiErrorKind::Validation);

    let err = core.tags().get_list(Some(page(1, 0))).await.unwrap_err();
    assert_eq!(err.kind, ApiErrorKind::Validation);
}

#[tokio::test]
async fn tasks_roundtrip_options() {
    let (core, _dir) = open().await;
    let tasks = core.tasks();

    let options = TaskOptionsDto {
        priority: Some(PriorityDto::High),
        due_date: Some("2026-12-31".into()),
        schedule: Some(ScheduleDto::Weekly { days_of_week: vec![WeekdayDto::Saturday.into()], hour: 9 }),
        check_list: Some(vec![
            SubTaskDto{ text: "a".to_string(), checked: false }.into(),
            SubTaskDto{ text: "b".to_string(), checked: false }.into()
        ]),
    };
    let task = tasks
        .create_task(
            "Review".into(),
            "weekly review".into(),
            TaskTypeDto::Periodic,
            options,
            vec![],
        )
        .await
        .unwrap();

    let got = tasks.get_task(task.id).await.unwrap();
    assert_eq!(got.task_type, TaskTypeDto::Periodic);
    assert_eq!(got.options.priority, Some(PriorityDto::High));
    assert_eq!(
        got.options.schedule,
        Some(ScheduleDto::Weekly { days_of_week: vec![WeekdayDto::Saturday.into()], hour: 9 })
    );
    assert_eq!(
        got.options.check_list,
        Some(vec![
            SubTaskDto{ text: "a".to_string(), checked: false }.into(),
            SubTaskDto{ text: "b".to_string(), checked: false }.into()
        ])
    );

    assert!(tasks.toggle_done(task.id).await.unwrap());
    assert!(!tasks.toggle_done(task.id).await.unwrap());

    tasks
        .update_options(task.id, TaskOptionsDto::default())
        .await
        .unwrap();
    assert!(tasks.get_task(task.id).await.unwrap().options.schedule.is_none());

    tasks.delete_task(task.id).await.unwrap();
    assert!(tasks.get_list(None).await.unwrap().is_empty());
}

#[tokio::test]
async fn short_tasks_sections_and_items() {
    let (core, _dir) = open().await;
    let st = core.short_tasks();

    let section = st.create_section("Groceries".into(), vec![]).await.unwrap();
    let item = st.create_item(section.id, "milk".into()).await.unwrap();
    assert!(!item.done);
    assert!(st.toggle_item_done(item.id).await.unwrap());

    let got = st.get_section(section.id).await.unwrap();
    assert_eq!(got.listed_items, 1);
    assert_eq!(got.items.len(), 1);
    assert!(got.items[0].done);

    let err = st.delete_section(section.id, false).await.unwrap_err();
    assert_eq!(err.kind, ApiErrorKind::Forbidden);

    st.delete_section(section.id, true).await.unwrap(); // items cascade
    assert!(st.get_all_sections(None).await.unwrap().is_empty());
}

#[tokio::test]
async fn short_notes_sections_and_items() {
    let (core, _dir) = open().await;
    let sn = core.short_notes();

    let section = sn.create_section("Ideas".into(), vec![]).await.unwrap();
    let item = sn.create_item(section.id, "first".into()).await.unwrap();
    sn.update_item_content(item.id, "edited".into()).await.unwrap();

    let got = sn.get_section(section.id).await.unwrap();
    assert_eq!(got.items[0].content, "edited");

    let cards = sn.get_all_sections(Some(page(1, 10))).await.unwrap();
    assert_eq!(cards.len(), 1);
    assert_eq!(cards[0].listed_items, 1);

    let err = sn.delete_section(section.id, false).await.unwrap_err();
    assert_eq!(err.kind, ApiErrorKind::Forbidden);
    sn.delete_section(section.id, true).await.unwrap();
}

#[tokio::test]
async fn settings_persist_across_reopen() {
    let dir = tempfile::tempdir().unwrap();
    let path = dir.path().to_str().unwrap().to_string();

    let core = NoteCore::open(path.clone()).await.unwrap();
    assert_eq!(core.get_setting("theme".into()).await.unwrap(), Some("default".to_string()));
    core.set_setting("theme".into(), "dark".into()).await.unwrap();
    core.close().await;

    let core = NoteCore::open(path).await.unwrap();
    assert_eq!(
        core.get_setting("theme".into()).await.unwrap().as_deref(),
        Some("dark")
    );
}
