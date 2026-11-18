use chrono::{Duration, Utc};

// use super::common::*;
use crate::models::notes::notes::{Note, NoteGroup};
use crate::models::notes::ui_notes::{UINote, UINoteGroup};
use crate::models::repo::Model;
use crate::models::tags::tags::Tag;
use crate::services::notes::NotesService;

async fn mk_note(db: &TestDb, title: &str, content: &str, tags: Vec<i64>) -> Note {
    let mut n = Note::new();
    n.title = title.to_string();
    n.content = content.to_string();
    n.tags.0 = tags;
    n.create(&db.pool).await.unwrap();
    n
}

async fn mk_group(db: &TestDb, name: &str, placing: i64) -> NoteGroup {
    let mut g = NoteGroup::new(name, placing);
    g.create(&db.pool).await.unwrap();
    g
}

// ============================================================ Note (model)

#[test]
fn new_note_has_defaults() {
    let n = Note::new();
    assert_eq!(n.id, 0);
    assert_eq!(n.title, "untitled");
    assert_eq!(n.content, "");
    assert_eq!(n.group_id, None);
    assert!(n.tags.0.is_empty());
}

#[tokio::test]
async fn note_create_then_get() {
    let db = TestDb::new().await;
    let n = mk_note(&db, "Title", "Body", vec![]).await;
    assert!(n.id > 0);

    let found = Note::get_by_id(&db.pool, n.id).await.unwrap();
    assert_eq!(found.title, "Title");
    assert_eq!(found.content, "Body");
    assert_eq!(found.group_id, None);
    assert!(Note::get_by_id(&db.pool, 9999).await.is_err());
}

#[tokio::test]
async fn note_update_changes_fields_and_bumps_updated_at() {
    let db = TestDb::new().await;
    let mut n = mk_note(&db, "a", "b", vec![]).await;
    let first = n.updated_at;
    tick().await;

    n.title = "changed".to_string();
    n.content = "new body".to_string();
    n.update(&db.pool).await.unwrap();
    assert!(n.updated_at > first);

    let found = Note::get_by_id(&db.pool, n.id).await.unwrap();
    assert_eq!(found.title, "changed");
    assert_eq!(found.content, "new body");
}

#[tokio::test]
async fn note_get_all_is_newest_first_and_paginated() {
    let db = TestDb::new().await;
    for i in 0..5 {
        mk_note(&db, &format!("n{i}"), "", vec![]).await;
        tick().await;
    }
    let all = Note::get_all(&db.pool, None).await.unwrap();
    assert_eq!(all.len(), 5);
    assert_eq!(all[0].title, "n4");
    assert_eq!(all[4].title, "n0");

    assert_eq!(Note::get_all(&db.pool, Some(page(1, 2))).await.unwrap().len(), 2);
    assert_eq!(Note::get_all(&db.pool, Some(page(3, 2))).await.unwrap().len(), 1);
    assert_eq!(Note::get_count(&db.pool).await.unwrap(), 5);
}

#[tokio::test]
async fn note_search_matches_title_or_content() {
    let db = TestDb::new().await;
    mk_note(&db, "Shopping list", "milk", vec![]).await;
    mk_note(&db, "Ideas", "build a shopping app", vec![]).await;
    mk_note(&db, "Other", "nothing", vec![]).await;

    let found = Note::search(&db.pool, params(Some("shopping"), None), None)
        .await
        .unwrap();
    assert_eq!(found.len(), 2);
    assert!(Note::search(&db.pool, params(Some("zzz"), None), None)
        .await
        .unwrap()
        .is_empty());
}

#[tokio::test]
async fn note_search_by_tags_requires_all_of_them() {
    let db = TestDb::new().await;
    let a = mk_tag(&db.pool, "a").await;
    let b = mk_tag(&db.pool, "b").await;
    let c = mk_tag(&db.pool, "c").await;
    mk_note(&db, "only a", "", vec![a]).await;
    mk_note(&db, "a and b", "", vec![a, b]).await;

    let q = |tags: Vec<i64>| params(None, Some(tags));
    assert_eq!(Note::search(&db.pool, q(vec![a]), None).await.unwrap().len(), 2);
    assert_eq!(Note::search(&db.pool, q(vec![a, b]), None).await.unwrap().len(), 1);
    assert_eq!(Note::search(&db.pool, q(vec![c]), None).await.unwrap().len(), 0);
}

