import 'package:flutter/material.dart';
import 'package:mobile_client/core/rust/dto/image.dart';
import 'package:mobile_client/features/notes/presentation/widgets/note_image_view.dart';
import 'package:mobile_client/l10n/app_localizations.dart';

/// The note's images as a row of thumbnails: tap to open, ✕ to remove.
class NoteImageStrip extends StatelessWidget {
  const NoteImageStrip({
    super.key,
    required this.images,
    required this.onOpen,
    required this.onRemove,
  });

  final List<ImageDto> images;
  final void Function(int index) onOpen;
  /// null hides the ✕ (read-only view).
  final void Function(int index)? onRemove;

  static const double _size = 104;

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;

    return SizedBox(
      height: _size,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: images.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          return SizedBox.square(
            dimension: _size,
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: GestureDetector(
                    onTap: () => onOpen(i),
                    child: NoteImageView(
                      image: images[i],
                      cacheWidth: 320,
                    ),
                  ),
                ),
                if (onRemove != null)
                  PositionedDirectional(
                  top: 4,
                  end: 4,
                  child: Material(
                    color: cs.scrim.withValues(alpha: 0.55),
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () => onRemove!(i),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          Icons.close,
                          size: 16,
                          semanticLabel: l10n.note_image_remove,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
