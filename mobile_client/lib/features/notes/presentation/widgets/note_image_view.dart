import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mobile_client/core/rust/dto/image.dart';

/// Shows an [ImageDto]: a file kept by the core, or an external link.
class NoteImageView extends StatelessWidget {
  const NoteImageView({
    super.key,
    required this.image,
    this.fit = BoxFit.cover,
    this.cacheWidth,
  });

  final ImageDto image;
  final BoxFit fit;

  /// Decode at this width (in pixels) so thumbnails stay cheap.
  final int? cacheWidth;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    Widget broken(BuildContext _, Object _, StackTrace? _) => ColoredBox(
      color: cs.surfaceContainerHighest,
      child: Center(child: Icon(Icons.broken_image_outlined, color: cs.outline)),
    );

    if (image.kind == ImageKindDto.link) {
      return Image.network(
        image.value,
        fit: fit,
        cacheWidth: cacheWidth,
        errorBuilder: broken,
        loadingBuilder: (context, child, progress) => progress == null
            ? child
            : ColoredBox(
                color: cs.surfaceContainerHighest,
                child: const Center(
                  child: SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
      );
    }
    return Image.file(
      File(image.value),
      fit: fit,
      cacheWidth: cacheWidth,
      errorBuilder: broken,
    );
  }
}
