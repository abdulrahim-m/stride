import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_client/l10n/app_localizations.dart';
import 'package:mobile_client/shared/dialogs/dialogs.dart';

/// What the person chose: picked file paths, or a link. The core copies the
/// files and validates the link.
class ImagePick {
  const ImagePick({this.paths = const [], this.link});
  final List<String> paths;
  final String? link;

  bool get isEmpty => paths.isEmpty && (link == null || link!.isEmpty);
}

enum _Source { gallery, camera, link }

/// Asks where the image comes from. Returns null if cancelled.
Future<ImagePick?> pickNoteImages(BuildContext context) async {
  final l10n = AppLocalizations.of(context)!;
  final source = await showModalBottomSheet<_Source>(
    context: context,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.photo_library_outlined),
            title: Text(l10n.note_image_gallery),
            onTap: () => Navigator.pop(context, _Source.gallery),
          ),
          ListTile(
            leading: const Icon(Icons.photo_camera_outlined),
            title: Text(l10n.note_image_camera),
            onTap: () => Navigator.pop(context, _Source.camera),
          ),
          ListTile(
            leading: const Icon(Icons.link),
            title: Text(l10n.note_image_from_link),
            onTap: () => Navigator.pop(context, _Source.link),
          ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
  if (source == null || !context.mounted) return null;

  final picker = ImagePicker();
  switch (source) {
    case _Source.gallery:
      final files = await picker.pickMultiImage(
        maxWidth: 1800,
        imageQuality: 85,
      );
      return ImagePick(paths: files.map((f) => f.path).toList());
    case _Source.camera:
      final file = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1800,
        imageQuality: 85,
      );
      return ImagePick(paths: file == null ? const [] : [file.path]);
    case _Source.link:
      final url = await showTextInputDialog(
        context,
        title: l10n.note_image_from_link,
        hint: l10n.note_image_link_hint,
        confirmLabel: l10n.notes_create,
      );
      return ImagePick(link: url?.trim());
  }
}
