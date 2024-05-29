import 'package:flutter/widgets.dart';

import '../models/editor_image.dart';
import '../utils/design_mode.dart';
import 'platform_circular_progress_indicator.dart';

/// A versatile widget for displaying images with various sources.
class AutoImage extends StatelessWidget {
  /// The image to be displayed, wrapped as an [EditorImage].
  final EditorImage image;

  /// How the image should be inscribed into the space allocated for it.
  final BoxFit? fit;

  /// The preferred width of the image. If null, it will be determined by the parent widget.
  final double? width;

  /// The preferred height of the image. If null, it will be determined by the parent widget.
  final double? height;

  /// The design mode of the editor.
  final ImageEditorDesignModeE designMode;

  /// Creates an [AutoImage] widget with the specified image source and optional parameters.
  const AutoImage(
    this.image, {
    super.key,
    this.fit,
    this.width,
    this.height,
    required this.designMode,
  });

  @override
  Widget build(BuildContext context) {
    // Display the image based on its type.
    switch (image.type) {
      case EditorImageType.memory:
        return Image.memory(
          image.byteArray!,
          fit: fit,
          width: width,
          height: height,
        );
      case EditorImageType.file:
        return Image.file(
          image.file!,
          fit: fit,
          width: width,
          height: height,
        );
      case EditorImageType.network:
        return Image.network(
          image.networkUrl!,
          fit: fit,
          width: width,
          height: height,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) {
              return child;
            } else {
              // Display a circular progress indicator while the image is loading.
              return Center(
                child: PlatformCircularProgressIndicator(
                  designMode: designMode,
                ),
              );
            }
          },
        );
      case EditorImageType.asset:
        return Image.asset(
          image.assetPath!,
          fit: fit,
          width: width,
          height: height,
        );
    }
  }
}
