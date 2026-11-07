// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get app_title => 'Stride';

  @override
  String get shell_navBar_note_view => 'ملاحظات';

  @override
  String get shell_navBar_thought_view => 'أفكار';

  @override
  String get shell_navBar_task_view => 'مهام';

  @override
  String get shell_navBar_checklist_view => 'القوائم';

  @override
  String get general_filters => 'التصفية';

  @override
  String get notes_all => 'الكل';

  @override
  String get notes_delete => 'حذف';

  @override
  String get notes_change_group => 'تغيير المجموعة';

  @override
  String get notes_select_group => 'نقل إلى مجموعة';

  @override
  String get notes_empty => 'لا توجد ملاحظات';

  @override
  String get notes_unassigned => 'بدون مجموعة';

  @override
  String notes_selected_count(int count) {
    return 'تم تحديد $count';
  }

  @override
  String get notes_search_hint => 'ابحث في الملاحظات';

  @override
  String get notes_no_results => 'لا توجد ملاحظات مطابقة';

  @override
  String get notes_untitled => 'بدون عنوان';

  @override
  String get notes_new_note => 'ملاحظة جديدة';

  @override
  String get notes_clear_selection => 'إلغاء التحديد';

  @override
  String get notes_clear_filters => 'مسح';

  @override
  String get notes_created_after => 'أُنشئت بعد';

  @override
  String get notes_created_before => 'أُنشئت قبل';

  @override
  String get notes_tags => 'الوسوم';

  @override
  String get notes_tags_empty => 'لا توجد وسوم بعد';

  @override
  String get notes_new_tag => 'وسم جديد';

  @override
  String get notes_add_tag => 'إضافة وسم';

  @override
  String get notes_manage_groups => 'إدارة المجموعات';

  @override
  String get notes_new_group => 'مجموعة جديدة';

  @override
  String get notes_rename_group => 'إعادة تسمية المجموعة';

  @override
  String get notes_group_name => 'اسم المجموعة';

  @override
  String get notes_groups_empty => 'لا توجد مجموعات بعد';

  @override
  String notes_count(int count) {
    return '$count ملاحظات';
  }

  @override
  String get notes_cancel => 'إلغاء';

  @override
  String get notes_save => 'حفظ';

  @override
  String get notes_create => 'إنشاء';

  @override
  String get notes_done => 'تم';

  @override
  String get notes_delete_notes_title => 'حذف الملاحظات؟';

  @override
  String notes_delete_notes_body(int count) {
    return 'سيتم حذف $count من الملاحظات المحددة نهائيًا.';
  }

  @override
  String get notes_delete_group_title => 'حذف المجموعة؟';

  @override
  String notes_delete_group_body(String name) {
    return 'سيتم حذف «$name». لا يمكن حذف مجموعة ما زالت تحتوي على ملاحظات.';
  }

  @override
  String get notes_delete_tag_title => 'حذف الوسم؟';

  @override
  String notes_delete_tag_body(String name) {
    return 'ستتم إزالة «$name» من جميع الملاحظات.';
  }

  @override
  String get note_title_hint => 'العنوان';

  @override
  String get note_content_hint => 'ابدأ الكتابة…';

  @override
  String get note_saved => 'تم الحفظ';

  @override
  String get note_saving => 'جارٍ الحفظ…';

  @override
  String get note_unsaved => 'غير محفوظ';

  @override
  String get note_save_failed => 'لم يتم الحفظ';

  @override
  String get note_leave_failed =>
      'تعذّر حفظ تغييراتك. ارجع مرة أخرى للمغادرة دون حفظ.';

  @override
  String get note_load_failed => 'تعذّر تحميل هذه الملاحظة';

  @override
  String get note_share => 'مشاركة';

  @override
  String get note_delete_title => 'حذف الملاحظة؟';

  @override
  String get note_delete_body => 'سيتم حذف هذه الملاحظة نهائيًا.';

  @override
  String get note_undo => 'تراجع';

  @override
  String get note_redo => 'إعادة';

  @override
  String get note_heading => 'عنوان';

  @override
  String get note_bullet_list => 'قائمة نقطية';

  @override
  String get note_checklist => 'قائمة مهام';

  @override
  String get note_indent => 'زيادة المسافة البادئة';

  @override
  String get note_outdent => 'تقليل المسافة البادئة';

  @override
  String get thoughts_search_hint => 'ابحث في الأفكار';

  @override
  String get thoughts_empty => 'لا توجد أفكار بعد';

  @override
  String get thoughts_new_section => 'قسم جديد';

  @override
  String get thoughts_section_name => 'اسم القسم';

  @override
  String get thoughts_rename_section => 'إعادة تسمية القسم';

  @override
  String thoughts_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count فكرة',
      many: '$count فكرة',
      few: '$count أفكار',
      two: 'فكرتان',
      one: 'فكرة واحدة',
      zero: 'لا أفكار',
    );
    return '$_temp0';
  }

  @override
  String thoughts_delete_title(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'حذف الأقسام؟',
      one: 'حذف القسم؟',
    );
    return '$_temp0';
  }

  @override
  String thoughts_delete_body(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'سيتم حذف $count من الأقسام وجميع أفكارها نهائيًا.',
      one: 'سيتم حذف هذا القسم وجميع أفكاره نهائيًا.',
    );
    return '$_temp0';
  }

  @override
  String get thoughts_new_item_hint => 'أضف فكرة…';

  @override
  String get thoughts_add => 'إضافة';

  @override
  String get thoughts_grid_view => 'عرض شبكي';

  @override
  String get thoughts_list_view => 'عرض قائمة';

  @override
  String get thoughts_load_failed => 'تعذّر تحميل هذا القسم';

  @override
  String get thoughts_section_empty => 'لا شيء هنا بعد. أضف أول فكرة بالأسفل.';

  @override
  String get checklists_search_hint => 'ابحث في القوائم';

  @override
  String get checklists_empty => 'لا توجد قوائم بعد';

  @override
  String get checklists_all_done => 'تم كل شيء! لا يوجد ما تبقى';

  @override
  String get checklists_new_section => 'قائمة جديدة';

  @override
  String get checklists_section_name => 'اسم القائمة';

  @override
  String get checklists_rename_section => 'إعادة تسمية القائمة';

  @override
  String get checklists_show_completed => 'إظهار المكتمل';

  @override
  String checklists_delete_title(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'حذف القوائم؟',
      one: 'حذف القائمة؟',
    );
    return '$_temp0';
  }

  @override
  String checklists_delete_body(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'سيتم حذف $count قوائم وجميع مهامها نهائيًا.',
      one: 'سيتم حذف هذه القائمة وجميع مهامها نهائيًا.',
    );
    return '$_temp0';
  }

  @override
  String get checklists_new_item_hint => 'أضف مهمة…';

  @override
  String get checklists_add => 'إضافة';

  @override
  String get checklists_load_failed => 'تعذر تحميل هذه القائمة';

  @override
  String get checklists_section_empty =>
      'لا توجد مهام بعد. أضف أول مهمة بالأسفل.';

  @override
  String get checklists_no_tasks => 'لا توجد مهام بعد';

  @override
  String get checklists_edit_tasks => 'تعديل القائمة';

  @override
  String get tasks_search_hint => 'ابحث في المهام';

  @override
  String get tasks_new => 'مهمة جديدة';

  @override
  String get tasks_edit => 'تعديل المهمة';

  @override
  String get tasks_empty => 'لا توجد مهام بعد';

  @override
  String get tasks_empty_simple => 'لا توجد مهام لمرة واحدة';

  @override
  String get tasks_empty_periodic => 'لا توجد مهام دورية';

  @override
  String get tasks_upcoming => 'القادم';

  @override
  String get tasks_all => 'كل المهام';

  @override
  String get tasks_view_simple => 'المهام';

  @override
  String get tasks_view_periodic => 'الدورية';

  @override
  String tasks_delete_title(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'حذف المهام؟',
      one: 'حذف المهمة؟',
    );
    return '$_temp0';
  }

  @override
  String tasks_delete_body(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'سيتم حذف $count مهام نهائيًا.',
      one: 'سيتم حذف هذه المهمة نهائيًا.',
    );
    return '$_temp0';
  }

  @override
  String get tasks_title_hint => 'العنوان';

  @override
  String get tasks_description_hint => 'الوصف';

  @override
  String get tasks_title_required => 'أضف عنوانًا للمهمة';

  @override
  String get tasks_load_failed => 'تعذر تحميل هذه المهمة';

  @override
  String get tasks_type => 'النوع';

  @override
  String get tasks_type_one_time => 'لمرة واحدة';

  @override
  String get tasks_type_periodic => 'دورية';

  @override
  String get tasks_priority => 'الأولوية';

  @override
  String get tasks_priority_none => 'بدون';

  @override
  String get tasks_priority_lowest => 'الأدنى';

  @override
  String get tasks_priority_low => 'منخفضة';

  @override
  String get tasks_priority_medium => 'متوسطة';

  @override
  String get tasks_priority_high => 'عالية';

  @override
  String get tasks_priority_highest => 'الأعلى';

  @override
  String get tasks_due_date => 'تاريخ الاستحقاق';

  @override
  String get tasks_no_due_date => 'بدون تاريخ';

  @override
  String get tasks_schedule => 'التكرار';

  @override
  String get tasks_kind_daily => 'كل يوم';

  @override
  String get tasks_kind_every_n_days => 'كل عدد من الأيام';

  @override
  String get tasks_kind_weekly => 'كل أسبوع';

  @override
  String get tasks_kind_monthly => 'كل شهر';

  @override
  String get tasks_kind_yearly => 'كل سنة';

  @override
  String get tasks_field_repeats => 'التكرار';

  @override
  String get tasks_field_days => 'الأيام';

  @override
  String get tasks_field_day_of_week => 'اليوم';

  @override
  String get tasks_field_day_of_month => 'يوم الشهر';

  @override
  String get tasks_field_month => 'الشهر';

  @override
  String get tasks_field_hour => 'الوقت';

  @override
  String tasks_sched_daily(String time) {
    return 'كل يوم عند $time';
  }

  @override
  String tasks_sched_every_n_days(int count, String time) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'كل $count أيام عند $time',
      one: 'كل يوم عند $time',
    );
    return '$_temp0';
  }

  @override
  String tasks_sched_weekly(String day, String time) {
    return 'كل $day عند $time';
  }

  @override
  String tasks_sched_monthly(int day, String time) {
    return 'اليوم $day من كل شهر عند $time';
  }

  @override
  String tasks_sched_yearly(String date, String time) {
    return 'كل سنة في $date عند $time';
  }

  @override
  String get tasks_checklist => 'قائمة التحقق';

  @override
  String get tasks_checklist_add => 'إضافة عنصر';

  @override
  String tasks_checklist_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count عناصر',
      one: 'عنصر واحد',
    );
    return '$_temp0';
  }

  @override
  String get tasks_discard_title => 'تجاهل التغييرات؟';

  @override
  String get tasks_discard_body =>
      'لديك تغييرات غير محفوظة. إذا غادرت الآن فستفقدها.';

  @override
  String get tasks_discard => 'تجاهل';

  @override
  String get tasks_status_unfinished => 'غير المنتهية';

  @override
  String get tasks_status_finished => 'المنتهية';

  @override
  String get tasks_all_types => 'كل الأنواع';

  @override
  String get tasks_empty_finished => 'لا توجد مهام منتهية بعد';

  @override
  String get tasks_due_after => 'الاستحقاق بعد';

  @override
  String get tasks_due_before => 'الاستحقاق قبل';

  @override
  String get settings_title => 'الإعدادات';

  @override
  String get settings_appearance => 'المظهر';

  @override
  String get settings_theme => 'السمة';

  @override
  String get settings_font_size => 'حجم الخط';

  @override
  String get settings_font_preview => 'نص تجريبي لمعاينة حجم الخط';

  @override
  String get settings_general => 'عام';

  @override
  String get settings_language => 'اللغة';

  @override
  String get settings_language_default => 'لغة الجهاز';

  @override
  String get settings_reset_time => 'وقت إعادة التعيين اليومي';

  @override
  String get settings_reset_time_hint =>
      'الساعة التي تُعاد فيها المهام الدورية';

  @override
  String get settings_reset_defaults => 'استعادة الإعدادات الافتراضية';

  @override
  String get settings_reset_title => 'استعادة الإعدادات؟';

  @override
  String get settings_reset_body => 'ستعود كل الإعدادات إلى قيمها الافتراضية.';

  @override
  String get settings_reset_action => 'استعادة';

  @override
  String get guide_tooltip => 'دليل الصفحة';

  @override
  String get guide_next => 'التالي';

  @override
  String get guide_back => 'السابق';

  @override
  String get guide_skip => 'تخطي';

  @override
  String get guide_done => 'تم';

  @override
  String get guide_search_title => 'البحث';

  @override
  String get guide_search_body =>
      'اكتب هنا للبحث. تتحدث القائمة أثناء الكتابة، ويرافقك نفس البحث بين الصفحات.';

  @override
  String get guide_filters_title => 'المرشحات والوسوم (Filters & Tags)';

  @override
  String get guide_filters_body =>
      'اضغط على زر المرشحات (Filters) في نهاية حقل البحث لفتح لوحة المرشحات: صفّ القائمة بالوسوم (Tags) وبالتاريخ. يعرض الرقم على الزر عدد المرشحات المفعّلة.';

  @override
  String get guide_refresh => 'اسحب للأسفل للتحديث.';

  @override
  String get guide_notes_intro_title => 'الملاحظات';

  @override
  String get guide_notes_intro_body =>
      'هنا توجد ملاحظاتك: نصوص أطول يمكنك تنسيقها. إليك جولة سريعة فيما يمكنك فعله في هذه الصفحة.';

  @override
  String get guide_notes_create_title => 'ملاحظة جديدة';

  @override
  String get guide_notes_create_body =>
      'اضغط + لإنشاء ملاحظة والبدء بالكتابة فورًا. تُحفظ الملاحظات تلقائيًا.';

  @override
  String get guide_notes_groups_title => 'المجموعات';

  @override
  String get guide_notes_groups_body =>
      'تُنظَّم الملاحظات في مجموعات. اضغط على مجموعة لعرض ملاحظاتها فقط، أو اختر الأولى لعرض كل شيء. زر الإدارة في نهاية الصف يتيح لك إنشاء المجموعات وإعادة تسميتها وحذفها.';

  @override
  String get guide_notes_list_title => 'ملاحظاتك';

  @override
  String get guide_notes_list_body => 'اضغط على ملاحظة لفتحها وتعديلها.';

  @override
  String get guide_notes_select_title => 'تحديد الملاحظات';

  @override
  String get guide_notes_select_body =>
      'اضغط مطولًا على ملاحظة لتحديدها، ثم اضغط على ملاحظات أخرى لإضافتها. يتيح لك الشريط العلوي إضافة وسوم (Tags) أو نقل الملاحظات المحددة إلى مجموعة أخرى أو حذفها.';

  @override
  String get guide_thoughts_intro_title => 'الأفكار';

  @override
  String get guide_thoughts_intro_body =>
      'الأفكار أقسام يضم كل منها ملاحظات قصيرة من سطر واحد. مناسبة لتدوين الأفكار بسرعة.';

  @override
  String get guide_thoughts_create_title => 'قسم جديد';

  @override
  String get guide_thoughts_create_body =>
      'اضغط + وأعطِ القسم اسمًا. يُفتح فورًا لتبدأ بإضافة الأفكار.';

  @override
  String get guide_thoughts_view_title => 'التخطيط';

  @override
  String get guide_thoughts_view_body =>
      'بدّل بين عرض الأقسام كشبكة أو كقائمة.';

  @override
  String get guide_thoughts_list_title => 'أقسامك';

  @override
  String get guide_thoughts_list_body =>
      'اضغط على قسم لفتحه، وأضف الأفكار وعدّلها، أو اسحب فكرة جانبًا لحذفها.';

  @override
  String get guide_thoughts_select_title => 'تحديد الأقسام';

  @override
  String get guide_thoughts_select_body =>
      'اضغط مطولًا على قسم لتحديده. يتيح لك الشريط العلوي إعادة تسميته أو إضافة وسوم (Tags) أو حذف الأقسام المحددة مع أفكارها.';

  @override
  String get guide_tasks_intro_title => 'المهام';

  @override
  String get guide_tasks_intro_body =>
      'يمكن أن تكون المهام لمرة واحدة، أو دورية تعود في الأيام التي تختارها. إليك طريقة عمل هذه الصفحة.';

  @override
  String get guide_tasks_create_title => 'مهمة جديدة';

  @override
  String get guide_tasks_create_body =>
      'اضغط + لفتح محرر المهام: حدد العنوان والملاحظات وتاريخ الاستحقاق والمهام الفرعية، أو اجعل المهمة تتكرر. تُحفظ المهمة عند التأكيد.';

  @override
  String get guide_tasks_filters_body =>
      'اضغط على زر المرشحات (Filters) في نهاية حقل البحث. إضافةً إلى الوسوم (Tags) والتواريخ، تضم اللوحة مرشحات مخصصة للمهام.';

  @override
  String get guide_tasks_views_title => 'العروض';

  @override
  String get guide_tasks_views_body =>
      'بدّل بين المهام غير المنجزة والمنجزة، واستخدم القائمة لعرض كل المهام أو المهام لمرة واحدة فقط أو الدورية فقط.';

  @override
  String get guide_tasks_upcoming_title => 'القادمة';

  @override
  String get guide_tasks_upcoming_body =>
      'يعرض الشريط العلوي ما يحين موعده قريبًا لتتمكن من إنجازه دون تمرير. يظهر في عرض المهام غير المنجزة لكل المهام.';

  @override
  String get guide_tasks_list_title => 'مهامك';

  @override
  String get guide_tasks_list_body =>
      'اضغط على مهمة لتعديلها، واستخدم مربع الاختيار لتحديدها كمنجزة. افتح السهم في المهمة لتحديد مهامها الفرعية دون فتح التعديل؛ ولا يشترط إنجاز المهام الفرعية لإنجاز المهمة.';

  @override
  String get guide_tasks_select_title => 'تحديد المهام';

  @override
  String get guide_tasks_select_body =>
      'اضغط مطولًا على مهمة لتحديدها، ثم استخدم الشريط العلوي للتصرف في كل المهام المحددة دفعة واحدة.';

  @override
  String get guide_checklists_intro_title => 'قوائم المراجعة';

  @override
  String get guide_checklists_intro_body =>
      'قوائم المراجعة أقسام من عناصر بسيطة بمربع اختيار فقط: قوائم التسوق والسفر وأي شيء سريع.';

  @override
  String get guide_checklists_create_title => 'قائمة جديدة';

  @override
  String get guide_checklists_create_body =>
      'اضغط + وسم (Tag)ِّ القائمة. تُفتح فورًا لتضيف العناصر.';

  @override
  String get guide_checklists_completed_title => 'العناصر المكتملة';

  @override
  String get guide_checklists_completed_body =>
      'تُخفى العناصر المحددة، والقوائم التي اكتملت كلها، لتبقى القائمة قصيرة. فعّل هذا الخيار لإظهارها من جديد.';

  @override
  String get guide_checklists_list_title => 'قوائمك';

  @override
  String get guide_checklists_list_body =>
      'وسّع قائمة لتحديد عناصرها هنا مباشرة، أو اضغط عليها لفتحها وتعديلها.';

  @override
  String get guide_checklists_select_title => 'تحديد القوائم';

  @override
  String get guide_checklists_select_body =>
      'اضغط مطولًا على قائمة لتحديدها. يتيح لك الشريط العلوي إعادة تسميتها أو إضافة وسوم (Tags) أو حذف القوائم المحددة مع عناصرها.';

  @override
  String get guide_notes_manage_title => 'إدارة المجموعات';

  @override
  String get guide_notes_manage_body =>
      'أنشئ مجموعاتك وأعد تسميتها واحذفها من هنا.';

  @override
  String get guide_tasks_kind_title => 'نوع المهام';

  @override
  String get guide_tasks_kind_body =>
      'اعرض كل المهام، أو المهام لمرة واحدة فقط، أو المهام الدورية المتكررة فقط.';
}
