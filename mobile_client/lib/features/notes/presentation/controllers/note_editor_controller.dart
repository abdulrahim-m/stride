import 'dart:async';
import 'package:flutter_rust_bridge/flutter_rust_bridge.dart'; 

import 'package:flutter/foundation.dart';
import 'package:mobile_client/core/rust/api/images.dart';
import 'package:mobile_client/core/rust/api/notes.dart';
import 'package:mobile_client/core/rust/api/tags.dart';
import 'package:mobile_client/core/rust/dto/image.dart';
import 'package:mobile_client/core/rust/dto/note.dart';
import 'package:mobile_client/core/rust/dto/tag.dart';
import 'package:mobile_client/core/rust/error.dart';
import 'package:mobile_client/features/notes/presentation/markdown/markdown_editing.dart';

enum SaveStatus { saved, pending, saving, error }

/// Loads one note and keeps it saved: edits are written to the core after a
/// short pause, one write at a time, and [flush] forces any pending write.
class NoteEditorController extends ChangeNotifier {
  NoteEditorController({
    required this.noteId,
    required NotesApi notes,
    required TagsApi tags,
    required ImagesApi images,
  }) : _notesApi = notes,
       _tagsApi = tags,
       _imagesApi = images;

  static const _placeholderTitle = 'untitled';
  static const _debounceDelay = Duration(milliseconds: 800);

  final int noteId;
  final NotesApi _notesApi;
  final TagsApi _tagsApi;
  final ImagesApi _imagesApi;

  void Function(String message)? onError;

  // ---------------------------------------------------------------- state
  bool _loading = true;
  bool _loadFailed = false;
  bool _isFresh = false;
  int? _groupId;
  List<TagDto> _tags = [];
  List<NoteGroupDto> _groups = [];
  List<TagDto> _allTags = [];
  List<ImageDto> _images = [];

  String _initialTitle = '';
  String _initialContent = '';

  String _title = '';
  String _content = '';
  String _savedTitle = '';
  String _savedContent = '';

  SaveStatus _status = SaveStatus.saved;
  Timer? _debounce;
  Future<bool> _chain = Future.value(true);
  bool _deleted = false;
  bool _disposed = false;

  bool get loading => _loading;
  bool get loadFailed => _loadFailed;

  bool get isFresh => _isFresh;
  int? get groupId => _groupId;
  List<TagDto> get tags => _tags;
  List<TagDto> get allTags => _allTags;
  List<NoteGroupDto> get groups => _groups;

  /// The note's images (files, then links), kept by the core.
  List<ImageDto> get images => _images;
  SaveStatus get status => _status;

  String get initialTitle => _initialTitle;

  String get initialContent => _initialContent;

  bool get _dirty => _title != _savedTitle || _content != _savedContent;

  // -------------------------------------------------------------- loading
  Future<void> load() async {
    try {
      final note = await _notesApi.getNote(id: noteId);
      _groupId = note.groupId;
      _tags = [...note.tags];

      final shownTitle = note.title.trim().toLowerCase() == _placeholderTitle
          ? ''
          : note.title;
      _initialTitle = shownTitle;
      _initialContent = note.content;
      _isFresh = shownTitle.isEmpty && note.content.trim().isEmpty;

      _title = _savedTitle = shownTitle;
      _content = _savedContent = MarkdownCodec.toMarkdown(
        MarkdownCodec.fromMarkdown(note.content),
      );
    } catch (e) {
      _loadFailed = true;
      _report(e);
    }

    if (!_loadFailed) {
      try {
        final groups = await _notesApi.getGroups();
        groups.sort((a, b) => a.placing.compareTo(b.placing));
        _groups = groups;
        _allTags = await _tagsApi.getList();
        _images = await _imagesApi.list(
          owner: ImageOwnerDto.note,
          ownerId: noteId,
        );
      } catch (e) {
        _report(e);
      }
    }
    _loading = false;
    _notify();
  }

  // --------------------------------------------------------------- saving
  void edit({required String title, required String content}) {
    if (_deleted || (title == _title && content == _content)) return;
    _title = title;
    _content = content;
    _debounce?.cancel();
    if (_dirty) {
      _setStatus(SaveStatus.pending);
      _debounce = Timer(_debounceDelay, _persist);
    } else {
      _setStatus(SaveStatus.saved);
    }
  }

