import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @app_title.
  ///
  /// In en, this message translates to:
  /// **'Stride'**
  String get app_title;

  /// No description provided for @shell_navBar_note_view.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get shell_navBar_note_view;

  /// No description provided for @shell_navBar_thought_view.
  ///
  /// In en, this message translates to:
  /// **'Thoughts'**
  String get shell_navBar_thought_view;

  /// No description provided for @shell_navBar_task_view.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get shell_navBar_task_view;

  /// No description provided for @shell_navBar_checklist_view.
  ///
  /// In en, this message translates to:
  /// **'Checklists'**
  String get shell_navBar_checklist_view;

  /// No description provided for @general_filters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get general_filters;

  /// No description provided for @notes_all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get notes_all;

  /// No description provided for @notes_delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get notes_delete;

  /// No description provided for @notes_change_group.
  ///
  /// In en, this message translates to:
  /// **'Change Group'**
  String get notes_change_group;

  /// No description provided for @notes_select_group.
  ///
  /// In en, this message translates to:
  /// **'Move to Group'**
  String get notes_select_group;

  /// No description provided for @notes_empty.
  ///
  /// In en, this message translates to:
  /// **'No notes found'**
  String get notes_empty;

  /// No description provided for @notes_unassigned.
  ///
  /// In en, this message translates to:
  /// **'Unassigned'**
  String get notes_unassigned;

  /// No description provided for @notes_selected_count.
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String notes_selected_count(int count);

  /// No description provided for @notes_search_hint.
  ///
  /// In en, this message translates to:
  /// **'Search notes'**
  String get notes_search_hint;

  /// No description provided for @notes_no_results.
  ///
  /// In en, this message translates to:
  /// **'No matching notes'**
  String get notes_no_results;

  /// No description provided for @notes_untitled.
  ///
  /// In en, this message translates to:
  /// **'Untitled'**
  String get notes_untitled;

  /// No description provided for @notes_new_note.
  ///
  /// In en, this message translates to:
  /// **'New note'**
  String get notes_new_note;

  /// No description provided for @notes_clear_selection.
  ///
  /// In en, this message translates to:
  /// **'Cancel selection'**
  String get notes_clear_selection;

  /// No description provided for @notes_clear_filters.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get notes_clear_filters;

  /// No description provided for @notes_created_after.
  ///
  /// In en, this message translates to:
  /// **'Created after'**
  String get notes_created_after;

  /// No description provided for @notes_created_before.
  ///
  /// In en, this message translates to:
  /// **'Created before'**
  String get notes_created_before;

  /// No description provided for @notes_tags.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get notes_tags;

  /// No description provided for @notes_tags_empty.
  ///
  /// In en, this message translates to:
  /// **'No tags yet'**
  String get notes_tags_empty;

  /// No description provided for @notes_new_tag.
  ///
  /// In en, this message translates to:
  /// **'New tag'**
  String get notes_new_tag;

  /// No description provided for @notes_add_tag.
  ///
  /// In en, this message translates to:
  /// **'Add tag'**
  String get notes_add_tag;

  /// No description provided for @notes_manage_groups.
  ///
  /// In en, this message translates to:
  /// **'Manage groups'**
  String get notes_manage_groups;

  /// No description provided for @notes_new_group.
  ///
  /// In en, this message translates to:
  /// **'New group'**
  String get notes_new_group;

  /// No description provided for @notes_rename_group.
  ///
  /// In en, this message translates to:
  /// **'Rename group'**
  String get notes_rename_group;

  /// No description provided for @notes_group_name.
  ///
  /// In en, this message translates to:
  /// **'Group name'**
  String get notes_group_name;

  /// No description provided for @notes_groups_empty.
  ///
  /// In en, this message translates to:
  /// **'No groups yet'**
  String get notes_groups_empty;

  /// No description provided for @notes_count.
  ///
  /// In en, this message translates to:
  /// **'{count} notes'**
  String notes_count(int count);

  /// No description provided for @notes_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get notes_cancel;

  /// No description provided for @notes_save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get notes_save;

  /// No description provided for @notes_create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get notes_create;

  /// No description provided for @notes_done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get notes_done;

  /// No description provided for @notes_delete_notes_title.
  ///
  /// In en, this message translates to:
  /// **'Delete notes?'**
  String get notes_delete_notes_title;

  /// No description provided for @notes_delete_notes_body.
  ///
  /// In en, this message translates to:
  /// **'{count} selected notes will be permanently deleted.'**
  String notes_delete_notes_body(int count);

  /// No description provided for @notes_delete_group_title.
  ///
  /// In en, this message translates to:
  /// **'Delete group?'**
  String get notes_delete_group_title;

  /// No description provided for @notes_delete_group_body.
  ///
  /// In en, this message translates to:
  /// **'“{name}” will be deleted. A group that still contains notes can\'t be deleted.'**
  String notes_delete_group_body(String name);

  /// No description provided for @notes_delete_tag_title.
  ///
  /// In en, this message translates to:
  /// **'Delete tag?'**
  String get notes_delete_tag_title;

  /// No description provided for @notes_delete_tag_body.
  ///
  /// In en, this message translates to:
  /// **'“{name}” will be removed from all notes.'**
  String notes_delete_tag_body(String name);

  /// No description provided for @note_title_hint.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get note_title_hint;

  /// No description provided for @note_content_hint.
  ///
  /// In en, this message translates to:
  /// **'Start writing…'**
  String get note_content_hint;

  /// No description provided for @note_saved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get note_saved;

  /// No description provided for @note_saving.
  ///
  /// In en, this message translates to:
  /// **'Saving…'**
  String get note_saving;

  /// No description provided for @note_unsaved.
  ///
  /// In en, this message translates to:
  /// **'Unsaved'**
  String get note_unsaved;

  /// No description provided for @note_save_failed.
  ///
  /// In en, this message translates to:
  /// **'Not saved'**
  String get note_save_failed;

  /// No description provided for @note_leave_failed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save your changes. Go back again to leave without saving.'**
  String get note_leave_failed;

  /// No description provided for @note_load_failed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load this note'**
  String get note_load_failed;

  /// No description provided for @note_share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get note_share;

  /// No description provided for @note_delete_title.
  ///
  /// In en, this message translates to:
  /// **'Delete note?'**
  String get note_delete_title;

  /// No description provided for @note_delete_body.
  ///
  /// In en, this message translates to:
  /// **'This note will be permanently deleted.'**
  String get note_delete_body;

  /// No description provided for @note_undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get note_undo;

  /// No description provided for @note_redo.
  ///
  /// In en, this message translates to:
  /// **'Redo'**
  String get note_redo;

  /// No description provided for @note_heading.
  ///
  /// In en, this message translates to:
  /// **'Heading'**
  String get note_heading;

  /// No description provided for @note_bullet_list.
  ///
  /// In en, this message translates to:
  /// **'Bullet list'**
  String get note_bullet_list;

  /// No description provided for @note_checklist.
  ///
  /// In en, this message translates to:
  /// **'Checklist'**
  String get note_checklist;

  /// No description provided for @note_indent.
  ///
  /// In en, this message translates to:
  /// **'Indent'**
  String get note_indent;

  /// No description provided for @note_outdent.
  ///
  /// In en, this message translates to:
  /// **'Outdent'**
  String get note_outdent;

  /// No description provided for @thoughts_search_hint.
  ///
  /// In en, this message translates to:
  /// **'Search thoughts'**
  String get thoughts_search_hint;

  /// No description provided for @thoughts_empty.
  ///
  /// In en, this message translates to:
  /// **'No thoughts yet'**
  String get thoughts_empty;

  /// No description provided for @thoughts_new_section.
  ///
  /// In en, this message translates to:
  /// **'New section'**
  String get thoughts_new_section;

  /// No description provided for @thoughts_section_name.
  ///
  /// In en, this message translates to:
  /// **'Section name'**
  String get thoughts_section_name;

  /// No description provided for @thoughts_rename_section.
  ///
  /// In en, this message translates to:
  /// **'Rename section'**
  String get thoughts_rename_section;

  /// No description provided for @thoughts_count.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No thoughts} =1{1 thought} other{{count} thoughts}}'**
  String thoughts_count(int count);

  /// No description provided for @thoughts_delete_title.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Delete section?} other{Delete sections?}}'**
  String thoughts_delete_title(int count);

  /// No description provided for @thoughts_delete_body.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{This section and all its thoughts will be permanently deleted.} other{{count} sections and all their thoughts will be permanently deleted.}}'**
  String thoughts_delete_body(int count);

  /// No description provided for @thoughts_new_item_hint.
  ///
  /// In en, this message translates to:
  /// **'Add a thought…'**
  String get thoughts_new_item_hint;

  /// No description provided for @thoughts_add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get thoughts_add;

  /// No description provided for @thoughts_grid_view.
  ///
  /// In en, this message translates to:
  /// **'Grid view'**
  String get thoughts_grid_view;

  /// No description provided for @thoughts_list_view.
  ///
  /// In en, this message translates to:
  /// **'List view'**
  String get thoughts_list_view;

  /// No description provided for @thoughts_load_failed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load this section'**
  String get thoughts_load_failed;

  /// No description provided for @thoughts_section_empty.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet. Add your first thought below.'**
  String get thoughts_section_empty;

  /// No description provided for @checklists_search_hint.
  ///
  /// In en, this message translates to:
  /// **'Search checklists'**
  String get checklists_search_hint;

  /// No description provided for @checklists_empty.
  ///
  /// In en, this message translates to:
  /// **'No checklists yet'**
  String get checklists_empty;

  /// No description provided for @checklists_all_done.
  ///
  /// In en, this message translates to:
  /// **'All done! Nothing left to do'**
  String get checklists_all_done;

  /// No description provided for @checklists_new_section.
  ///
  /// In en, this message translates to:
  /// **'New checklist'**
  String get checklists_new_section;

  /// No description provided for @checklists_section_name.
  ///
  /// In en, this message translates to:
  /// **'Checklist name'**
  String get checklists_section_name;

  /// No description provided for @checklists_rename_section.
  ///
  /// In en, this message translates to:
  /// **'Rename checklist'**
  String get checklists_rename_section;

  /// No description provided for @checklists_show_completed.
  ///
  /// In en, this message translates to:
  /// **'Show completed'**
  String get checklists_show_completed;

  /// No description provided for @checklists_delete_title.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Delete checklist?} other{Delete checklists?}}'**
  String checklists_delete_title(int count);

  /// No description provided for @checklists_delete_body.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{This checklist and all its tasks will be permanently deleted.} other{{count} checklists and all their tasks will be permanently deleted.}}'**
  String checklists_delete_body(int count);

  /// No description provided for @checklists_new_item_hint.
  ///
  /// In en, this message translates to:
  /// **'Add a task…'**
  String get checklists_new_item_hint;

  /// No description provided for @checklists_add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get checklists_add;

  /// No description provided for @checklists_load_failed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load this checklist'**
  String get checklists_load_failed;

  /// No description provided for @checklists_section_empty.
  ///
  /// In en, this message translates to:
  /// **'No tasks yet. Add your first task below.'**
  String get checklists_section_empty;

  /// No description provided for @checklists_no_tasks.
  ///
  /// In en, this message translates to:
  /// **'No tasks yet'**
  String get checklists_no_tasks;

  /// No description provided for @checklists_edit_tasks.
  ///
  /// In en, this message translates to:
  /// **'Edit checklist'**
  String get checklists_edit_tasks;

  /// No description provided for @tasks_search_hint.
  ///
  /// In en, this message translates to:
  /// **'Search tasks'**
  String get tasks_search_hint;

  /// No description provided for @tasks_new.
  ///
  /// In en, this message translates to:
  /// **'New task'**
  String get tasks_new;

  /// No description provided for @tasks_edit.
  ///
  /// In en, this message translates to:
  /// **'Edit task'**
  String get tasks_edit;

  /// No description provided for @tasks_empty.
  ///
  /// In en, this message translates to:
  /// **'No tasks yet'**
  String get tasks_empty;

  /// No description provided for @tasks_empty_simple.
  ///
  /// In en, this message translates to:
  /// **'No one-time tasks'**
  String get tasks_empty_simple;

  /// No description provided for @tasks_empty_periodic.
  ///
  /// In en, this message translates to:
  /// **'No periodic tasks'**
  String get tasks_empty_periodic;

  /// No description provided for @tasks_upcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get tasks_upcoming;

  /// No description provided for @tasks_all.
  ///
  /// In en, this message translates to:
  /// **'All tasks'**
  String get tasks_all;

  /// No description provided for @tasks_view_simple.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get tasks_view_simple;

  /// No description provided for @tasks_view_periodic.
  ///
  /// In en, this message translates to:
  /// **'Periodic'**
  String get tasks_view_periodic;

  /// No description provided for @tasks_delete_title.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Delete task?} other{Delete tasks?}}'**
  String tasks_delete_title(int count);

  /// No description provided for @tasks_delete_body.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{This task will be permanently deleted.} other{{count} tasks will be permanently deleted.}}'**
  String tasks_delete_body(int count);

  /// No description provided for @tasks_title_hint.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get tasks_title_hint;

  /// No description provided for @tasks_description_hint.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get tasks_description_hint;

  /// No description provided for @tasks_title_required.
  ///
  /// In en, this message translates to:
  /// **'Give the task a title'**
  String get tasks_title_required;

  /// No description provided for @tasks_load_failed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load this task'**
  String get tasks_load_failed;

  /// No description provided for @tasks_type.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get tasks_type;

  /// No description provided for @tasks_type_one_time.
  ///
  /// In en, this message translates to:
  /// **'One-time'**
  String get tasks_type_one_time;

  /// No description provided for @tasks_type_periodic.
  ///
  /// In en, this message translates to:
  /// **'Periodic'**
  String get tasks_type_periodic;

  /// No description provided for @tasks_priority.
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get tasks_priority;

  /// No description provided for @tasks_priority_none.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get tasks_priority_none;

  /// No description provided for @tasks_priority_lowest.
  ///
  /// In en, this message translates to:
  /// **'Lowest'**
  String get tasks_priority_lowest;

  /// No description provided for @tasks_priority_low.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get tasks_priority_low;

  /// No description provided for @tasks_priority_medium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get tasks_priority_medium;

  /// No description provided for @tasks_priority_high.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get tasks_priority_high;

  /// No description provided for @tasks_priority_highest.
  ///
  /// In en, this message translates to:
  /// **'Highest'**
  String get tasks_priority_highest;

  /// No description provided for @tasks_due_date.
  ///
  /// In en, this message translates to:
  /// **'Due date'**
  String get tasks_due_date;

  /// No description provided for @tasks_no_due_date.
  ///
  /// In en, this message translates to:
  /// **'No due date'**
  String get tasks_no_due_date;

  /// No description provided for @tasks_schedule.
  ///
  /// In en, this message translates to:
  /// **'Repeats'**
  String get tasks_schedule;

  /// No description provided for @tasks_kind_daily.
  ///
  /// In en, this message translates to:
  /// **'Every day'**
  String get tasks_kind_daily;

  /// No description provided for @tasks_kind_every_n_days.
  ///
  /// In en, this message translates to:
  /// **'Every N days'**
  String get tasks_kind_every_n_days;

  /// No description provided for @tasks_kind_weekly.
  ///
  /// In en, this message translates to:
  /// **'Every week'**
  String get tasks_kind_weekly;

  /// No description provided for @tasks_kind_monthly.
  ///
  /// In en, this message translates to:
  /// **'Every month'**
  String get tasks_kind_monthly;

  /// No description provided for @tasks_kind_yearly.
  ///
  /// In en, this message translates to:
  /// **'Every year'**
  String get tasks_kind_yearly;

  /// No description provided for @tasks_field_repeats.
  ///
  /// In en, this message translates to:
  /// **'Repeats'**
  String get tasks_field_repeats;

  /// No description provided for @tasks_field_days.
  ///
  /// In en, this message translates to:
  /// **'Days'**
  String get tasks_field_days;

  /// No description provided for @tasks_field_day_of_week.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get tasks_field_day_of_week;

  /// No description provided for @tasks_field_day_of_month.
  ///
  /// In en, this message translates to:
  /// **'Day of month'**
  String get tasks_field_day_of_month;

  /// No description provided for @tasks_field_month.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get tasks_field_month;

  /// No description provided for @tasks_field_hour.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get tasks_field_hour;

  /// No description provided for @tasks_sched_daily.
  ///
  /// In en, this message translates to:
  /// **'Every day at {time}'**
  String tasks_sched_daily(String time);

  /// No description provided for @tasks_sched_every_n_days.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Every day at {time}} other{Every {count} days at {time}}}'**
  String tasks_sched_every_n_days(int count, String time);

  /// No description provided for @tasks_sched_weekly.
  ///
  /// In en, this message translates to:
  /// **'Every {day} at {time}'**
  String tasks_sched_weekly(String day, String time);

  /// No description provided for @tasks_sched_monthly.
  ///
  /// In en, this message translates to:
  /// **'Day {day} of every month at {time}'**
  String tasks_sched_monthly(int day, String time);

  /// No description provided for @tasks_sched_yearly.
  ///
  /// In en, this message translates to:
  /// **'Every {date} at {time}'**
  String tasks_sched_yearly(String date, String time);

  /// No description provided for @tasks_checklist.
  ///
  /// In en, this message translates to:
  /// **'Checklist'**
  String get tasks_checklist;

  /// No description provided for @tasks_checklist_add.
  ///
  /// In en, this message translates to:
  /// **'Add item'**
  String get tasks_checklist_add;

  /// No description provided for @tasks_checklist_count.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 item} other{{count} items}}'**
  String tasks_checklist_count(int count);

  /// No description provided for @tasks_discard_title.
  ///
  /// In en, this message translates to:
  /// **'Discard changes?'**
  String get tasks_discard_title;

  /// No description provided for @tasks_discard_body.
  ///
  /// In en, this message translates to:
  /// **'You have unsaved changes. If you leave now, they will be lost.'**
  String get tasks_discard_body;

  /// No description provided for @tasks_discard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get tasks_discard;

  /// No description provided for @tasks_status_unfinished.
  ///
  /// In en, this message translates to:
  /// **'Unfinished'**
  String get tasks_status_unfinished;

  /// No description provided for @tasks_status_finished.
  ///
  /// In en, this message translates to:
  /// **'Finished'**
  String get tasks_status_finished;

  /// No description provided for @tasks_all_types.
  ///
  /// In en, this message translates to:
  /// **'All types'**
  String get tasks_all_types;

  /// No description provided for @tasks_empty_finished.
  ///
  /// In en, this message translates to:
  /// **'No finished tasks yet'**
  String get tasks_empty_finished;

  /// No description provided for @tasks_due_after.
  ///
  /// In en, this message translates to:
  /// **'Due after'**
  String get tasks_due_after;

  /// No description provided for @tasks_due_before.
  ///
  /// In en, this message translates to:
  /// **'Due before'**
  String get tasks_due_before;

  /// No description provided for @settings_title.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings_title;

  /// No description provided for @settings_appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settings_appearance;

  /// No description provided for @settings_theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settings_theme;

  /// No description provided for @settings_font_size.
  ///
  /// In en, this message translates to:
  /// **'Font size'**
  String get settings_font_size;

  /// No description provided for @settings_font_preview.
  ///
  /// In en, this message translates to:
  /// **'The quick brown fox jumps over the lazy dog'**
  String get settings_font_preview;

  /// No description provided for @settings_general.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get settings_general;

  /// No description provided for @settings_language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settings_language;

  /// No description provided for @settings_language_default.
  ///
  /// In en, this message translates to:
  /// **'Device default'**
  String get settings_language_default;

  /// No description provided for @settings_reset_time.
  ///
  /// In en, this message translates to:
  /// **'Daily reset time'**
  String get settings_reset_time;

  /// No description provided for @settings_reset_time_hint.
  ///
  /// In en, this message translates to:
  /// **'Hour at which periodic tasks reset'**
  String get settings_reset_time_hint;

  /// No description provided for @settings_reset_defaults.
  ///
  /// In en, this message translates to:
  /// **'Reset to defaults'**
  String get settings_reset_defaults;

  /// No description provided for @settings_reset_title.
  ///
  /// In en, this message translates to:
  /// **'Reset settings?'**
  String get settings_reset_title;

  /// No description provided for @settings_reset_body.
  ///
  /// In en, this message translates to:
  /// **'All settings return to their default values.'**
  String get settings_reset_body;

  /// No description provided for @settings_reset_action.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get settings_reset_action;

  /// No description provided for @guide_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Page guide'**
  String get guide_tooltip;

  /// No description provided for @guide_next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get guide_next;

  /// No description provided for @guide_back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get guide_back;

  /// No description provided for @guide_skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get guide_skip;

  /// No description provided for @guide_done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get guide_done;

  /// No description provided for @guide_search_title.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get guide_search_title;

  /// No description provided for @guide_search_body.
  ///
  /// In en, this message translates to:
  /// **'Type here to search. The list updates as you type, and the same search follows you between pages.'**
  String get guide_search_body;

  /// No description provided for @guide_filters_title.
  ///
  /// In en, this message translates to:
  /// **'Filters and tags'**
  String get guide_filters_title;

  /// No description provided for @guide_filters_body.
  ///
  /// In en, this message translates to:
  /// **'Tap the filter button at the end of the search field to open the filter panel: narrow the list by tags and by date. A number on the button shows how many filters are active.'**
  String get guide_filters_body;

  /// No description provided for @guide_refresh.
  ///
  /// In en, this message translates to:
  /// **'Pull down to refresh.'**
  String get guide_refresh;

  /// No description provided for @guide_notes_intro_title.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get guide_notes_intro_title;

  /// No description provided for @guide_notes_intro_body.
  ///
  /// In en, this message translates to:
  /// **'This is where your notes live: longer text you can format. Here is a quick tour of what you can do on this page.'**
  String get guide_notes_intro_body;

  /// No description provided for @guide_notes_create_title.
  ///
  /// In en, this message translates to:
  /// **'New note'**
  String get guide_notes_create_title;

  /// No description provided for @guide_notes_create_body.
  ///
  /// In en, this message translates to:
  /// **'Tap + to create a note and start writing right away. Notes save automatically.'**
  String get guide_notes_create_body;

  /// No description provided for @guide_notes_groups_title.
  ///
  /// In en, this message translates to:
  /// **'Groups'**
  String get guide_notes_groups_title;

  /// No description provided for @guide_notes_groups_body.
  ///
  /// In en, this message translates to:
  /// **'Notes are organized in groups. Tap a group to see only its notes, or pick the first one to see everything. The manage button at the end of the row lets you create, rename and delete groups.'**
  String get guide_notes_groups_body;

  /// No description provided for @guide_notes_list_title.
  ///
  /// In en, this message translates to:
  /// **'Your notes'**
  String get guide_notes_list_title;

  /// No description provided for @guide_notes_list_body.
  ///
  /// In en, this message translates to:
  /// **'Tap a note to open and edit it.'**
  String get guide_notes_list_body;

  /// No description provided for @guide_notes_select_title.
  ///
  /// In en, this message translates to:
  /// **'Selecting notes'**
  String get guide_notes_select_title;

  /// No description provided for @guide_notes_select_body.
  ///
  /// In en, this message translates to:
  /// **'Long-press a note to select it, then tap more notes to add them. The bar at the top lets you add tags, move the selected notes to another group, or delete them.'**
  String get guide_notes_select_body;

  /// No description provided for @guide_thoughts_intro_title.
  ///
  /// In en, this message translates to:
  /// **'Thoughts'**
  String get guide_thoughts_intro_title;

  /// No description provided for @guide_thoughts_intro_body.
  ///
  /// In en, this message translates to:
  /// **'Thoughts are sections that each hold short one-line notes. Perfect for ideas you want to jot down fast.'**
  String get guide_thoughts_intro_body;

  /// No description provided for @guide_thoughts_create_title.
  ///
  /// In en, this message translates to:
  /// **'New section'**
  String get guide_thoughts_create_title;

  /// No description provided for @guide_thoughts_create_body.
  ///
  /// In en, this message translates to:
  /// **'Tap + and give the section a name. It opens right away so you can start adding thoughts.'**
  String get guide_thoughts_create_body;

  /// No description provided for @guide_thoughts_view_title.
  ///
  /// In en, this message translates to:
  /// **'Layout'**
  String get guide_thoughts_view_title;

  /// No description provided for @guide_thoughts_view_body.
  ///
  /// In en, this message translates to:
  /// **'Switch between a grid and a list of sections.'**
  String get guide_thoughts_view_body;

  /// No description provided for @guide_thoughts_list_title.
  ///
  /// In en, this message translates to:
  /// **'Your sections'**
  String get guide_thoughts_list_title;

  /// No description provided for @guide_thoughts_list_body.
  ///
  /// In en, this message translates to:
  /// **'Tap a section to open it, add thoughts, edit them, or swipe a thought to delete it.'**
  String get guide_thoughts_list_body;

  /// No description provided for @guide_thoughts_select_title.
  ///
  /// In en, this message translates to:
  /// **'Selecting sections'**
  String get guide_thoughts_select_title;

  /// No description provided for @guide_thoughts_select_body.
  ///
  /// In en, this message translates to:
  /// **'Long-press a section to select it. The bar at the top lets you rename it, add tags, or delete the selected sections together with their thoughts.'**
  String get guide_thoughts_select_body;

  /// No description provided for @guide_tasks_intro_title.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get guide_tasks_intro_title;

  /// No description provided for @guide_tasks_intro_body.
  ///
  /// In en, this message translates to:
  /// **'Tasks can be one-time, or periodic so they come back on the days you choose. Here is how this page works.'**
  String get guide_tasks_intro_body;

  /// No description provided for @guide_tasks_create_title.
  ///
  /// In en, this message translates to:
  /// **'New task'**
  String get guide_tasks_create_title;

  /// No description provided for @guide_tasks_create_body.
  ///
  /// In en, this message translates to:
  /// **'Tap + to open the task editor: set a title, notes, a due date, sub-tasks, or make the task repeat. Tasks are saved when you confirm.'**
  String get guide_tasks_create_body;

  /// No description provided for @guide_tasks_filters_body.
  ///
  /// In en, this message translates to:
  /// **'Tap the filter button at the end of the search field. Besides tags and dates, the panel has filters made just for tasks.'**
  String get guide_tasks_filters_body;

  /// No description provided for @guide_tasks_views_title.
  ///
  /// In en, this message translates to:
  /// **'Views'**
  String get guide_tasks_views_title;

  /// No description provided for @guide_tasks_views_body.
  ///
  /// In en, this message translates to:
  /// **'Switch between unfinished and finished tasks, and use the menu to show all tasks, only one-time tasks, or only periodic tasks.'**
  String get guide_tasks_views_body;

  /// No description provided for @guide_tasks_upcoming_title.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get guide_tasks_upcoming_title;

  /// No description provided for @guide_tasks_upcoming_body.
  ///
  /// In en, this message translates to:
  /// **'The strip at the top shows what is due soon, so you can check it off without scrolling. It appears in the unfinished view of all tasks.'**
  String get guide_tasks_upcoming_body;

  /// No description provided for @guide_tasks_list_title.
  ///
  /// In en, this message translates to:
  /// **'Your tasks'**
  String get guide_tasks_list_title;

  /// No description provided for @guide_tasks_list_body.
  ///
  /// In en, this message translates to:
  /// **'Tap a task to edit it, and use its checkbox to mark it done. Open the arrow on a task to check its sub-tasks without editing; finishing a task does not require its sub-tasks to be checked.'**
  String get guide_tasks_list_body;

  /// No description provided for @guide_tasks_select_title.
  ///
  /// In en, this message translates to:
  /// **'Selecting tasks'**
  String get guide_tasks_select_title;

  /// No description provided for @guide_tasks_select_body.
  ///
  /// In en, this message translates to:
  /// **'Long-press a task to select it, then use the bar at the top to act on all selected tasks at once.'**
  String get guide_tasks_select_body;

  /// No description provided for @guide_checklists_intro_title.
  ///
  /// In en, this message translates to:
  /// **'Checklists'**
  String get guide_checklists_intro_title;

  /// No description provided for @guide_checklists_intro_body.
  ///
  /// In en, this message translates to:
  /// **'Checklists are sections of simple items with just a checkbox: shopping lists, packing lists, anything quick.'**
  String get guide_checklists_intro_body;

  /// No description provided for @guide_checklists_create_title.
  ///
  /// In en, this message translates to:
  /// **'New checklist'**
  String get guide_checklists_create_title;

  /// No description provided for @guide_checklists_create_body.
  ///
  /// In en, this message translates to:
  /// **'Tap + and name the checklist. It opens right away so you can add items.'**
  String get guide_checklists_create_body;

  /// No description provided for @guide_checklists_completed_title.
  ///
  /// In en, this message translates to:
  /// **'Completed items'**
  String get guide_checklists_completed_title;

  /// No description provided for @guide_checklists_completed_body.
  ///
  /// In en, this message translates to:
  /// **'Checked items, and checklists with everything checked, are hidden to keep the list short. Turn this on to see them again.'**
  String get guide_checklists_completed_body;

  /// No description provided for @guide_checklists_list_title.
  ///
  /// In en, this message translates to:
  /// **'Your checklists'**
  String get guide_checklists_list_title;

  /// No description provided for @guide_checklists_list_body.
  ///
  /// In en, this message translates to:
  /// **'Expand a checklist to tick its items right here, or tap it to open and edit it.'**
  String get guide_checklists_list_body;

  /// No description provided for @guide_checklists_select_title.
  ///
  /// In en, this message translates to:
  /// **'Selecting checklists'**
  String get guide_checklists_select_title;

  /// No description provided for @guide_checklists_select_body.
  ///
  /// In en, this message translates to:
  /// **'Long-press a checklist to select it. The bar at the top lets you rename it, add tags, or delete the selected checklists together with their items.'**
  String get guide_checklists_select_body;

  /// No description provided for @guide_notes_manage_title.
  ///
  /// In en, this message translates to:
  /// **'Manage groups'**
  String get guide_notes_manage_title;

  /// No description provided for @guide_notes_manage_body.
  ///
  /// In en, this message translates to:
  /// **'Create, rename and delete your groups here.'**
  String get guide_notes_manage_body;

  /// No description provided for @guide_tasks_kind_title.
  ///
  /// In en, this message translates to:
  /// **'Type of tasks'**
  String get guide_tasks_kind_title;

  /// No description provided for @guide_tasks_kind_body.
  ///
  /// In en, this message translates to:
  /// **'Show all tasks, only one-time tasks, or only periodic tasks that repeat.'**
  String get guide_tasks_kind_body;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
