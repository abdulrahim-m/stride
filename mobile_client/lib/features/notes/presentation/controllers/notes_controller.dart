import 'package:flutter_rust_bridge/flutter_rust_bridge.dart';
import 'package:mobile_client/core/rust/api/notes.dart';
import 'package:mobile_client/core/rust/dto/note.dart';
import 'package:mobile_client/core/rust/dto/query.dart';
import 'package:mobile_client/shared/controllers/paged_list_controller.dart';
import 'package:mobile_client/shared/widgets/search_filters.dart';

/// The notes list, groups + actions. Paging and selection come from
/// [PagedListController], search / tag / date filters from the app-wide
/// [SearchFilters].
class NotesController extends PagedListController<NoteListItemDto> {
  NotesController({required NotesApi notes, required this.filters})
    : _api = notes {
    filters.queryChanges.addListener(_onQueryChanged);
  }

  final NotesApi _api;
  final SearchFilters filters;

  List<NoteGroupDto> _groups = [];
  int? _selectedGroupId;

  List<NoteListItemDto> get notes => items;
  Set<int> get selectedNoteIds => selectedIds;
  List<NoteGroupDto> get groups => _groups;
  int? get selectedGroupId => _selectedGroupId;
  bool get isSearching => filters.isSearching;

  void _onQueryChanged() => reload();

  @override
  int idOf(NoteListItemDto item) => item.id;

  @override
  Future<List<NoteListItemDto>> fetchPage(ListRequestDto req) {
    if (filters.isSearching) {
      return _api.search(params: filters.toParams(), list: req);
    }
    final group = _selectedGroupId;
    return group == null
        ? _api.getList(req: req)
        : _api.getListInGroup(req: req, groupId: group);
  }

  @override
  List<NoteListItemDto> filterPage(List<NoteListItemDto> raw) {
    final group = _selectedGroupId;
    return (filters.isSearching && group != null)
        ? raw.where((n) => n.groupId == group).toList()
        : raw;
  }

  // -------------------------------------------------------------- loading
  Future<void> loadInitial() async {
    await Future.wait([loadGroups(), filters.loadTags(), reload()]);
  }

  /// Like [loadInitial] but keeps as many pages loaded as before, so the
  /// scroll position survives (used when coming back from the note view).
  @override
  Future<void> refresh() async {
    await Future.wait([
      loadGroups(),
      filters.loadTags(),
      reload(keepPages: true),
    ]);
  }

  Future<void> loadGroups() async {
    final ok = await guard(() async {
      final list = await _api.getGroups();
      list.sort((a, b) => a.placing.compareTo(b.placing));
      _groups = list;
      if (_selectedGroupId != null &&
          !_groups.any((g) => g.id == _selectedGroupId)) {
        _selectedGroupId = null;
      }
    });
    if (ok) notifyListeners();
  }

  void selectGroup(int? id) {
    if (_selectedGroupId == id) return;
    _selectedGroupId = id;
    clearSelection();
    reload();
  }

  // --------------------------------------------------------- note actions
  /// Creates an empty note in the current group, if one is selected.
  Future<NoteDto?> createNote() async {
    NoteDto? created;
    await guard(() async {
      final note = await _api.createNote();
      final group = _selectedGroupId;
      if (group != null) {
        await _api.addToGroup(groupId: group, noteIds: _ids([note.id]));
      }
      created = note;
    });
    return created;
  }

  Future<void> deleteSelected() async {
    final ids = selectedIds.toList();
    if (ids.isEmpty) return;
    await guard(() async {
      for (final id in ids) {
        await _api.deleteNote(id: id);
      }
    });
    clearSelection();
    await Future.wait([reload(keepPages: true), loadGroups()]);
  }

  /// [groupId] == null removes the notes from any group.
  Future<void> moveSelected(int? groupId) async {
    final ids = selectedIds.toList();
    if (ids.isEmpty) return;
    final ok = await guard(
      () => _api.addToGroup(groupId: groupId, noteIds: _ids(ids)),
    );
    if (ok) clearSelection();
    await Future.wait([reload(keepPages: true), loadGroups()]);
  }

  /// Adds [tagIds] to every selected note, keeping the tags they already have,
  /// the API replaces the whole set, so we merge first.
  Future<void> addTagsToSelected(Set<int> tagIds) async {
    if (tagIds.isEmpty || !selecting) return;
    final targets = items.where((n) => selectedIds.contains(n.id)).toList();
    final ok = await guard(() async {
      for (final note in targets) {
        final merged = {...note.tags.map((t) => t.id), ...tagIds};
        if (merged.length == note.tags.length) continue; // nothing new
        await _api.updateTags(noteId: note.id, tagIds: _ids(merged));
      }
    });
    if (ok) clearSelection();
    await reload(keepPages: true);
  }

  // -------------------------------------------------------- group actions
  Future<void> createGroup(String name) async {
    final placing = _groups.isEmpty
        ? 0
        : _groups.map((g) => g.placing).reduce((a, b) => a > b ? a : b) + 1;
    final ok = await guard(
      () => _api.createNoteGroup(name: name.trim(), placing: placing),
    );
    if (ok) await loadGroups();
  }

  Future<void> renameGroup(int id, String name) async {
    final ok = await guard(
      () => _api.updateNoteGroup(id: id, name: name.trim()),
    );
    if (ok) await loadGroups();
  }

  /// Moves a group in the manager's list and saves the new order (the core
  /// rewrites every group's `placing`). Shows the new order at once and
  /// re-reads from the core afterwards, which also undoes it if saving failed.
  Future<void> reorderGroups(int oldIndex, int newIndex) async {
    if (newIndex > oldIndex) newIndex -= 1; // ReorderableListView semantics
    if (oldIndex == newIndex || oldIndex < 0 || oldIndex >= _groups.length) {
      return;
    }
    final list = [..._groups];
    list.insert(newIndex, list.removeAt(oldIndex));
    _groups = list;
    notifyListeners();
    await guard(() => _api.reorderNoteGroups(ids: _ids(list.map((g) => g.id))));
    await loadGroups();
  }

  /// The core refuses with 'Forbidden' if the group still contains notes, the
  /// message is surfaced through [onError].
  Future<void> deleteGroup(int id) async {
    final ok = await guard(() => _api.deleteGroup(id: id));
    if (!ok) return;
    final wasSelected = _selectedGroupId == id;
    if (wasSelected) _selectedGroupId = null;
    await loadGroups();
    if (wasSelected) await reload();
  }

  Int64List _ids(Iterable<int> ids) => Int64List.fromList(ids.toList());

  @override
  void dispose() {
    filters.queryChanges.removeListener(_onQueryChanged);
    super.dispose();
  }
}