#[tokio::test]
async fn note_search_combines_text_and_tag() {
    let db = TestDb::new().await;
    let a = mk_tag(&db.pool, "a").await;
    mk_note(&db, "match", "", vec![a]).await;
    mk_note(&db, "match too", "", vec![]).await;

    let found = Note::search(&db.pool, params(Some("match"), Some(vec![a])), None)
        .await
        .unwrap();
    assert_eq!(found.len(), 1);
    assert_eq!(found[0].title, "match");
}

#[tokio::test]
async fn note_search_filters_by_date_and_paginates() {
    let db = TestDb::new().await;
    for i in 0..3 {
        mk_note(&db, &format!("n{i}"), "", vec![]).await;
    }
    let mut future = params(None, None);
    future.created_after = Some(Utc::now() + Duration::days(1));
    assert!(Note::search(&db.pool, future, None).await.unwrap().is_empty());

    let mut past = params(None, None);
    past.created_before = Some(Utc::now() - Duration::days(1));
    assert!(Note::search(&db.pool, past, None).await.unwrap().is_empty());

    let page_one = Note::search(&db.pool, params(None, None), Some(page(1, 2)))
        .await
        .unwrap();
    assert_eq!(page_one.len(), 2);
}

#[tokio::test]
async fn note_delete_removes_it() {
    let db = TestDb::new().await;
    let n = mk_note(&db, "x", "", vec![]).await;
    Note::delete(&db.pool, n.id).await.unwrap();
    assert!(Note::get_by_id(&db.pool, n.id).await.is_err());
}

#[tokio::test]
async fn note_get_with_group_id_returns_only_that_group() {
    let db = TestDb::new().await;
    let g = mk_group(&db, "work", 1).await;
    let mut inside = mk_note(&db, "inside", "", vec![]).await;
    mk_note(&db, "outside", "", vec![]).await;
    inside.group_id = Some(g.id);
    inside.update(&db.pool).await.unwrap();

    let found = Note::get_with_group_id(&db.pool, page(1, 10), g.id)
        .await
        .unwrap();
    assert_eq!(found.len(), 1);
    assert_eq!(found[0].title, "inside");
}

#[tokio::test]
async fn note_add_to_group_moves_notes_and_can_clear_the_group() {
    let db = TestDb::new().await;
    let g = mk_group(&db, "g", 1).await;
    let n1 = mk_note(&db, "1", "", vec![]).await;
    let n2 = mk_note(&db, "2", "", vec![]).await;

    Note::add_to_group(&db.pool, Some(g.id), vec![n1.id, n2.id])
        .await
        .unwrap();
    assert_eq!(Note::get_by_id(&db.pool, n1.id).await.unwrap().group_id, Some(g.id));
    assert_eq!(Note::get_by_id(&db.pool, n2.id).await.unwrap().group_id, Some(g.id));

    Note::add_to_group(&db.pool, None, vec![n1.id]).await.unwrap();
    assert_eq!(Note::get_by_id(&db.pool, n1.id).await.unwrap().group_id, None);
    assert_eq!(Note::get_by_id(&db.pool, n2.id).await.unwrap().group_id, Some(g.id));
}

#[tokio::test]
async fn note_add_to_group_with_no_ids_does_nothing() {
    let db = TestDb::new().await;
    let g = mk_group(&db, "g", 1).await;
    Note::add_to_group(&db.pool, Some(g.id), vec![]).await.unwrap();
}

#[tokio::test]
async fn note_cannot_point_to_a_missing_group() {
    let db = TestDb::new().await;
    let mut n = Note::new();
    n.group_id = Some(9999);
    assert!(n.create(&db.pool).await.is_err());
}

// ======================================================== NoteGroup (model)

