// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get app_title => 'Stride';

  @override
  String get shell_navBar_note_view => 'Notes';

  @override
  String get shell_navBar_thought_view => 'Thoughts';

  @override
  String get shell_navBar_task_view => 'Tasks';

  @override
  String get shell_navBar_checklist_view => 'Checklists';

  @override
  String get general_filters => 'Filters';

  @override
  String get notes_all => 'All';

  @override
  String get notes_delete => 'Delete';

  @override
  String get notes_change_group => 'Change Group';

  @override
  String get notes_select_group => 'Move to Group';

  @override
  String get notes_empty => 'No notes found';

  @override
  String get notes_unassigned => 'Unassigned';

  @override
  String notes_selected_count(int count) {
    return '$count selected';
  }

  @override
  String get notes_search_hint => 'Search notes';

  @override
  String get notes_no_results => 'No matching notes';

  @override
  String get notes_untitled => 'Untitled';

  @override
  String get notes_new_note => 'New note';

  @override
  String get notes_clear_selection => 'Cancel selection';

  @override
  String get notes_clear_filters => 'Clear';

  @override
  String get notes_created_after => 'Created after';

  @override
  String get notes_created_before => 'Created before';

  @override
  String get notes_tags => 'Tags';

  @override
  String get notes_tags_empty => 'No tags yet';

  @override
  String get notes_new_tag => 'New tag';

  @override
  String get notes_add_tag => 'Add tag';

  @override
  String get notes_manage_groups => 'Manage groups';

  @override
  String get notes_new_group => 'New group';

  @override
  String get notes_rename_group => 'Rename group';

  @override
  String get notes_group_name => 'Group name';

  @override
  String get notes_groups_empty => 'No groups yet';

  @override
  String notes_count(int count) {
    return '$count notes';
  }

  @override
  String get notes_cancel => 'Cancel';

  @override
  String get notes_save => 'Save';

  @override
  String get notes_create => 'Create';

  @override
  String get notes_done => 'Done';

  @override
  String get notes_delete_notes_title => 'Delete notes?';

  @override
  String notes_delete_notes_body(int count) {
    return '$count selected notes will be permanently deleted.';
  }

  @override
  String get notes_delete_group_title => 'Delete group?';

  @override
  String notes_delete_group_body(String name) {
    return '“$name” will be deleted. A group that still contains notes can\'t be deleted.';
  }

  @override
  String get notes_delete_tag_title => 'Delete tag?';

  @override
  String notes_delete_tag_body(String name) {
    return '“$name” will be removed from all notes.';
  }

  @override
  String get note_title_hint => 'Title';

  @override
  String get note_content_hint => 'Start writing…';

  @override
  String get note_saved => 'Saved';

  @override
  String get note_saving => 'Saving…';

  @override
  String get note_unsaved => 'Unsaved';

  @override
  String get note_save_failed => 'Not saved';

  @override
  String get note_leave_failed =>
      'Couldn\'t save your changes. Go back again to leave without saving.';

  @override
  String get note_load_failed => 'Couldn\'t load this note';

  @override
  String get note_share => 'Share';

  @override
  String get note_delete_title => 'Delete note?';

  @override
  String get note_delete_body => 'This note will be permanently deleted.';

  @override
  String get note_undo => 'Undo';

  @override
  String get note_redo => 'Redo';

  @override
  String get note_heading => 'Heading';

  @override
  String get note_bullet_list => 'Bullet list';

  @override
  String get note_checklist => 'Checklist';

  @override
  String get note_indent => 'Indent';

  @override
  String get note_outdent => 'Outdent';

  @override
  String get thoughts_search_hint => 'Search thoughts';

  @override
  String get thoughts_empty => 'No thoughts yet';

  @override
  String get thoughts_new_section => 'New section';

  @override
  String get thoughts_section_name => 'Section name';

  @override
  String get thoughts_rename_section => 'Rename section';

  @override
  String thoughts_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count thoughts',
      one: '1 thought',
      zero: 'No thoughts',
    );
    return '$_temp0';
  }

  @override
  String thoughts_delete_title(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Delete sections?',
      one: 'Delete section?',
    );
    return '$_temp0';
  }

  @override
  String thoughts_delete_body(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count sections and all their thoughts will be permanently deleted.',
      one: 'This section and all its thoughts will be permanently deleted.',
    );
    return '$_temp0';
  }

  @override
  String get thoughts_new_item_hint => 'Add a thought…';

  @override
  String get thoughts_add => 'Add';

  @override
  String get thoughts_grid_view => 'Grid view';

  @override
  String get thoughts_list_view => 'List view';

  @override
  String get thoughts_load_failed => 'Couldn\'t load this section';

  @override
  String get thoughts_section_empty =>
      'Nothing here yet. Add your first thought below.';

  @override
  String get checklists_search_hint => 'Search checklists';

  @override
  String get checklists_empty => 'No checklists yet';

  @override
  String get checklists_all_done => 'All done! Nothing left to do';

  @override
  String get checklists_new_section => 'New checklist';

  @override
  String get checklists_section_name => 'Checklist name';

  @override
  String get checklists_rename_section => 'Rename checklist';

  @override
  String get checklists_show_completed => 'Show completed';

  @override
  String checklists_delete_title(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Delete checklists?',
      one: 'Delete checklist?',
    );
    return '$_temp0';
  }

  @override
  String checklists_delete_body(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count checklists and all their tasks will be permanently deleted.',
      one: 'This checklist and all its tasks will be permanently deleted.',
    );
    return '$_temp0';
  }

  @override
  String get checklists_new_item_hint => 'Add a task…';

  @override
  String get checklists_add => 'Add';

  @override
  String get checklists_load_failed => 'Couldn\'t load this checklist';

  @override
  String get checklists_section_empty =>
      'No tasks yet. Add your first task below.';

  @override
  String get checklists_no_tasks => 'No tasks yet';

  @override
  String get checklists_edit_tasks => 'Edit checklist';

  @override
  String get tasks_search_hint => 'Search tasks';

  @override
  String get tasks_new => 'New task';

  @override
  String get tasks_edit => 'Edit task';

  @override
  String get tasks_empty => 'No tasks yet';

  @override
  String get tasks_empty_simple => 'No one-time tasks';

  @override
  String get tasks_empty_periodic => 'No periodic tasks';

  @override
  String get tasks_upcoming => 'Upcoming';

  @override
  String get tasks_all => 'All tasks';

  @override
  String get tasks_view_simple => 'Tasks';

  @override
  String get tasks_view_periodic => 'Periodic';

  @override
  String tasks_delete_title(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Delete tasks?',
      one: 'Delete task?',
    );
    return '$_temp0';
  }

  @override
  String tasks_delete_body(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tasks will be permanently deleted.',
      one: 'This task will be permanently deleted.',
    );
    return '$_temp0';
  }

  @override
  String get tasks_title_hint => 'Title';

  @override
  String get tasks_description_hint => 'Description';

  @override
  String get tasks_title_required => 'Give the task a title';

  @override
  String get tasks_load_failed => 'Couldn\'t load this task';

  @override
  String get tasks_type => 'Type';

  @override
  String get tasks_type_one_time => 'One-time';

  @override
  String get tasks_type_periodic => 'Periodic';

  @override
  String get tasks_priority => 'Priority';

  @override
  String get tasks_priority_none => 'None';

  @override
  String get tasks_priority_lowest => 'Lowest';

  @override
  String get tasks_priority_low => 'Low';

  @override
  String get tasks_priority_medium => 'Medium';

  @override
  String get tasks_priority_high => 'High';

  @override
  String get tasks_priority_highest => 'Highest';

  @override
  String get tasks_due_date => 'Due date';

  @override
  String get tasks_no_due_date => 'No due date';

  @override
  String get tasks_schedule => 'Repeats';

  @override
  String get tasks_kind_daily => 'Every day';

  @override
  String get tasks_kind_every_n_days => 'Every N days';

  @override
  String get tasks_kind_weekly => 'Every week';

  @override
  String get tasks_kind_monthly => 'Every month';

  @override
  String get tasks_kind_yearly => 'Every year';

  @override
  String get tasks_field_repeats => 'Repeats';

  @override
  String get tasks_field_days => 'Days';

  @override
  String get tasks_field_day_of_week => 'Day';

  @override
  String get tasks_field_day_of_month => 'Day of month';

  @override
  String get tasks_field_month => 'Month';

  @override
  String get tasks_field_hour => 'Time';

  @override
  String tasks_sched_daily(String time) {
    return 'Every day at $time';
  }

  @override
  String tasks_sched_every_n_days(int count, String time) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Every $count days at $time',
      one: 'Every day at $time',
    );
    return '$_temp0';
  }

  @override
  String tasks_sched_weekly(String day, String time) {
    return 'Every $day at $time';
  }

  @override
  String tasks_sched_monthly(int day, String time) {
    return 'Day $day of every month at $time';
  }

  @override
  String tasks_sched_yearly(String date, String time) {
    return 'Every $date at $time';
  }

  @override
  String get tasks_checklist => 'Checklist';

  @override
  String get tasks_checklist_add => 'Add item';

  @override
  String tasks_checklist_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
    );
    return '$_temp0';
  }

  @override
  String get tasks_discard_title => 'Discard changes?';

  @override
  String get tasks_discard_body =>
      'You have unsaved changes. If you leave now, they will be lost.';

  @override
  String get tasks_discard => 'Discard';

  @override
  String get tasks_status_unfinished => 'Unfinished';

  @override
  String get tasks_status_finished => 'Finished';

  @override
  String get tasks_all_types => 'All types';

  @override
  String get tasks_empty_finished => 'No finished tasks yet';

  @override
  String get tasks_due_after => 'Due after';

  @override
  String get tasks_due_before => 'Due before';

  @override
  String get settings_title => 'Settings';

  @override
  String get settings_appearance => 'Appearance';

  @override
  String get settings_theme => 'Theme';

  @override
  String get settings_font_size => 'Font size';

  @override
  String get settings_font_preview =>
      'The quick brown fox jumps over the lazy dog';

  @override
  String get settings_general => 'General';

  @override
  String get settings_language => 'Language';

  @override
  String get settings_language_default => 'Device default';

  @override
  String get settings_reset_time => 'Daily reset time';

  @override
  String get settings_reset_time_hint => 'Hour at which periodic tasks reset';

  @override
  String get settings_reset_defaults => 'Reset to defaults';

  @override
  String get settings_reset_title => 'Reset settings?';

  @override
  String get settings_reset_body =>
      'All settings return to their default values.';

  @override
  String get settings_reset_action => 'Reset';

  @override
  String get guide_tooltip => 'Page guide';

  @override
  String get guide_next => 'Next';

  @override
  String get guide_back => 'Back';

  @override
  String get guide_skip => 'Skip';

  @override
  String get guide_done => 'Done';

  @override
  String get guide_search_title => 'Search';

  @override
  String get guide_search_body =>
      'Type here to search. The list updates as you type, and the same search follows you between pages.';

  @override
  String get guide_filters_title => 'Filters and tags';

  @override
  String get guide_filters_body =>
      'Tap the filter button at the end of the search field to open the filter panel: narrow the list by tags and by date. A number on the button shows how many filters are active.';

  @override
  String get guide_refresh => 'Pull down to refresh.';

  @override
  String get guide_notes_intro_title => 'Notes';

  @override
  String get guide_notes_intro_body =>
      'This is where your notes live: longer text you can format. Here is a quick tour of what you can do on this page.';

  @override
  String get guide_notes_create_title => 'New note';

  @override
  String get guide_notes_create_body =>
      'Tap + to create a note and start writing right away. Notes save automatically.';

  @override
  String get guide_notes_groups_title => 'Groups';

  @override
  String get guide_notes_groups_body =>
      'Notes are organized in groups. Tap a group to see only its notes, or pick the first one to see everything. The manage button at the end of the row lets you create, rename and delete groups.';

  @override
  String get guide_notes_list_title => 'Your notes';

  @override
  String get guide_notes_list_body => 'Tap a note to open and edit it.';

  @override
  String get guide_notes_select_title => 'Selecting notes';

  @override
  String get guide_notes_select_body =>
      'Long-press a note to select it, then tap more notes to add them. The bar at the top lets you add tags, move the selected notes to another group, or delete them.';

  @override
  String get guide_thoughts_intro_title => 'Thoughts';

  @override
  String get guide_thoughts_intro_body =>
      'Thoughts are sections that each hold short one-line notes. Perfect for ideas you want to jot down fast.';

  @override
  String get guide_thoughts_create_title => 'New section';

  @override
  String get guide_thoughts_create_body =>
      'Tap + and give the section a name. It opens right away so you can start adding thoughts.';

  @override
  String get guide_thoughts_view_title => 'Layout';

  @override
  String get guide_thoughts_view_body =>
      'Switch between a grid and a list of sections.';

  @override
  String get guide_thoughts_list_title => 'Your sections';

  @override
  String get guide_thoughts_list_body =>
      'Tap a section to open it, add thoughts, edit them, or swipe a thought to delete it.';

  @override
  String get guide_thoughts_select_title => 'Selecting sections';

  @override
  String get guide_thoughts_select_body =>
      'Long-press a section to select it. The bar at the top lets you rename it, add tags, or delete the selected sections together with their thoughts.';

  @override
  String get guide_tasks_intro_title => 'Tasks';

  @override
  String get guide_tasks_intro_body =>
      'Tasks can be one-time, or periodic so they come back on the days you choose. Here is how this page works.';

  @override
  String get guide_tasks_create_title => 'New task';

  @override
  String get guide_tasks_create_body =>
      'Tap + to open the task editor: set a title, notes, a due date, sub-tasks, or make the task repeat. Tasks are saved when you confirm.';

  @override
  String get guide_tasks_filters_body =>
      'Tap the filter button at the end of the search field. Besides tags and dates, the panel has filters made just for tasks.';

  @override
  String get guide_tasks_views_title => 'Views';

  @override
  String get guide_tasks_views_body =>
      'Switch between unfinished and finished tasks, and use the menu to show all tasks, only one-time tasks, or only periodic tasks.';

  @override
  String get guide_tasks_upcoming_title => 'Upcoming';

  @override
  String get guide_tasks_upcoming_body =>
      'The strip at the top shows what is due soon, so you can check it off without scrolling. It appears in the unfinished view of all tasks.';

  @override
  String get guide_tasks_list_title => 'Your tasks';

  @override
  String get guide_tasks_list_body =>
      'Tap a task to edit it, and use its checkbox to mark it done. Open the arrow on a task to check its sub-tasks without editing; finishing a task does not require its sub-tasks to be checked.';

  @override
  String get guide_tasks_select_title => 'Selecting tasks';

  @override
  String get guide_tasks_select_body =>
      'Long-press a task to select it, then use the bar at the top to act on all selected tasks at once.';

  @override
  String get guide_checklists_intro_title => 'Checklists';

  @override
  String get guide_checklists_intro_body =>
      'Checklists are sections of simple items with just a checkbox: shopping lists, packing lists, anything quick.';

  @override
  String get guide_checklists_create_title => 'New checklist';

  @override
  String get guide_checklists_create_body =>
      'Tap + and name the checklist. It opens right away so you can add items.';

  @override
  String get guide_checklists_completed_title => 'Completed items';

  @override
  String get guide_checklists_completed_body =>
      'Checked items, and checklists with everything checked, are hidden to keep the list short. Turn this on to see them again.';

  @override
  String get guide_checklists_list_title => 'Your checklists';

  @override
  String get guide_checklists_list_body =>
      'Expand a checklist to tick its items right here, or tap it to open and edit it.';

  @override
  String get guide_checklists_select_title => 'Selecting checklists';

  @override
  String get guide_checklists_select_body =>
      'Long-press a checklist to select it. The bar at the top lets you rename it, add tags, or delete the selected checklists together with their items.';

  @override
  String get guide_notes_manage_title => 'Manage groups';

  @override
  String get guide_notes_manage_body =>
      'Create, rename and delete your groups here.';

  @override
  String get guide_tasks_kind_title => 'Type of tasks';

  @override
  String get guide_tasks_kind_body =>
      'Show all tasks, only one-time tasks, or only periodic tasks that repeat.';
}