  Future<bool> flush() {
    _debounce?.cancel();
    return _persist();
  }

  Future<bool> _persist() => _chain = _chain.then((_) => _writeIfDirty());

  Future<bool> _writeIfDirty() async {
    if (_deleted || !_dirty) return true;
    final title = _title;
    final content = _content;
    _setStatus(SaveStatus.saving);
    try {
      await _notesApi.updateNote(
        id: noteId,
        title: title.trim().isEmpty ? _placeholderTitle : title.trim(),
        content: content,
      );
      _savedTitle = title;
      _savedContent = content;
      if (_dirty) {
        _setStatus(SaveStatus.pending);
        if (!_disposed) {
          _debounce?.cancel();
          _debounce = Timer(_debounceDelay, _persist);
        }
      } else {
        _setStatus(SaveStatus.saved);
      }
      return true;
    } catch (e) {
      _setStatus(SaveStatus.error);
      _report(e);
      return false;
    }
  }

  // ----------------------------------------------------------- note actions
  Future<bool> delete() async {
    _debounce?.cancel();
    _deleted = true;
    await _chain;
    try {
      await _notesApi.deleteNote(id: noteId);
      return true;
    } catch (e) {
      _deleted = false;
      _report(e);
      return false;
    }
  }

  Future<void> moveToGroup(int? id) async {
    final ok = await _guard(
      () => _notesApi.addToGroup(
        groupId: id,
        noteIds: Int64List.fromList([noteId]),
      ),
    );
    if (ok) {
      _groupId = id;
      _notify();
    }
  }

  Future<void> setTags(Set<int> ids) async {
    final ok = await _guard(
      () => _notesApi.updateTags(
        noteId: noteId,
        tagIds: Int64List.fromList(ids.toList()),
      ),
    );
    if (ok) {
      _tags = _allTags.where((t) => ids.contains(t.id)).toList();
      _notify();
    }
  }

  Future<TagDto?> createTag(String name) async {
    TagDto? created;
    final ok = await _guard(() async {
      created = await _tagsApi.createTag(name: name.trim());
      _allTags = await _tagsApi.getList();
    });
    if (ok) _notify();
    return created;
  }

  // --------------------------------------------------------------- images
  Future<void> addImagesFromPaths(List<String> paths) async {
    await _guard(() async {
      for (final path in paths) {
        await _imagesApi.addFromPath(
          owner: ImageOwnerDto.note,
          ownerId: noteId,
          path: path,
        );
      }
    });
    // Reload even after a failure, earlier files of the batch may be in.
    await _reloadImages();
  }

  Future<void> addImageLink(String url) async {
    final ok = await _guard(
      () => _imagesApi.addLink(
        owner: ImageOwnerDto.note,
        ownerId: noteId,
        url: url,
      ),
    );
    if (ok) await _reloadImages();
  }

  Future<void> removeImage(ImageDto image) async {
    final ok = await _guard(
      () => image.kind == ImageKindDto.link
          ? _imagesApi.removeLink(
              owner: ImageOwnerDto.note,
              ownerId: noteId,
              url: image.value,
            )
          : _imagesApi.removeImage(
              owner: ImageOwnerDto.note,
              ownerId: noteId,
              name: image.name,
            ),
    );
    if (ok) await _reloadImages();
  }

  Future<void> _reloadImages() async {
    try {
      _images = await _imagesApi.list(
        owner: ImageOwnerDto.note,
        ownerId: noteId,
      );
      _notify();
    } catch (e) {
      _report(e);
    }
  }

  // -------------------------------------------------------------- helpers
  void _setStatus(SaveStatus s) {
    if (_status == s) return;
    _status = s;
    _notify();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  void _report(Object e) =>
      onError?.call(e is ApiError ? e.message : e.toString());

  Future<bool> _guard(Future<void> Function() action) async {
    try {
      await action();
      return true;
    } catch (e) {
      _report(e);
      return false;
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    if (!_deleted && _dirty) _persist();
    _disposed = true;
    super.dispose();
  }
}
