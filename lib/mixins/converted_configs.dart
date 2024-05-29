import 'package:pro_image_editor_tony/pro_image_editor.dart';

/// A mixin providing access to converted configurations from [ProImageEditorConfigs].
mixin ImageEditorConvertedConfigs {
  /// Returns the main configuration options for the editor.
  ProImageEditorConfigs get configs;

  /// Returns the configuration options for the paint editor.
  PaintEditorConfigs get paintEditorConfigs => configs.paintEditorConfigs;

  /// Returns the configuration options for the text editor.
  TextEditorConfigs get textEditorConfigs => configs.textEditorConfigs;

  /// Returns the configuration options for the crop and rotate editor.
  CropRotateEditorConfigs get cropRotateEditorConfigs =>
      configs.cropRotateEditorConfigs;

  /// Returns the configuration options for the filter editor.
  FilterEditorConfigs get filterEditorConfigs => configs.filterEditorConfigs;

  /// Returns the configuration options for the blur editor.
  BlurEditorConfigs get blurEditorConfigs => configs.blurEditorConfigs;

  /// Returns the configuration options for the emoji editor.
  EmojiEditorConfigs get emojiEditorConfigs => configs.emojiEditorConfigs;

  /// Returns the configuration options for the sticker editor.
  StickerEditorConfigs? get stickerEditorConfigs =>
      configs.stickerEditorConfigs;

  /// Returns the design mode for the image editor.
  ImageEditorDesignModeE get designMode => configs.designMode;

  /// Returns the theme settings for the image editor.
  ImageEditorTheme get imageEditorTheme => configs.imageEditorTheme;

  /// Returns custom widget configurations for the image editor.
  ImageEditorCustomWidgets get customWidgets => configs.customWidgets;

  /// Returns the icons used in the image editor.
  ImageEditorIcons get icons => configs.icons;

  /// Returns the internationalization settings for the image editor.
  I18n get i18n => configs.i18n;

  /// Returns the initial state history for the image editor.
  ImportStateHistory? get initStateHistory => configs.initStateHistory;

  /// Returns helper lines configurations for the image editor.
  HelperLines get helperLines => configs.helperLines;

  /// Returns layerInteraction configurations for the image editor.
  LayerInteraction get layerInteraction => configs.layerInteraction;

  /// Returns the hero tag used in the image editor.
  String get heroTag => configs.heroTag;
}
