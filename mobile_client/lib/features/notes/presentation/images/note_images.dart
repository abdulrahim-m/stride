import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

/// One image of a note: `![alt](path)` in the stored markdown.
///
/// [path] is either an http(s) link, or a path relative to the app's documents
/// folder (`note_images/<file>`), relative so it survives the app container
/// moving (iOS does that on updates and restores).
class NoteImage {
  const NoteImage({required this.path, this.alt = 'image'});

  final String path;
  final String alt;

  bool get isRemote => path.startsWith('http://') || path.startsWith('https://');

  String toMarkdown() => '![$alt]($path)';

  @override
  bool operator ==(Object other) =>
      other is NoteImage && other.path == path && other.alt == alt;

  @override
  int get hashCode => Object.hash(path, alt);
}

/// Keeps image lines out of the text editor: a note's markdown is split into
/// its text and its images, and joined again when saving. Images live at the
/// end of the stored markdown, one `![alt](path)` per line, so the note stays
/// valid markdown anywhere else.
class NoteImages {
  NoteImages._();

  static final RegExp _line = RegExp(r'^!\[([^\]]*)\]\(([^)\s]+)\)\s*$');

  static ({String text, List<NoteImage> images}) split(String markdown) {
    final kept = <String>[];
    final images = <NoteImage>[];
    for (final line in markdown.replaceAll('\r\n', '\n').split('\n')) {
      final m = _line.firstMatch(line);
      if (m == null) {
        kept.add(line);
      } else {
        images.add(NoteImage(path: m.group(2)!, alt: m.group(1)!));
      }
    }
    // Drop the blank lines that separated the images from the text.
    while (kept.isNotEmpty && kept.last.trim().isEmpty) {
      kept.removeLast();
    }
    return (text: kept.join('\n'), images: images);
  }

  static String join(String text, List<NoteImage> images) {
    if (images.isEmpty) return text;
    final block = images.map((i) => i.toMarkdown()).join('\n');
    return text.trim().isEmpty ? block : '$text\n\n$block';
  }
}

/// Copies picked images into the app's own folder (the gallery's temp file is
/// not ours to keep) and resolves stored paths back to files.
class NoteImageStore {
  NoteImageStore._();

  static const folder = 'note_images';
  static Directory? _root;

  static Future<Directory> _docs() async =>
      _root ??= await getApplicationDocumentsDirectory();

  static Future<File> resolve(String relativePath) async =>
      File('${(await _docs()).path}/$relativePath');

  static Future<NoteImage> import(XFile picked, {int salt = 0}) async {
    final dir = Directory('${(await _docs()).path}/$folder');
    await dir.create(recursive: true);
    final dot = picked.path.lastIndexOf('.');
    final ext = dot == -1 || picked.path.length - dot > 6
        ? '.jpg'
        : picked.path.substring(dot).toLowerCase();
    final name = '${DateTime.now().microsecondsSinceEpoch}_$salt$ext';
    await File(picked.path).copy('${dir.path}/$name');
    return NoteImage(path: '$folder/$name');
  }

  static Future<void> delete(NoteImage image) async {
    if (image.isRemote) return;
    try {
      final f = await resolve(image.path);
      if (await f.exists()) await f.delete();
    } catch (_) {
      // An orphaned file is harmless.
    }
  }
}