#[tokio::test]
async fn group_create_and_get_with_listed_notes() {
    let db = TestDb::new().await;
    let g = mk_group(&db, "work", 3).await;
    assert!(g.id > 0);
    assert_eq!(g.listed_notes, 0);

    let n1 = mk_note(&db, "1", "", vec![]).await;
    let n2 = mk_note(&db, "2", "", vec![]).await;
    Note::add_to_group(&db.pool, Some(g.id), vec![n1.id, n2.id])
        .await
        .unwrap();

    let found = NoteGroup::get_by_id(&db.pool, g.id).await.unwrap();
    assert_eq!(found.name, "work");
    assert_eq!(found.placing, 3);
    assert_eq!(found.listed_notes, 2);
    assert!(NoteGroup::get_by_id(&db.pool, 9999).await.is_err());
}

#[tokio::test]
async fn groups_are_ordered_by_placing() {
    let db = TestDb::new().await;
    mk_group(&db, "second", 2).await;
    mk_group(&db, "first", 1).await;
    mk_group(&db, "third", 3).await;

    let names: Vec<String> = NoteGroup::get_all(&db.pool, None)
        .await
        .unwrap()
        .into_iter()
        .map(|g| g.name)
        .collect();
    assert_eq!(names, vec!["first", "second", "third"]);
    assert_eq!(NoteGroup::get_count(&db.pool).await.unwrap(), 3);
    assert_eq!(NoteGroup::get_all(&db.pool, Some(page(2, 2))).await.unwrap().len(), 1);
}

#[tokio::test]
async fn group_search_matches_the_name() {
    let db = TestDb::new().await;
    mk_group(&db, "Work", 1).await;
    mk_group(&db, "Home", 2).await;
    let found = NoteGroup::search(&db.pool, params(Some("wor"), None), None)
        .await
        .unwrap();
    assert_eq!(found.len(), 1);
    assert_eq!(found[0].name, "Work");
    assert_eq!(
        NoteGroup::search(&db.pool, params(None, None), Some(page(1, 1)))
            .await
            .unwrap()
            .len(),
        1
    );
}

#[tokio::test]
async fn group_update_changes_name_and_placing() {
    let db = TestDb::new().await;
    let mut g = mk_group(&db, "old", 1).await;
    g.name = "new".to_string();
    g.placing = 9;
    g.update(&db.pool).await.unwrap();
    let found = NoteGroup::get_by_id(&db.pool, g.id).await.unwrap();
    assert_eq!(found.name, "new");
    assert_eq!(found.placing, 9);
}

#[tokio::test]
async fn deleting_a_group_leaves_its_notes_ungrouped() {
    let db = TestDb::new().await;
    let g = mk_group(&db, "g", 1).await;
    let n = mk_note(&db, "n", "", vec![]).await;
    Note::add_to_group(&db.pool, Some(g.id), vec![n.id]).await.unwrap();

    NoteGroup::delete(&db.pool, g.id).await.unwrap();
    assert!(NoteGroup::get_by_id(&db.pool, g.id).await.is_err());
    assert_eq!(Note::get_by_id(&db.pool, n.id).await.unwrap().group_id, None);
}

// ============================================================ UI structs

#[test]
fn ui_note_group_copies_the_group() {
    let mut g = NoteGroup::new("g", 4);
    g.id = 5;
    g.listed_notes = 2;
    let ui = UINoteGroup::from(g);
    assert_eq!((ui.id, ui.name.as_str(), ui.listed_notes, ui.placing), (5, "g", 2, 4));
}

#[test]
fn ui_note_copies_fields_and_maps_tags() {
    let mut n = Note::new();
    n.id = 3;
    n.group_id = Some(8);
    n.title = "t".to_string();
    n.content = "c".to_string();
    let tag = Tag {
        id: 1,
        name: "tag".to_string(),
        created_at: Utc::now(),
    };
    let ui = UINote::from(n, vec![tag]);
    assert_eq!(ui.id, 3);
    assert_eq!(ui.group_id, Some(8));
    assert_eq!(ui.title, "t");
    assert_eq!(ui.content, "c");
    assert_eq!(ui.tags.len(), 1);
    assert_eq!(ui.tags[0].name, "tag");
}

// ============================================================== service

