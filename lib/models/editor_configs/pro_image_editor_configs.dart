import 'package:flutter/material.dart';
import 'package:pro_image_editor_tony/models/import_export/import_state_history.dart';

import '../custom_widgets.dart';
import 'crop_rotate_editor_configs.dart';
import 'emoji_editor_configs.dart';
import 'filter_editor_configs.dart';
import 'blur_editor_configs.dart';
import 'layer_interaction_configs.dart';
import 'paint_editor_configs.dart';
import 'text_editor_configs.dart';
import 'helper_lines_configs.dart';
import 'sticker_editor_configs.dart';
import '../i18n/i18n.dart';
import '../icons/icons.dart';
import '../theme/theme.dart';
import '../../utils/design_mode.dart';

export 'helper_lines_configs.dart';
export 'paint_editor_configs.dart';
export 'text_editor_configs.dart';
export 'crop_rotate_editor_configs.dart';
export 'filter_editor_configs.dart';
export 'emoji_editor_configs.dart';
export 'sticker_editor_configs.dart';
export 'blur_editor_configs.dart';
export 'layer_interaction_configs.dart';

/// A class representing configuration options for the Image Editor.
class ProImageEditorConfigs {
  /// The theme to be used for the Image Editor.
  final ThemeData? theme;

  /// Remove the transparent area of the final image.
  final bool removeTransparentAreas;

  /// A unique hero tag for the Image Editor widget.
  final String heroTag;

  /// Internationalization settings for the Image Editor.
  final I18n i18n;

  /// Configuration options for helper lines in the Image Editor.
  final HelperLines helperLines;

  /// Configuration options for the layer interaction behavior.
  final LayerInteraction layerInteraction;

  /// Custom widgets to be used in the Image Editor.
  final ImageEditorCustomWidgets customWidgets;

  /// Theme settings for the Image Editor.
  final ImageEditorTheme imageEditorTheme;

  /// Icons to be used in the Image Editor.
  final ImageEditorIcons icons;

  /// Configuration options for the Paint Editor.
  final PaintEditorConfigs paintEditorConfigs;

  /// Configuration options for the Text Editor.
  final TextEditorConfigs textEditorConfigs;

  /// Configuration options for the Crop and Rotate Editor.
  final CropRotateEditorConfigs cropRotateEditorConfigs;

  /// Configuration options for the Filter Editor.
  final FilterEditorConfigs filterEditorConfigs;

  /// Configuration options for the Blur Editor.
  final BlurEditorConfigs blurEditorConfigs;

  /// Configuration options for the Emoji Editor.
  final EmojiEditorConfigs emojiEditorConfigs;

  /// Configuration options for the Sticker Editor.
  final StickerEditorConfigs? stickerEditorConfigs;

  /// The design mode for the Image Editor.
  final ImageEditorDesignModeE designMode;

  /// Holds the initial state history of the Image Editor.
  final ImportStateHistory? initStateHistory;

  /// Creates an instance of [ProImageEditorConfigs].
  /// - The `theme` specifies the theme for the Image Editor.
  /// - The `heroTag` is a unique tag for the Image Editor widget. By default, it is 'Pro-Image-Editor-Hero'.
  /// - The `activePreferredOrientations` is a list of preferred device orientations. The editor currently supports only 'portraitUp' orientation. After closing the editor, it will revert to your default settings.
  /// - The `i18n` is used for internationalization settings. By default, it uses an empty `I18n` instance.
  /// - The `helperLines` configures helper lines in the Image Editor. By default, it uses an empty `HelperLines` instance.
  /// - The `layerInteraction` specifies options for the layer interaction behavior.
  /// - The `customWidgets` specifies custom widgets to be used in the Image Editor. By default, it uses an empty `CustomWidgets` instance.
  /// - The `imageEditorTheme` sets the theme for the Image Editor. By default, it uses an empty `ImageEditorTheme` instance.
  /// - The `icons` specifies the icons to be used in the Image Editor. By default, it uses an empty `ImageEditorIcons` instance.
  /// - The `paintEditorConfigs` configures the Paint Editor. By default, it uses an empty `PaintEditorConfigs` instance.
  /// - The `textEditorConfigs` configures the Text Editor. By default, it uses an empty `TextEditorConfigs` instance.
  /// - The `cropRotateEditorConfigs` configures the Crop and Rotate Editor. By default, it uses an empty `CropRotateEditorConfigs` instance.
  /// - The `filterEditorConfigs` configures the Filter Editor. By default, it uses an empty `FilterEditorConfigs` instance.
  /// - The `emojiEditorConfigs` configures the Emoji Editor. By default, it uses an empty `EmojiEditorConfigs` instance.
  /// - The `stickerEditorConfigs` configures the Sticker Editor. By default, it uses an empty `stickerEditorConfigs` instance.
  /// - The `designMode` specifies the design mode for the Image Editor. By default, it is `ImageEditorDesignMode.material`.
  /// - The `initStateHistory` holds the initial state history of the Image Editor.
  const ProImageEditorConfigs({
    this.theme,
    this.heroTag = 'Pro-Image-Editor-Hero',
    this.i18n = const I18n(),
    this.removeTransparentAreas = false,
    this.helperLines = const HelperLines(),
    this.layerInteraction = const LayerInteraction(),
    this.customWidgets = const ImageEditorCustomWidgets(),
    this.imageEditorTheme = const ImageEditorTheme(),
    this.icons = const ImageEditorIcons(),
    this.paintEditorConfigs = const PaintEditorConfigs(),
    this.textEditorConfigs = const TextEditorConfigs(),
    this.cropRotateEditorConfigs = const CropRotateEditorConfigs(),
    this.filterEditorConfigs = const FilterEditorConfigs(),
    this.blurEditorConfigs = const BlurEditorConfigs(),
    this.emojiEditorConfigs = const EmojiEditorConfigs(),
    this.stickerEditorConfigs,
    this.designMode = ImageEditorDesignModeE.material,
    this.initStateHistory,
  });
}
