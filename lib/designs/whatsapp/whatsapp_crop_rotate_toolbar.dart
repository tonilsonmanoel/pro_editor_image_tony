import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pro_image_editor_tony/models/editor_configs/pro_image_editor_configs.dart';
import 'package:pro_image_editor_tony/utils/design_mode.dart';

import '../../pro_image_editor.dart';

/// Represents the toolbar for the crop/rotate functionality in the WhatsApp theme.
class WhatsAppCropRotateToolbar extends StatefulWidget {
  /// The configuration for the image editor.
  final ProImageEditorConfigs configs;

  /// Callback function for canceling the crop/rotate operation.
  final Function() onCancel;

  /// Callback function for rotating the image.
  final Function() onRotate;

  /// Callback function for completing the crop/rotate operation.
  final Function() onDone;

  /// Callback function for resetting the crop/rotate operation.
  final Function() onReset;

  /// Callback function for opening aspect ratios.
  final Function() openAspectRatios;

  /// Constructs a WhatsAppCropRotateToolbar widget with the specified parameters.
  const WhatsAppCropRotateToolbar({
    super.key,
    required this.configs,
    required this.onCancel,
    required this.onRotate,
    required this.onDone,
    required this.onReset,
    required this.openAspectRatios,
  });

  @override
  State<WhatsAppCropRotateToolbar> createState() => _WhatsAppAppbarState();
}

class _WhatsAppAppbarState extends State<WhatsAppCropRotateToolbar> {
  @override
  Widget build(BuildContext context) {
    if (widget.configs.designMode == ImageEditorDesignModeE.material) {
      return _buildMaterialToolbar();
    } else {
      return _buildCupertinoToolbar();
    }
  }

  Widget _buildMaterialToolbar() {
    var style = TextStyle(
      color: widget
          .configs.imageEditorTheme.cropRotateEditor.appBarForegroundColor,
    );

    return BottomAppBar(
      color: widget
          .configs.imageEditorTheme.cropRotateEditor.appBarBackgroundColor,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: widget.onCancel,
            child: Text(
              widget.configs.i18n.cropRotateEditor.cancel,
              style: style,
            ),
          ),
          IconButton(
            onPressed: widget.onRotate,
            tooltip: widget.configs.i18n.cropRotateEditor.rotate,
            icon: Icon(widget.configs.icons.cropRotateEditor.rotate),
            color: widget.configs.imageEditorTheme.cropRotateEditor
                .appBarForegroundColor,
          ),
          TextButton(
            onPressed: widget.onDone,
            child: Text(
              widget.configs.i18n.cropRotateEditor.done,
              style: style,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCupertinoToolbar() {
    var padding = const EdgeInsets.symmetric(vertical: 8, horizontal: 16);
    var style = TextStyle(
      color: widget
          .configs.imageEditorTheme.cropRotateEditor.appBarForegroundColor,
      fontSize: 16,
    );

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: widget.onRotate,
                tooltip: widget.configs.i18n.cropRotateEditor.rotate,
                icon: Icon(widget.configs.icons.cropRotateEditor.rotate),
                color: widget.configs.imageEditorTheme.cropRotateEditor
                    .appBarForegroundColor,
              ),
              CupertinoButton(
                onPressed: widget.onReset,
                padding: padding,
                child: Text(
                  widget.configs.i18n.cropRotateEditor.reset,
                  style: style,
                ),
              ),
              IconButton(
                onPressed: widget.openAspectRatios,
                tooltip: widget.configs.i18n.cropRotateEditor.ratio,
                icon: Icon(widget.configs.icons.cropRotateEditor.aspectRatio),
                color: widget.configs.imageEditorTheme.cropRotateEditor
                    .appBarForegroundColor,
              ),
            ],
          ),
        ),
        Container(
          color: widget.configs.imageEditorTheme.cropRotateEditor
              .whatsappCupertinoBottomBarColor,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CupertinoButton(
                onPressed: widget.onCancel,
                padding: padding,
                child: Text(
                  widget.configs.i18n.cropRotateEditor.cancel,
                  style: style,
                ),
              ),
              CupertinoButton(
                onPressed: widget.onDone,
                padding: padding,
                child: Text(
                  widget.configs.i18n.cropRotateEditor.done,
                  style: style.copyWith(fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
