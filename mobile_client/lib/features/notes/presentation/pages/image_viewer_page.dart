import 'package:flutter/material.dart';
import 'package:mobile_client/core/rust/dto/image.dart';
import 'package:mobile_client/features/notes/presentation/widgets/note_image_view.dart';

/// Full-screen, swipeable, pinch-to-zoom view of a note's images.
class ImageViewerPage extends StatefulWidget {
  const ImageViewerPage({super.key, required this.images, this.initial = 0});

  final List<ImageDto> images;
  final int initial;

  static Future<void> open(
    BuildContext context,
    List<ImageDto> images,
    int index,
  ) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) => ImageViewerPage(images: images, initial: index),
      ),
    );
  }

  @override
  State<ImageViewerPage> createState() => _ImageViewerPageState();
}

class _ImageViewerPageState extends State<ImageViewerPage> {
  late final PageController _pages = PageController(
    initialPage: widget.initial,
  );
  late int _index = widget.initial;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: widget.images.length > 1
            ? Text('${_index + 1} / ${widget.images.length}')
            : null,
      ),
      body: PageView.builder(
        controller: _pages,
        itemCount: widget.images.length,
        onPageChanged: (i) => setState(() => _index = i),
        itemBuilder: (context, i) => InteractiveViewer(
          maxScale: 5,
          child: Center(
            child: NoteImageView(image: widget.images[i], fit: BoxFit.contain),
          ),
        ),
      ),
    );
  }
}