async fn svc(db: &TestDb) -> NotesService {
    NotesService::new(db.pool.clone()).await.unwrap()
}

#[tokio::test]
async fn service_creates_an_untitled_empty_note() {
    let db = TestDb::new().await;
    let s = svc(&db).await;
    let n = s.create_note().await.unwrap();
    assert!(n.id > 0);
    assert_eq!(n.title, "untitled");
    assert_eq!(n.content, "");
    assert!(n.tags.is_empty());
    assert_eq!(n.group_id, None);

    let again = s.get_note(n.id).await.unwrap();
    assert_eq!(again.id, n.id);
}

#[tokio::test]
async fn service_update_note_persists_title_and_content() {
    let db = TestDb::new().await;
    let s = svc(&db).await;
    let n = s.create_note().await.unwrap();
    s.update_note(n.id, "Plan".to_string(), "Step one".to_string())
        .await
        .unwrap();
    let got = s.get_note(n.id).await.unwrap();
    assert_eq!(got.title, "Plan");
    assert_eq!(got.content, "Step one");
}

#[tokio::test]
async fn service_get_note_fails_for_unknown_ids() {
    let db = TestDb::new().await;
    let s = svc(&db).await;
    assert!(s.get_note(9999).await.is_err());
    assert!(s.update_note(9999, "a".to_string(), "b".to_string()).await.is_err());
}

#[tokio::test]
async fn service_update_tags_resolves_tags_on_get() {
    let db = TestDb::new().await;
    let s = svc(&db).await;
    let t1 = mk_tag(&db.pool, "one").await;
    let t2 = mk_tag(&db.pool, "two").await;
    let n = s.create_note().await.unwrap();

    s.update_tags(n.id, vec![t1, t2]).await.unwrap();
    let got = s.get_note(n.id).await.unwrap();
    let mut names: Vec<String> = got.tags.into_iter().map(|t| t.name).collect();
    names.sort();
    assert_eq!(names, vec!["one", "two"]);

    s.update_tags(n.id, vec![]).await.unwrap();
    assert!(s.get_note(n.id).await.unwrap().tags.is_empty());
}

#[tokio::test]
async fn service_list_item_preview_is_the_first_line() {
    let db = TestDb::new().await;
    let s = svc(&db).await;
    let a = s.create_note().await.unwrap();
    s.update_note(a.id, "multi".to_string(), "first line\nsecond line".to_string())
        .await
        .unwrap();
    let b = s.create_note().await.unwrap();

    let list = s.get_list(page(1, 10)).await.unwrap();
    let by_id = |id: i64| list.iter().find(|i| i.id == id).unwrap();
    assert_eq!(by_id(a.id).preview, "first line");
    assert_eq!(by_id(b.id).preview, "");
}

#[tokio::test]
async fn service_list_paginates_newest_first() {
    let db = TestDb::new().await;
    let s = svc(&db).await;
    for i in 0..3 {
        let n = s.create_note().await.unwrap();
        s.update_note(n.id, format!("n{i}"), String::new()).await.unwrap();
        tick().await;
    }
    let first_page = s.get_list(page(1, 2)).await.unwrap();
    assert_eq!(first_page.len(), 2);
    assert_eq!(first_page[0].title, "n2");
    assert_eq!(s.get_list(page(2, 2)).await.unwrap().len(), 1);
}

#[tokio::test]
async fn service_list_shows_tags_of_each_note() {
    let db = TestDb::new().await;
    let s = svc(&db).await;
    let t = mk_tag(&db.pool, "x").await;
    let n = s.create_note().await.unwrap();
    s.update_tags(n.id, vec![t]).await.unwrap();
    let list = s.get_list(page(1, 10)).await.unwrap();
    assert_eq!(list[0].tags.len(), 1);
    assert_eq!(list[0].tags[0].name, "x");
}

#[tokio::test]
async fn service_search_uses_text_and_tags() {
    let db = TestDb::new().await;
    let s = svc(&db).await;
    let t = mk_tag(&db.pool, "x").await;
    let a = s.create_note().await.unwrap();
    s.update_note(a.id, "apple pie".to_string(), String::new()).await.unwrap();
    s.update_tags(a.id, vec![t]).await.unwrap();
    let b = s.create_note().await.unwrap();
    s.update_note(b.id, "apple juice".to_string(), String::new()).await.unwrap();

    let by_text = s.search(params(Some("apple"), None), page(1, 10)).await.unwrap();
    assert_eq!(by_text.len(), 2);
    let by_both = s
        .search(params(Some("apple"), Some(vec![t])), page(1, 10))
        .await
        .unwrap();
    assert_eq!(by_both.len(), 1);
    assert_eq!(by_both[0].title, "apple pie");
}

#[tokio::test]
async fn service_groups_are_created_ordered_and_counted() {
    let db = TestDb::new().await;
    let s = svc(&db).await;
    let second = s.create_note_group("second", 2).await.unwrap();
    let first = s.create_note_group("first", 1).await.unwrap();
    assert!(first.id > 0);

    let n = s.create_note().await.unwrap();
    s.add_to_group(Some(first.id), vec![n.id]).await.unwrap();

    let groups = s.get_groups().await.unwrap();
    assert_eq!(groups.len(), 2);
    assert_eq!(groups[0].name, "first");
    assert_eq!(groups[0].listed_notes, 1);
    assert_eq!(groups[1].id, second.id);
    assert_eq!(groups[1].listed_notes, 0);
}

#[tokio::test]
async fn service_lists_the_notes_of_one_group() {
    let db = TestDb::new().await;
    let s = svc(&db).await;
    let g = s.create_note_group("g", 1).await.unwrap();
    let inside = s.create_note().await.unwrap();
    s.create_note().await.unwrap();
    s.add_to_group(Some(g.id), vec![inside.id]).await.unwrap();

    let list = s.get_list_group(page(1, 10), g.id).await.unwrap();
    assert_eq!(list.len(), 1);
    assert_eq!(list[0].id, inside.id);
    assert_eq!(list[0].group_id, Some(g.id));
}

#[tokio::test]
async fn service_renames_a_group() {
    let db = TestDb::new().await;
    let s = svc(&db).await;
    let g = s.create_note_group("old", 1).await.unwrap();
    s.update_note_group(g.id, "new".to_string()).await.unwrap();
    assert_eq!(s.get_groups().await.unwrap()[0].name, "new");
}

#[tokio::test]
async fn service_refuses_to_delete_a_group_that_still_has_notes() {
    let db = TestDb::new().await;
    let s = svc(&db).await;
    let g = s.create_note_group("g", 1).await.unwrap();
    let n = s.create_note().await.unwrap();
    s.add_to_group(Some(g.id), vec![n.id]).await.unwrap();

    assert!(is_forbidden(&s.delete_group(g.id).await));
    assert_eq!(s.get_groups().await.unwrap().len(), 1);

    // once the group is empty it can go
    s.add_to_group(None, vec![n.id]).await.unwrap();
    s.delete_group(g.id).await.unwrap();
    assert!(s.get_groups().await.unwrap().is_empty());
}

#[tokio::test]
async fn service_deletes_a_note() {
    let db = TestDb::new().await;
    let s = svc(&db).await;
    let n = s.create_note().await.unwrap();
    s.delete_note(n.id).await.unwrap();
    assert!(s.get_note(n.id).await.is_err());
}

#[tokio::test]
async fn service_reorders_groups() {
    let db = TestDb::new().await;
    let s = svc(&db).await;
    let a = s.create_note_group("a", 0).await.unwrap();
    let b = s.create_note_group("b", 1).await.unwrap();
    let c = s.create_note_group("c", 2).await.unwrap();

    s.reorder_note_groups(vec![c.id, a.id, b.id]).await.unwrap();

    let names: Vec<String> = s.get_groups().await.unwrap().into_iter().map(|g| g.name).collect();
    assert_eq!(names, vec!["c", "a", "b"]);
}

#[tokio::test]
async fn service_reorder_with_unknown_group_fails() {
    let db = TestDb::new().await;
    let s = svc(&db).await;
    let a = s.create_note_group("a", 0).await.unwrap();
    assert!(s.reorder_note_groups(vec![a.id, 9999]).await.is_err());
}
