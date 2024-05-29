import 'dart:async';
import 'dart:math';
import 'dart:io';

import 'package:colorfilter_generator/presets.dart';
import 'package:defer_pointer/defer_pointer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pro_image_editor_tony/designs/whatsapp/whatsapp_appbar.dart';
import 'package:pro_image_editor_tony/models/import_export/utils/export_import_enum.dart';
import 'package:pro_image_editor_tony/models/init_configs/blur_editor_init_configs.dart';
import 'package:pro_image_editor_tony/models/init_configs/filter_editor_init_configs.dart';
import 'package:pro_image_editor_tony/modules/main_editor/utils/layer_manager.dart';
import 'package:pro_image_editor_tony/models/theme/theme_editor_mode.dart';
import 'package:pro_image_editor_tony/modules/main_editor/utils/main_editor_controllers.dart';
import 'package:pro_image_editor_tony/modules/main_editor/utils/state_manager.dart';
import 'package:pro_image_editor_tony/modules/sticker_editor.dart';
import 'package:pro_image_editor_tony/utils/design_mode.dart';
import 'package:pro_image_editor_tony/mixins/editor_configs_mixin.dart';
import 'package:pro_image_editor_tony/utils/swipe_mode.dart';
import 'package:screenshot/screenshot.dart';
import 'package:vibration/vibration.dart';

import '../../designs/whatsapp/whatsapp_filter_button.dart';
import '../../designs/whatsapp/whatsapp_sticker_editor.dart';
import '../../mixins/main_editor/main_editor_global_keys.dart';
import '../../utils/constants.dart';
import '../../utils/image_helpers.dart';
import '../filter_editor/widgets/image_with_multiple_filters.dart';
import '../text_editor/text_editor.dart';
import 'utils/desktop_interaction_manager.dart';
import 'utils/main_editor_callbacks.dart';
import 'utils/screen_size_helper.dart';
import 'utils/whatsapp_helper.dart';
import '../../models/crop_rotate_editor/transform_factors.dart';
import '../../models/history/filter_state_history.dart';
import '../../models/history/state_history.dart';
import '../../models/history/last_position.dart';
import '../../models/crop_rotate_editor_response.dart';
import '../../models/editor_image.dart';
import '../../models/history/blur_state_history.dart';
import '../../models/import_export/export_state_history.dart';
import '../../models/import_export/export_state_history_configs.dart';
import '../../models/import_export/import_state_history.dart';
import '../../models/layer.dart';
import '../../models/init_configs/paint_editor_init_configs.dart';
import 'utils/layer_interaction_helper.dart';
import '../crop_rotate_editor/crop_rotate_editor.dart';
import '../emoji_editor/emoji_editor.dart';
import '../filter_editor/filter_editor.dart';
import '../filter_editor/widgets/filter_editor_item_list.dart';
import '../blur_editor.dart';
import '../paint_editor/paint_editor.dart';
import '../../utils/debounce.dart';
import '../../models/editor_configs/pro_image_editor_configs.dart';
import '../../mixins/converted_configs.dart';
import '../../widgets/adaptive_dialog.dart';
import '../../widgets/flat_icon_text_button.dart';
import '../../widgets/layer_widget.dart';
import '../../widgets/loading_dialog.dart';
import '../../widgets/pro_image_editor_desktop_mode.dart';
import '../../widgets/transformed_content_generator.dart';

/// A widget for image editing using ProImageEditor.
///
/// `ProImageEditor` provides a versatile image editing widget for Flutter applications.
/// It allows you to edit images from various sources like memory, files, assets, or network URLs.
///
/// You can use one of the specific constructors, such as `memory`, `file`, `asset`, or `network`,
/// to create an instance of this widget based on your image source. Additionally, you can provide
/// custom configuration settings through the `configs` parameter.
///
/// Example usage:
///
/// ```dart
/// ProImageEditor.memory(Uint8List.fromList(imageBytes));
/// ProImageEditor.file(File('path/to/image.jpg'));
/// ProImageEditor.asset('assets/images/image.png');
/// ProImageEditor.network('https://example.com/image.jpg');
/// ```
///
/// To handle image editing, you can use the callbacks provided by the `EditorConfigs` instance
/// passed through the `configs` parameter.
///
/// See also:
/// - [ProImageEditorConfigs] for configuring image editing options.
class ProImageEditor extends StatefulWidget with SimpleConfigsAccess {
  @override
  final ProImageEditorConfigs configs;

  /// Image data as a `Uint8List` from memory.
  final Uint8List? byteArray;

  /// Path to the image asset.
  final String? assetPath;

  /// URL of the image to be loaded from the network.
  final String? networkUrl;

  /// File object representing the image file.
  final File? file;

  /// A callback function that will be called when the editing is done,
  /// and it returns the edited image as a Uint8List.
  ///
  /// The edited image is provided as a Uint8List to the [onImageEditingComplete] function
  /// when the editing is completed.
  final ImageEditingCompleteCallback onImageEditingComplete;

  /// Whether [onImageEditingComplete] call with empty editing.
  ///
  /// The default value is false.
  final bool allowCompleteWithEmptyEditing;

  /// A callback function that will be called before the image editor will close.
  final ImageEditingEmptyCallback? onCloseEditor;

  /// A callback function that can be used to update the UI from custom widgets.
  final ImageEditingEmptyCallback? onUpdateUI;

  /// Creates a `ProImageEditor` widget for image editing.
  ///
  /// Use one of the specific constructors like `memory`, `file`, `asset`, or `network`
  /// to create an instance of this widget based on your image source.
  ///
  /// The [byteArray], [assetPath], [networkUrl], and [file] parameters represent different
  /// sources of the image data. At least one of these parameters must not be null.
  ///
  /// The `configs` parameter allows you to customize the image editing experience by providing
  /// various configuration options. If not specified, default settings will be used.
  ///
  /// The `onImageEditingComplete` parameter is a callback function that will be called when the editing is done,
  /// and it returns the edited image as a Uint8List.
  ///
  /// If `allowCompleteWithEmptyEditing` parameter is true,
  /// `onImageEditingComplete` will be called even if user done nothing to image.
  /// The default value is false.
  ///
  /// The `onCloseEditor` parameter is a callback function that gets invoked when the editor is closed.
  /// You can use this callback if you want to close the editor with your own parameters or if you want
  /// to prevent Navigator.pop(context) from being automatically triggered.
  ///
  /// The `onUpdateUI` parameter is a callback function that can be used to update the UI from custom widgets.
  const ProImageEditor._({
    super.key,
    required this.onImageEditingComplete,
    required this.allowCompleteWithEmptyEditing,
    this.onCloseEditor,
    this.onUpdateUI,
    this.byteArray,
    this.assetPath,
    this.networkUrl,
    this.file,
    this.configs = const ProImageEditorConfigs(),
  }) : assert(
          byteArray != null ||
              file != null ||
              networkUrl != null ||
              assetPath != null,
          'At least one of bytes, file, networkUrl, or assetPath must not be null.',
        );

  /// Creates a `ProImageEditor` widget for editing an image from memory.
  ///
  /// The `byteArray` parameter should contain the image data as a `Uint8List`.
  ///
  /// The `configs` parameter allows you to customize the image editing experience by providing
  /// various configuration options. If not specified, default settings will be used.
  ///
  /// The `onImageEditingComplete` parameter is a callback function that will be called when the editing is done,
  /// and it returns the edited image as a Uint8List.
  ///
  /// If `allowCompleteWithEmptyEditing` parameter is true,
  /// `onImageEditingComplete` will be called even if user done nothing to image.
  /// The default value is false.
  ///
  /// The `onCloseEditor` parameter is a callback function that gets invoked when the editor is closed.
  /// You can use this callback if you want to close the editor with your own parameters or if you want
  /// to prevent Navigator.pop(context) from being automatically triggered.
  ///
  /// The `onUpdateUI` parameter is a callback function that can be used to update the UI from custom widgets.
  factory ProImageEditor.memory(
    Uint8List byteArray, {
    Key? key,
    required ImageEditingCompleteCallback onImageEditingComplete,
    bool allowCompleteWithEmptyEditing = false,
    ImageEditingEmptyCallback? onUpdateUI,
    ImageEditingEmptyCallback? onCloseEditor,
    ProImageEditorConfigs configs = const ProImageEditorConfigs(),
  }) {
    return ProImageEditor._(
      key: key,
      byteArray: byteArray,
      configs: configs,
      onImageEditingComplete: onImageEditingComplete,
      allowCompleteWithEmptyEditing: allowCompleteWithEmptyEditing,
      onCloseEditor: onCloseEditor,
      onUpdateUI: onUpdateUI,
    );
  }

  /// Creates a `ProImageEditor` widget for editing an image from a file.
  ///
  /// The `file` parameter should point to the image file.
  ///
  /// The `configs` parameter allows you to customize the image editing experience by providing
  /// various configuration options. If not specified, default settings will be used.
  ///
  /// The `onImageEditingComplete` parameter is a callback function that will be called when the editing is done,
  /// and it returns the edited image as a Uint8List.
  ///
  /// If `allowCompleteWithEmptyEditing` parameter is true,
  /// `onImageEditingComplete` will be called even if user done nothing to image.
  /// The default value is false.
  ///
  /// The `onCloseEditor` parameter is a callback function that gets invoked when the editor is closed.
  /// You can use this callback if you want to close the editor with your own parameters or if you want
  /// to prevent Navigator.pop(context) from being automatically triggered.
  ///
  /// The `onUpdateUI` parameter is a callback function that can be used to update the UI from custom widgets.
  factory ProImageEditor.file(
    File file, {
    Key? key,
    ProImageEditorConfigs configs = const ProImageEditorConfigs(),
    required ImageEditingCompleteCallback onImageEditingComplete,
    bool allowCompleteWithEmptyEditing = false,
    ImageEditingEmptyCallback? onUpdateUI,
    ImageEditingEmptyCallback? onCloseEditor,
  }) {
    return ProImageEditor._(
      key: key,
      file: file,
      configs: configs,
      onImageEditingComplete: onImageEditingComplete,
      allowCompleteWithEmptyEditing: allowCompleteWithEmptyEditing,
      onCloseEditor: onCloseEditor,
      onUpdateUI: onUpdateUI,
    );
  }

  /// Creates a `ProImageEditor` widget for editing an image from an asset.
  ///
  /// The `assetPath` parameter should specify the path to the image asset.
  ///
  /// The `configs` parameter allows you to customize the image editing experience by providing
  /// various configuration options. If not specified, default settings will be used.
  ///
  /// The `onImageEditingComplete` parameter is a callback function that will be called when the editing is done,
  /// and it returns the edited image as a Uint8List.
  ///
  /// If `allowCompleteWithEmptyEditing` parameter is true,
  /// `onImageEditingComplete` will be called even if user done nothing to image.
  /// The default value is false.
  ///
  /// The `onCloseEditor` parameter is a callback function that gets invoked when the editor is closed.
  /// You can use this callback if you want to close the editor with your own parameters or if you want
  /// to prevent Navigator.pop(context) from being automatically triggered.
  ///
  /// The `onUpdateUI` parameter is a callback function that can be used to update the UI from custom widgets.
  factory ProImageEditor.asset(
    String assetPath, {
    Key? key,
    ProImageEditorConfigs configs = const ProImageEditorConfigs(),
    required ImageEditingCompleteCallback onImageEditingComplete,
    bool allowCompleteWithEmptyEditing = false,
    ImageEditingEmptyCallback? onUpdateUI,
    ImageEditingEmptyCallback? onCloseEditor,
  }) {
    return ProImageEditor._(
      key: key,
      assetPath: assetPath,
      configs: configs,
      onImageEditingComplete: onImageEditingComplete,
      allowCompleteWithEmptyEditing: allowCompleteWithEmptyEditing,
      onCloseEditor: onCloseEditor,
      onUpdateUI: onUpdateUI,
    );
  }

  /// Creates a `ProImageEditor` widget for editing an image from a network URL.
  ///
  /// The `networkUrl` parameter should specify the URL of the image to be loaded.
  ///
  /// The `configs` parameter allows you to customize the image editing experience by providing
  /// various configuration options. If not specified, default settings will be used.
  ///
  /// The `onImageEditingComplete` parameter is a callback function that will be called when the editing is done,
  /// and it returns the edited image as a Uint8List.
  ///
  /// If `allowCompleteWithEmptyEditing` parameter is true,
  /// `onImageEditingComplete` will be called even if user done nothing to image.
  /// The default value is false.
  ///
  /// The `onCloseEditor` parameter is a callback function that gets invoked when the editor is closed.
  /// You can use this callback if you want to close the editor with your own parameters or if you want
  /// to prevent Navigator.pop(context) from being automatically triggered.
  ///
  /// The `onUpdateUI` parameter is a callback function that can be used to update the UI from custom widgets.
  factory ProImageEditor.network(
    String networkUrl, {
    Key? key,
    ProImageEditorConfigs configs = const ProImageEditorConfigs(),
    required ImageEditingCompleteCallback onImageEditingComplete,
    bool allowCompleteWithEmptyEditing = false,
    ImageEditingEmptyCallback? onUpdateUI,
    ImageEditingEmptyCallback? onCloseEditor,
  }) {
    return ProImageEditor._(
      key: key,
      networkUrl: networkUrl,
      configs: configs,
      onImageEditingComplete: onImageEditingComplete,
      allowCompleteWithEmptyEditing: allowCompleteWithEmptyEditing,
      onCloseEditor: onCloseEditor,
      onUpdateUI: onUpdateUI,
    );
  }

  @override
  State<ProImageEditor> createState() => ProImageEditorState();
}

class ProImageEditorState extends State<ProImageEditor>
    with
        ImageEditorConvertedConfigs,
        SimpleConfigsAccessState,
        MainEditorGlobalKeys {
  /// Helper class for managing screen sizes and layout calculations.
  late final ScreenSizeHelper _screenSize;

  /// Manager class for handling desktop interactions in the image editor.
  late final DesktopInteractionManager _desktopInteractionManager;

  /// Controller instances for managing various aspects of the main editor.
  final MainEditorControllers _controllers = MainEditorControllers();

  /// Manager class for handling layer interactions in the editor.
  final LayerManager _layerManager = LayerManager();

  /// Manager class for managing the state of the editor.
  final StateManager _stateManager = StateManager();

  /// Helper class for managing WhatsApp filters.
  final WhatsAppHelper _whatsAppHelper = WhatsAppHelper();

  /// Helper class for managing interactions with layers in the editor.
  final LayerInteractionHelper _layerInteraction = LayerInteractionHelper();

  /// The current theme used by the image editor.
  late ThemeData _theme;

  /// Temporary layer used during editing.
  Layer? _tempLayer;

  /// Index of the selected layer.
  int _selectedLayerIndex = -1;

  /// Flag indicating if the editor has been initialized.
  bool _inited = false;

  /// Flag indicating if the crop tool is active.
  bool _activeCrop = false;

  /// Flag indicating if the image needs decoding.
  bool _imageNeedDecode = true;

  /// Flag to track if editing is completed.
  bool _doneEditing = false;

  /// The pixel ratio of the device's screen.
  double _pixelRatio = 1;

  /// Whether an editor is currently open.
  bool _isEditorOpen = false;

  /// Whether a dialog is currently open.
  bool _openDialog = false;

  /// Represents the direction of swipe action.
  SwipeMode _swipeDirection = SwipeMode.none;

  /// Represents the start time of the swipe action.
  DateTime _swipeStartTime = DateTime.now();

  /// Indicates whether the browser's context menu was enabled before any changes.
  bool _browserContextMenuBeforeEnabled = false;

  /// Store the last device Orientation
  int _deviceOrientation = 0;

  /// Getter for the active layer currently being edited.
  Layer? get _activeLayer =>
      activeLayers.length > _selectedLayerIndex && _selectedLayerIndex >= 0
          ? activeLayers[_selectedLayerIndex]
          : null;

  /// Get the list of layers from the current image editor changes.
  List<Layer> get activeLayers =>
      _stateManager.stateHistory[_stateManager.editPosition].layers;

  /// List to store the history of image editor changes.
  List<EditorStateHistory> get stateHistory => _stateManager.stateHistory;

  /// Determines whether undo actions can be performed on the current state.
  bool get canUndo => _stateManager.editPosition > 0;

  /// Determines whether redo actions can be performed on the current state.
  bool get canRedo =>
      _stateManager.editPosition < _stateManager.stateHistory.length - 1;

  Offset get newLayerOffsetPosition =>
      layerInteraction.newLayerOffsetPosition ??
      Offset(
        _screenSize.imageWidth / 2,
        _screenSize.imageHeight / 2,
      );

  @override
  void initState() {
    super.initState();
    _desktopInteractionManager = DesktopInteractionManager(
      configs: configs,
      context: context,
      onUpdateUI: widget.onUpdateUI,
      setState: setState,
    );
    _screenSize = ScreenSizeHelper(configs: configs, context: context);
    _layerInteraction.scaleDebounce =
        Debounce(const Duration(milliseconds: 100));

    _stateManager.imgStateHistory.add(EditorImage(
      assetPath: widget.assetPath,
      byteArray: widget.byteArray,
      file: widget.file,
      networkUrl: widget.networkUrl,
    ));

    _stateManager.stateHistory.add(EditorStateHistory(
        transformConfigs: TransformConfigs.empty(),
        bytesRefIndex: 0,
        blur: BlurStateHistory(),
        layers: [],
        filters: []));

    Vibration.hasVibrator()
        .then((value) => _layerInteraction.deviceCanVibrate = value ?? false);
    Vibration.hasCustomVibrationsSupport().then(
        (value) => _layerInteraction.deviceCanCustomVibrate = value ?? false);

    ServicesBinding.instance.keyboard.addHandler(_onKeyEvent);
    if (kIsWeb) {
      _browserContextMenuBeforeEnabled = BrowserContextMenu.enabled;
      BrowserContextMenu.disableContextMenu();
    }
  }

  @override
  void dispose() {
    _controllers.dispose();
    _layerInteraction.scaleDebounce.dispose();
    _screenSize.screenSizeDebouncer.dispose();
    SystemChrome.setSystemUIOverlayStyle(_theme.brightness == Brightness.dark
        ? SystemUiOverlayStyle.light
        : SystemUiOverlayStyle.dark);
    SystemChrome.restoreSystemUIOverlays();
    ServicesBinding.instance.keyboard.removeHandler(_onKeyEvent);
    if (kIsWeb && _browserContextMenuBeforeEnabled) {
      BrowserContextMenu.enableContextMenu();
    }
    super.dispose();
  }

  bool _onKeyEvent(KeyEvent event) {
    return _desktopInteractionManager.onKey(
      event,
      activeLayer: _activeLayer,
      canPressEscape: !_activeCrop && !_openDialog,
      isEditorOpen: _isEditorOpen,
      onCloseEditor: closeEditor,
      onUndoRedo: (undo) {
        if (undo) {
          undoAction();
        } else {
          redoAction();
        }
      },
    );
  }

  /// Add a cropped image to the editor.
  ///
  /// This method adds a cropped image to the editor and updates the editing state.
  void _addCroppedImg(List<Layer> layers, EditorImage image) {
    _stateManager.cleanForwardChanges();
    _stateManager.imgStateHistory.add(image);
    stateHistory.add(
      EditorStateHistory(
        transformConfigs: TransformConfigs.empty(),
        bytesRefIndex: _stateManager.imgStateHistory.length - 1,
        blur: _stateManager.blurStateHistory,
        layers: layers,
        filters: _stateManager.filters,
      ),
    );
    _stateManager.editPosition = stateHistory.length - 1;
  }

  /// Add a new layer to the image editor.
  ///
  /// This method adds a new layer to the image editor and updates the editing state.
  void addLayer(Layer layer, {int removeLayerIndex = -1, EditorImage? image}) {
    _stateManager.cleanForwardChanges();
    if (image != null) _stateManager.imgStateHistory.add(image);

    stateHistory.add(
      EditorStateHistory(
        transformConfigs: TransformConfigs.empty(),
        bytesRefIndex: _stateManager.imgStateHistory.length - 1,
        blur: _stateManager.blurStateHistory,
        layers: List<Layer>.from(
            stateHistory.last.layers.map((e) => _layerManager.copyLayer(e)))
          ..add(layer),
        filters: _stateManager.filters,
      ),
    );
    _stateManager.editPosition++;
    if (removeLayerIndex >= 0) {
      activeLayers.removeAt(removeLayerIndex);
    }
    if (_layerInteraction.layersAreSelectable(configs) &&
        layerInteraction.initialSelected) {
      _layerInteraction.selectedLayerId = layer.id;
    }
  }

  /// Remove a layer from the editor.
  ///
  /// This method removes a layer from the editor and updates the editing state.
  void removeLayer(int layerPos, {Layer? layer}) {
    _stateManager.cleanForwardChanges();
    var layers =
        List<Layer>.from(activeLayers.map((e) => _layerManager.copyLayer(e)));
    layers.removeAt(layerPos);
    stateHistory.add(
      EditorStateHistory(
        transformConfigs: TransformConfigs.empty(),
        bytesRefIndex: _stateManager.imgStateHistory.length - 1,
        blur: _stateManager.blurStateHistory,
        layers: layers,
        filters: _stateManager.filters,
      ),
    );
    var oldIndex = activeLayers
        .indexWhere((element) => element.id == (layer?.id ?? _tempLayer!.id));
    if (oldIndex >= 0) {
      stateHistory[_stateManager.editPosition].layers[oldIndex] =
          _layerManager.copyLayer(layer ?? _tempLayer!);
    }
    _stateManager.editPosition++;
  }

  /// Update the temporary layer in the editor.
  ///
  /// This method updates the temporary layer in the editor and updates the editing state.
  void _updateTempLayer() {
    _stateManager.cleanForwardChanges();
    stateHistory.add(
      EditorStateHistory(
        transformConfigs: TransformConfigs.empty(),
        bytesRefIndex: _stateManager.imgStateHistory.length - 1,
        blur: _stateManager.blurStateHistory,
        layers: List.from(
            stateHistory.last.layers.map((e) => _layerManager.copyLayer(e))),
        filters: _stateManager.filters,
      ),
    );
    var oldIndex =
        activeLayers.indexWhere((element) => element.id == _tempLayer!.id);
    if (oldIndex >= 0) {
      stateHistory[_stateManager.editPosition].layers[oldIndex] =
          _layerManager.copyLayer(_tempLayer!);
    }
    _stateManager.editPosition++;
    _tempLayer = null;
  }

  /// Decode the image being edited.
  ///
  /// This method decodes the image if it hasn't been decoded yet and updates its properties.
  void _decodeImage() async {
    bool shouldImportStateHistory =
        _imageNeedDecode && initStateHistory != null;
    _imageNeedDecode = false;
    var decodedImage =
        await decodeImageFromList(await _stateManager.image.safeByteArray);

    if (!mounted) return;
    var w = decodedImage.width;
    var h = decodedImage.height;

    var widthRatio = w.toDouble() / _screenSize.lastScreenSize.width;
    var heightRatio = h.toDouble() / _screenSize.screenInnerHeight;
    _pixelRatio = max(heightRatio, widthRatio);

    _screenSize.imageWidth = w / _pixelRatio;
    _screenSize.imageHeight = h / _pixelRatio;
    _inited = true;

    if (shouldImportStateHistory) {
      importStateHistory(initStateHistory!);
    }

    setState(() {});
    widget.onUpdateUI?.call();
  }

  /// Set the temporary layer to a copy of the provided layer.
  void _setTempLayer(Layer layer) {
    _tempLayer = _layerManager.copyLayer(layer);
  }

  /// Handle the start of a scaling operation.
  ///
  /// This method is called when a scaling operation begins and initializes the necessary variables.
  void _onScaleStart(ScaleStartDetails details) {
    _swipeDirection = SwipeMode.none;
    _swipeStartTime = DateTime.now();
    _layerInteraction.snapStartPosX = details.focalPoint.dx;
    _layerInteraction.snapStartPosY = details.focalPoint.dy;

    if (_selectedLayerIndex < 0) return;

    var layer = activeLayers[_selectedLayerIndex];

    if (_layerInteraction.selectedLayerId != layer.id) {
      _layerInteraction.selectedLayerId = '';
    }

    _setTempLayer(layer);
    _layerInteraction.baseScaleFactor = layer.scale;
    _layerInteraction.baseAngleFactor = layer.rotation;
    _layerInteraction.snapStartRotation = layer.rotation * 180 / pi;
    _layerInteraction.snapLastRotation = _layerInteraction.snapStartRotation;
    _layerInteraction.rotationStartedHelper = false;
    _layerInteraction.showHelperLines = true;

    double posX = layer.offset.dx + _screenSize.screenPaddingHelper.left;
    double posY = layer.offset.dy + _screenSize.screenPaddingHelper.top;

    _layerInteraction.lastPositionY =
        posY <= _screenSize.screenMiddleY - _layerInteraction.hitSpan
            ? LayerLastPosition.top
            : posY >= _screenSize.screenMiddleY + _layerInteraction.hitSpan
                ? LayerLastPosition.bottom
                : LayerLastPosition.center;

    _layerInteraction.lastPositionX =
        posX <= _screenSize.screenMiddleX - _layerInteraction.hitSpan
            ? LayerLastPosition.left
            : posX >= _screenSize.screenMiddleX + _layerInteraction.hitSpan
                ? LayerLastPosition.right
                : LayerLastPosition.center;
  }

  /// Handle updates during scaling.
  ///
  /// This method is called during a scaling operation and updates the selected layer's position and properties.
  void _onScaleUpdate(ScaleUpdateDetails details) {
    if (_selectedLayerIndex < 0) {
      if (imageEditorTheme.editorMode == ThemeEditorMode.whatsapp) {
        _whatsAppHelper.filterShowHelper -= details.focalPointDelta.dy;
        _whatsAppHelper.filterShowHelper =
            max(0, min(120, _whatsAppHelper.filterShowHelper));

        double pointerOffset =
            _layerInteraction.snapStartPosY - details.focalPoint.dy;
        if (pointerOffset > 20) {
          _swipeDirection = SwipeMode.up;
        } else if (pointerOffset < -20) {
          _swipeDirection = SwipeMode.down;
        }

        setState(() {});
      }
      return;
    }

    if (_whatsAppHelper.filterShowHelper > 0 || _activeLayer == null) return;

    if (_layerInteraction.rotateScaleLayerSizeHelper != null) {
      _layerInteraction.freeStyleHighPerformanceScaling =
          paintEditorConfigs.freeStyleHighPerformanceScaling ?? !isDesktop;
      _layerInteraction.calculateInteractiveButtonScaleRotate(
        activeLayer: _activeLayer!,
        screenPaddingHelper: _screenSize.screenPaddingHelper,
        configEnabledHitVibration: helperLines.hitVibration,
        details: details,
        layerTheme: imageEditorTheme.layerInteraction,
      );
      setState(() {});
      widget.onUpdateUI?.call();
      return;
    }

    _layerInteraction.enabledHitDetection = false;
    if (details.pointerCount == 1) {
      _layerInteraction.freeStyleHighPerformanceMoving =
          paintEditorConfigs.freeStyleHighPerformanceMoving ?? isWebMobile;
      _layerInteraction.calculateMovement(
        activeLayer: _activeLayer!,
        context: context,
        detail: details,
        screenMiddleX: _screenSize.screenMiddleX,
        screenMiddleY: _screenSize.screenMiddleY,
        screenPaddingHelper: _screenSize.screenPaddingHelper,
        configEnabledHitVibration: helperLines.hitVibration,
      );
    } else if (details.pointerCount == 2) {
      _layerInteraction.freeStyleHighPerformanceScaling =
          paintEditorConfigs.freeStyleHighPerformanceScaling ?? !isDesktop;
      _layerInteraction.calculateScaleRotate(
        activeLayer: _activeLayer!,
        detail: details,
        screenPaddingHelper: _screenSize.screenPaddingHelper,
        configEnabledHitVibration: helperLines.hitVibration,
      );
    }
    setState(() {});
    widget.onUpdateUI?.call();
  }

  /// Handle the end of a scaling operation.
  ///
  /// This method is called when a scaling operation ends and resets helper lines and flags.
  void _onScaleEnd(ScaleEndDetails detail) async {
    if (_selectedLayerIndex < 0 &&
        imageEditorTheme.editorMode == ThemeEditorMode.whatsapp) {
      _layerInteraction.showHelperLines = false;

      if (_swipeDirection != SwipeMode.none &&
          DateTime.now().difference(_swipeStartTime).inMilliseconds < 200) {
        if (_swipeDirection == SwipeMode.up) {
          _whatsAppHelper.filterSheetAutoAnimation(true, setState);
        } else if (_swipeDirection == SwipeMode.down) {
          _whatsAppHelper.filterSheetAutoAnimation(false, setState);
        }
      } else {
        if (_whatsAppHelper.filterShowHelper < 90) {
          _whatsAppHelper.filterSheetAutoAnimation(false, setState);
        } else {
          _whatsAppHelper.filterSheetAutoAnimation(true, setState);
        }
      }

      _whatsAppHelper.filterShowHelper =
          max(0, min(120, _whatsAppHelper.filterShowHelper));
      setState(() {});
    }

    if (!_layerInteraction.hoverRemoveBtn && _tempLayer != null) {
      _updateTempLayer();
    }

    _layerInteraction.onScaleEnd();
    setState(() {});
    widget.onUpdateUI?.call();
  }

  /// Handles tap events on a text layer.
  ///
  /// This method opens a text editor for the specified text layer and updates the layer's properties
  /// based on the user's input.
  ///
  /// [layerData] - The text layer data to be edited.
  void _onTextLayerTap(TextLayerData layerData) async {
    TextLayerData? layer = await _openPage(
      TextEditor(
        key: textEditor,
        layer: layerData,
        heroTag: layerData.id,
        configs: widget.configs,
        theme: _theme,
        onUpdateUI: widget.onUpdateUI,
      ),
      duration: const Duration(milliseconds: 50),
    );

    if (layer == null || !mounted) return;

    int i = activeLayers.indexWhere((element) => element.id == layerData.id);
    if (i >= 0) {
      _setTempLayer(layerData);
      TextLayerData textLayer = activeLayers[i] as TextLayerData;
      textLayer
        ..text = layer.text
        ..background = layer.background
        ..color = layer.color
        ..colorMode = layer.colorMode
        ..colorPickerPosition = layer.colorPickerPosition
        ..align = layer.align
        ..fontScale = layer.fontScale
        ..fontStyle = layer.fontStyle
        ..id = layerData.id
        ..flipX = layerData.flipX
        ..flipY = layerData.flipY
        ..offset = layerData.offset
        ..scale = layerData.scale
        ..rotation = layerData.rotation;

      _updateTempLayer();
    }

    setState(() {});
    widget.onUpdateUI?.call();
  }

  /// Open a new page on top of the current page.
  ///
  /// This method navigates to a new page using a fade transition animation.
  Future<T?> _openPage<T>(
    Widget page, {
    Duration duration = const Duration(milliseconds: 300),
  }) {
    _layerInteraction.selectedLayerId = '';
    setState(() => _isEditorOpen = true);
    return Navigator.push<T?>(
      context,
      PageRouteBuilder(
        opaque: false,
        transitionDuration: duration,
        reverseTransitionDuration: duration,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        pageBuilder: (context, animation, secondaryAnimation) {
          void animationStatusListener(AnimationStatus status) {
            if (status == AnimationStatus.dismissed) {
              setState(() => _isEditorOpen = false);
              animation.removeStatusListener(animationStatusListener);
            }
          }

          animation.addStatusListener(animationStatusListener);
          return page;
        },
      ),
    );
  }

  /// Opens the painting editor.
  ///
  /// This method opens the painting editor and allows the user to draw on the current image.
  /// After closing the painting editor, any changes made are applied to the image's layers.
  void openPaintingEditor() async {
    await _openPage<List<PaintingLayerData>>(
      PaintingEditor.autoSource(
        key: paintingEditor,
        file: _stateManager.image.file,
        byteArray: _stateManager.image.byteArray,
        assetPath: _stateManager.image.assetPath,
        networkUrl: _stateManager.image.networkUrl,
        initConfigs: PaintEditorInitConfigs(
          layers: activeLayers,
          theme: _theme,
          imageSize: Size(_screenSize.imageWidth, _screenSize.imageHeight),
          configs: widget.configs,
          paddingHelper: EdgeInsets.only(
            top: _screenSize.screenPaddingHelper.top - _screenSize.appBarHeight,
            left: _screenSize.screenPaddingHelper.left,
          ),
          onUpdateUI: widget.onUpdateUI,
          appliedBlurFactor: _stateManager.blurStateHistory.blur,
          appliedFilters: _stateManager.filters,
        ),
      ),
      duration: const Duration(milliseconds: 150),
    ).then((List<PaintingLayerData>? paintingLayers) {
      if (paintingLayers != null && paintingLayers.isNotEmpty) {
        for (var layer in paintingLayers) {
          addLayer(layer);
        }

        setState(() {});
        widget.onUpdateUI?.call();
      }
    });
  }

  /// Opens the text editor.
  ///
  /// This method opens the text editor, allowing the user to add or edit text layers on the image.
  void openTextEditor() async {
    TextLayerData? layer = await _openPage(
      TextEditor(
        key: textEditor,
        configs: widget.configs,
        theme: _theme,
        onUpdateUI: widget.onUpdateUI,
      ),
      duration: const Duration(milliseconds: 50),
    );

    if (layer == null || !mounted) return;
    layer.offset = newLayerOffsetPosition;

    addLayer(layer);

    setState(() {});
    widget.onUpdateUI?.call();
  }

  /// Opens the crop editor.
  ///
  /// This method opens the crop editor, allowing the user to crop and rotate the image.
  void openCropEditor() async {
    if (_activeCrop) return;
    EditorImage img = EditorImage(
      assetPath: _stateManager.image.assetPath,
      byteArray: _stateManager.image.byteArray,
      file: _stateManager.image.file,
      networkUrl: _stateManager.image.networkUrl,
    );
    Uint8List? bytesWithLayers;
    if (activeLayers.isNotEmpty ||
        _stateManager.filters.isNotEmpty ||
        _stateManager.blurStateHistory.blur != 0) {
      _activeCrop = true;
      LoadingDialog loading = LoadingDialog()
        ..show(
          context,
          theme: _theme,
          imageEditorTheme: imageEditorTheme,
          designMode: designMode,
          i18n: i18n,
          message: i18n.cropRotateEditor.prepareImageDialogMsg,
        );
      setState(() {
        _layerInteraction.selectedLayerId = '';
      });
      bytesWithLayers = await _controllers.screenshot.capture(
        pixelRatio: _pixelRatio,
      );
      if (mounted) await loading.hide(context);
    }
    _activeCrop = false;
    if (!mounted) return;

    _openPage<CropRotateEditorRes?>(
      CropRotateEditor.autoSource(
        key: cropRotateEditor,
        file: img.file,
        onUpdateUI: widget.onUpdateUI,
        byteArray: img.byteArray,
        assetPath: img.assetPath,
        networkUrl: img.networkUrl,
        bytesWithLayers: bytesWithLayers,
        theme: _theme,
        imageSize: Size(_screenSize.imageWidth, _screenSize.imageHeight),
        configs: widget.configs,
      ),
    ).then((response) async {
      if (response != null) {
        CropRotateEditorResponse res = response.result;
        if (res.bytes != null) {
          var decodedImage = response.image;
          if (!mounted) return;
          var w = decodedImage.width;
          var h = decodedImage.height;

          var widthRatio = w.toDouble() / _screenSize.lastScreenSize.width;
          var heightRatio = h.toDouble() / _screenSize.screenInnerHeight;
          var newPixelRatio = max(heightRatio, widthRatio);

          var newImgW = w / newPixelRatio;
          var newImgH = h / newPixelRatio;
          var scale = (_screenSize.imageWidth * _pixelRatio) / w;
          var oldFullW = _screenSize.imageWidth * _pixelRatio;
          var oldFullH = _screenSize.imageHeight * _pixelRatio;

          var rotationScale = _screenSize.imageWidth / newImgH;

          double fitFactor = 1;

          bool oldFitWidth = _screenSize.imageWidth >=
                  _screenSize.lastScreenSize.width - 0.1 &&
              _screenSize.imageWidth <= _screenSize.lastScreenSize.width + 0.1;
          bool newFitWidth =
              newImgW >= _screenSize.lastScreenSize.width - 0.1 &&
                  newImgW <= _screenSize.lastScreenSize.width + 0.1;
          var scaleX = newFitWidth ? oldFullW / w : oldFullH / h;

          if (oldFitWidth != newFitWidth) {
            if (newFitWidth) {
              fitFactor = _screenSize.imageWidth / newImgW;
            } else {
              fitFactor = _screenSize.imageHeight / newImgH;
            }
          }

          List<Layer> updatedLayers = [];
          for (var el in activeLayers) {
            var layer = _layerManager.copyLayer(el);
            var beforeIsFlipX = layer.flipX;
            switch (res.rotationAngle) {
              case 0:
              case 180:
                layer.offset = Offset(
                  layer.offset.dx / fitFactor,
                  layer.offset.dy / fitFactor,
                );
                break;
              case 180:
                layer.offset = Offset(
                  layer.offset.dx / fitFactor,
                  layer.offset.dy / fitFactor,
                );
                break;
              default:
            }
            bool zoomed = _layerInteraction.zoomedLayer(
              layer: layer,
              scale: scale,
              scaleX: scaleX,
              oldFullH: oldFullH,
              oldFullW: oldFullW,
              cropRect: res.cropRect,
              isHalfPi: res.isHalfPi,
              pixelRatio: _pixelRatio,
            );
            _layerInteraction.flipLayer(
              layer: layer,
              flipX: res.flipX,
              flipY: res.flipY,
              isHalfPi: res.isHalfPi,
              imageHeight: _screenSize.imageHeight,
              imageWidth: _screenSize.imageWidth,
            );
            _layerInteraction.rotateLayer(
              layer: layer,
              beforeIsFlipX: beforeIsFlipX,
              newImgW: newImgW,
              newImgH: newImgH,
              rotationAngle: res.rotationAngle,
              rotationRadian: res.rotationRadian,
              rotationScale: zoomed ? 1 : rotationScale,
            );

            updatedLayers.add(layer);
          }

          _addCroppedImg(updatedLayers, EditorImage(byteArray: res.bytes));
          _pixelRatio = max(heightRatio, widthRatio);
          _screenSize.imageWidth = w / _pixelRatio;
          _screenSize.imageHeight = h / _pixelRatio;
          setState(() {});
          widget.onUpdateUI?.call();
        }
      }
    });
  }

  /// Opens the filter editor.
  ///
  /// This method allows the user to apply filters to the current image and replaces the image
  /// with the filtered version if a filter is applied.
  ///
  /// The filter editor is opened as a page, and the resulting filtered image is received as a
  /// `Uint8List`. If no filter is applied or the operation is canceled, the original image is retained.
  void openFilterEditor() async {
    if (!mounted) return;
    FilterStateHistory? filterAppliedImage = await _openPage(
      FilterEditor.autoSource(
        key: filterEditor,
        file: _stateManager.image.file,
        byteArray: _stateManager.image.byteArray,
        assetPath: _stateManager.image.assetPath,
        networkUrl: _stateManager.image.networkUrl,
        initConfigs: FilterEditorInitConfigs(
          theme: _theme,
          configs: widget.configs,
          transformConfigs: _stateManager.transformConfigs,
          onUpdateUI: widget.onUpdateUI,
          layers: activeLayers,
          imageSizeWithLayers: _screenSize.renderedImageSize,
          bodySizeWithLayers: _screenSize.bodySize,
          convertToUint8List: false,
          appliedBlurFactor: _stateManager.blurStateHistory.blur,
          appliedFilters: _stateManager.filters,
        ),
      ),
    );

    if (filterAppliedImage == null) return;

    _stateManager.cleanForwardChanges();

    stateHistory.add(
      EditorStateHistory(
        transformConfigs: TransformConfigs.empty(),
        bytesRefIndex: _stateManager.imgStateHistory.length - 1,
        blur: _stateManager.blurStateHistory,
        layers: activeLayers,
        filters: [
          filterAppliedImage,
          ..._stateManager.filters,
        ],
      ),
    );
    _stateManager.editPosition++;

    setState(() {});
    widget.onUpdateUI?.call();
  }

  /// Opens the blur editor as a modal bottom sheet.
  void openBlurEditor() async {
    if (!mounted) return;
    double? blur = await _openPage(
      BlurEditor.autoSource(
        key: blurEditor,
        file: _stateManager.image.file,
        byteArray: _stateManager.image.byteArray,
        assetPath: _stateManager.image.assetPath,
        networkUrl: _stateManager.image.networkUrl,
        initConfigs: BlurEditorInitConfigs(
          theme: _theme,
          imageSize: Size(_screenSize.imageWidth, _screenSize.imageHeight),
          imageSizeWithLayers: _screenSize.renderedImageSize,
          bodySizeWithLayers: _screenSize.bodySize,
          layers: activeLayers,
          configs: widget.configs,
          transformConfigs: _stateManager.transformConfigs,
          onUpdateUI: widget.onUpdateUI,
          convertToUint8List: false,
          appliedBlurFactor: _stateManager.blurStateHistory.blur,
          appliedFilters: _stateManager.filters,
        ),
      ),
    );

    if (blur == null) return;

    _stateManager.cleanForwardChanges();

    stateHistory.add(
      EditorStateHistory(
        transformConfigs: TransformConfigs.empty(),
        bytesRefIndex: _stateManager.imgStateHistory.length - 1,
        blur: BlurStateHistory(blur: blur),
        layers: activeLayers,
        filters: _stateManager.filters,
      ),
    );
    _stateManager.editPosition++;

    setState(() {});
    widget.onUpdateUI?.call();
  }

  /// Opens the emoji editor.
  ///
  /// This method opens the emoji editor as a modal bottom sheet, allowing the user to add emoji
  /// layers to the current image. The selected emoji layer's properties, such as scale and offset,
  /// are adjusted before adding it to the image's layers.
  ///
  /// Keyboard event handlers are temporarily removed while the emoji editor is active and restored
  /// after its closure.
  void openEmojiEditor() async {
    setState(() => _layerInteraction.selectedLayerId = '');
    ServicesBinding.instance.keyboard.removeHandler(_onKeyEvent);
    EmojiLayerData? layer = await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black,
      builder: (BuildContext context) => EmojiEditor(configs: widget.configs),
    );
    ServicesBinding.instance.keyboard.addHandler(_onKeyEvent);
    if (layer == null || !mounted) return;
    layer.scale = emojiEditorConfigs.initScale;
    layer.offset = newLayerOffsetPosition;

    addLayer(layer);

    setState(() {});
    widget.onUpdateUI?.call();
  }

  /// Opens the sticker editor as a modal bottom sheet.
  void openStickerEditor() async {
    setState(() => _layerInteraction.selectedLayerId = '');
    ServicesBinding.instance.keyboard.removeHandler(_onKeyEvent);
    StickerLayerData? layer = await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black,
      builder: (BuildContext context) => StickerEditor(
        configs: widget.configs,
      ),
    );
    ServicesBinding.instance.keyboard.addHandler(_onKeyEvent);
    if (layer == null || !mounted) return;
    layer.offset = newLayerOffsetPosition;

    addLayer(layer);

    setState(() {});
    widget.onUpdateUI?.call();
  }

  /// Opens the WhatsApp sticker editor.
  ///
  /// This method removes the keyboard handler, then depending on the design mode specified in the [configs] parameter of the widget, it either opens the WhatsAppStickerPage directly or shows it as a modal bottom sheet.
  ///
  /// If the design mode is set to [ImageEditorDesignModeE.material], the WhatsAppStickerPage is opened directly using [_openPage()]. Otherwise, it is displayed as a modal bottom sheet with specific configurations such as transparent background, black barrier color, and controlled scrolling.
  ///
  /// After the page is opened and a layer is returned, the keyboard handler is added back. If no layer is returned or the widget is not mounted, the method returns early.
  ///
  /// If the returned layer's runtime type is not StickerLayerData, the layer's scale is set to the initial scale specified in [emojiEditorConfigs] of the [configs] parameter. Regardless, the layer's offset is set to the center of the image.
  ///
  /// Finally, the layer is added, the UI is updated, and the widget's [onUpdateUI] callback is called if provided.
  void openWhatsAppStickerEditor() async {
    ServicesBinding.instance.keyboard.removeHandler(_onKeyEvent);

    Layer? layer;
    if (designMode == ImageEditorDesignModeE.material) {
      layer = await _openPage(WhatsAppStickerPage(
        configs: widget.configs,
      ));
    } else {
      layer = await showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        barrierColor: Colors.black12,
        showDragHandle: false,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (context) {
          return Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              clipBehavior: Clip.hardEdge,
              child: WhatsAppStickerPage(
                configs: widget.configs,
              ),
            ),
          );
        },
      );
    }

    ServicesBinding.instance.keyboard.addHandler(_onKeyEvent);
    if (layer == null || !mounted) {
      setState(() {});
      return;
    }

    if (layer.runtimeType != StickerLayerData) {
      layer.scale = emojiEditorConfigs.initScale;
    }
    layer.offset = newLayerOffsetPosition;

    addLayer(layer);

    setState(() {});
    widget.onUpdateUI?.call();
  }

  /// Moves a layer in the list to a new position.
  ///
  /// - `oldIndex` is the current index of the layer.
  /// - `newIndex` is the desired index to move the layer to.
  void moveLayerListPosition({
    required int oldIndex,
    required int newIndex,
  }) {
    if (newIndex > oldIndex) {
      var item = activeLayers.removeAt(oldIndex);
      activeLayers.insert(newIndex - 1, item);
    } else {
      var item = activeLayers.removeAt(oldIndex);
      activeLayers.insert(newIndex, item);
    }
    setState(() {});
  }

  /// Undo the last editing action.
  ///
  /// This function allows the user to undo the most recent editing action performed on the image.
  /// It decreases the edit position, and the image is decoded to reflect the previous state.
  void undoAction() {
    if (_stateManager.editPosition > 0) {
      setState(() {
        _layerInteraction.selectedLayerId = '';
        _stateManager.editPosition--;
        _decodeImage();
      });
      widget.onUpdateUI?.call();
    }
  }

  /// Redo the previously undone editing action.
  ///
  /// This function allows the user to redo an editing action that was previously undone using the
  /// `undoAction` function. It increases the edit position, and the image is decoded to reflect
  /// the next state.
  void redoAction() {
    if (_stateManager.editPosition < stateHistory.length - 1) {
      setState(() {
        _layerInteraction.selectedLayerId = '';
        _stateManager.editPosition++;
        _decodeImage();
      });
      widget.onUpdateUI?.call();
    }
  }

  /// Complete the editing process and return the edited image.
  ///
  /// This function is called when the user is done editing the image. If no changes have been made
  /// or if the image has no additional layers, it cancels the editing process and closes the editor.
  /// Otherwise, it captures the current state of the image, including any applied changes or layers,
  /// and returns it as a byte array.
  ///
  /// Before returning the edited image, a loading dialog is displayed to indicate that the operation
  /// is in progress.
  void doneEditing() async {
    if (_stateManager.editPosition <= 0 && activeLayers.isEmpty) {
      final allowCompleteWithEmptyEditing =
          widget.allowCompleteWithEmptyEditing;
      if (!allowCompleteWithEmptyEditing) {
        return closeEditor();
      }
    }
    setState(() => _layerInteraction.selectedLayerId = '');

    _doneEditing = true;
    LoadingDialog loading = LoadingDialog()
      ..show(
        context,
        i18n: i18n,
        theme: _theme,
        designMode: designMode,
        message: i18n.doneLoadingMsg,
        imageEditorTheme: imageEditorTheme,
      );

    Uint8List bytes = Uint8List.fromList([]);
    try {
      bytes = await _controllers.screenshot.capture(
            pixelRatio: configs.removeTransparentAreas ? null : _pixelRatio,
          ) ??
          bytes;
    } catch (_) {}

    if (configs.removeTransparentAreas) {
      bytes = removeTransparentImgAreas(bytes) ?? bytes;
    }

    await widget.onImageEditingComplete(bytes);

    if (mounted) loading.hide(context);

    widget.onCloseEditor?.call();
  }

  /// Close the image editor.
  ///
  /// This function allows the user to close the image editor without saving any changes or edits.
  /// It navigates back to the previous screen or closes the modal editor.
  void closeEditor() {
    if (_stateManager.editPosition <= 0) {
      if (widget.onCloseEditor == null) {
        Navigator.pop(context);
      } else {
        widget.onCloseEditor!.call();
      }
    } else {
      closeWarning();
    }
  }

  /// Displays a warning dialog before closing the image editor.
  void closeWarning() async {
    _openDialog = true;

    bool close = false;

    if (customWidgets.closeWarningDialog != null) {
      close = await customWidgets.closeWarningDialog!();
    } else {
      await showAdaptiveDialog(
        context: context,
        builder: (BuildContext context) => Theme(
          data: _theme,
          child: AdaptiveDialog(
            designMode: designMode,
            brightness: _theme.brightness,
            imageEditorTheme: imageEditorTheme,
            title: Text(i18n.various.closeEditorWarningTitle),
            content: Text(i18n.various.closeEditorWarningMessage),
            actions: <AdaptiveDialogAction>[
              AdaptiveDialogAction(
                designMode: designMode,
                onPressed: () => Navigator.pop(context, 'Cancel'),
                child: Text(i18n.various.closeEditorWarningCancelBtn),
              ),
              AdaptiveDialogAction(
                designMode: designMode,
                onPressed: () {
                  close = true;
                  _stateManager.editPosition = 0;
                  Navigator.pop(context, 'OK');
                },
                child: Text(i18n.various.closeEditorWarningConfirmBtn),
              ),
            ],
          ),
        ),
      );
    }

    if (close) {
      if (widget.onCloseEditor == null) {
        if (mounted) Navigator.pop(context);
      } else {
        widget.onCloseEditor!.call();
      }
    }

    _openDialog = false;
  }

  /// Imports state history and performs necessary recalculations.
  ///
  /// If [ImportStateHistory.configs.recalculateSizeAndPosition] is `true`, it recalculates the position and size of layers.
  /// It adjusts the scale and offset of each layer based on the image size and the editor's dimensions.
  ///
  /// If [ImportStateHistory.configs.mergeMode] is [ImportEditorMergeMode.replace], it replaces the current state history with the imported one.
  /// Otherwise, it merges the imported state history with the current one based on the merge mode.
  ///
  /// After importing, it updates the UI by calling [setState()] and the optional [onUpdateUI] callback.
  void importStateHistory(ImportStateHistory import) {
    /// Recalculate position and size
    if (import.configs.recalculateSizeAndPosition) {
      var imgSize = import.imgSize;
      for (var el in import.stateHistory) {
        for (var layer in el.layers) {
          // Calculate scaling factors for width and height
          double scaleWidth = _screenSize.imageWidth / imgSize.width;
          double scaleHeight = _screenSize.imageHeight / imgSize.height;

          if (scaleWidth == 0 || scaleWidth.isInfinite) scaleWidth = 1;
          if (scaleHeight == 0 || scaleHeight.isInfinite) scaleHeight = 1;

          // Choose the middle value between scaleWidth and scaleHeight
          double scale = (scaleWidth + scaleHeight) / 2;

          // Adjust the scale
          layer.scale *= scale;

          // Adjust the offset
          layer.offset = Offset(
            layer.offset.dx * scaleWidth,
            layer.offset.dy * scaleHeight,
          );
        }
      }
    }

    if (import.configs.mergeMode == ImportEditorMergeMode.replace) {
      _stateManager.editPosition = import.editorPosition + 1;
      if (import.imgStateHistory.isNotEmpty) {
        _stateManager.imgStateHistory = import.imgStateHistory;
      }
      _stateManager.stateHistory = [
        EditorStateHistory(
            transformConfigs: TransformConfigs.empty(),
            bytesRefIndex: 0,
            blur: BlurStateHistory(),
            filters: [],
            layers: []),
        ...import.stateHistory
      ];
    } else {
      for (var el in import.stateHistory) {
        if (import.configs.mergeMode == ImportEditorMergeMode.merge) {
          el.layers.insertAll(0, stateHistory.last.layers);
          el.filters.insertAll(0, stateHistory.last.filters);
        }
      }

      stateHistory.addAll(import.stateHistory);
      _stateManager.imgStateHistory.addAll(import.imgStateHistory);
      _stateManager.editPosition = stateHistory.length - 1;
    }

    setState(() {});
    widget.onUpdateUI?.call();
  }

  /// Exports the current state history.
  ///
  /// `configs` specifies the export configurations, such as whether to include filters or layers.
  ///
  /// Returns an [ExportStateHistory] object containing the exported state history, image state history, image size, edit position, and export configurations.
  ExportStateHistory exportStateHistory(
      {ExportEditorConfigs configs = const ExportEditorConfigs()}) {
    return ExportStateHistory(
      stateHistory,
      _stateManager.imgStateHistory,
      Size(_screenSize.imageWidth, _screenSize.imageHeight),
      _stateManager.editPosition,
      configs: configs,
    );
  }

  @override
  Widget build(BuildContext context) {
    _theme = configs.theme ??
        ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue.shade800,
            brightness: Brightness.dark,
          ),
        );
    if (_imageNeedDecode) _decodeImage();
    return Constants(
      child: OrientationBuilder(builder: (context, orientation) {
        if (_deviceOrientation != orientation.index) {
          _deviceOrientation = orientation.index;
        }
        return PopScope(
          canPop: _stateManager.editPosition <= 0 || _doneEditing,
          onPopInvoked: (didPop) {
            if (_stateManager.editPosition > 0 && !_doneEditing) {
              closeWarning();
            }
          },
          child: LayoutBuilder(builder: (context, constraints) {
            // Check if screensize changed to recalculate image size
            if (_screenSize.lastScreenSize.width != constraints.maxWidth ||
                _screenSize.lastScreenSize.height != constraints.maxHeight) {
              _screenSize.screenSizeDebouncer(() {
                _decodeImage();
              });
              _screenSize.lastScreenSize = constraints.biggest;
            }
            return AnnotatedRegion<SystemUiOverlayStyle>(
              value: imageEditorTheme.uiOverlayStyle,
              child: Theme(
                data: _theme,
                child: SafeArea(
                  child: Scaffold(
                    backgroundColor: imageEditorTheme.background,
                    resizeToAvoidBottomInset: false,
                    appBar: _buildAppBar(),
                    body: _buildBody(),
                    bottomNavigationBar: _buildBottomNavBar(),
                  ),
                ),
              ),
            );
          }),
        );
      }),
    );
  }

  PreferredSizeWidget? _buildAppBar() {
    return _selectedLayerIndex >= 0
        ? null
        : customWidgets.appBar ??
            (imageEditorTheme.editorMode == ThemeEditorMode.simple
                ? AppBar(
                    automaticallyImplyLeading: false,
                    foregroundColor: imageEditorTheme.appBarForegroundColor,
                    backgroundColor: imageEditorTheme.appBarBackgroundColor,
                    actions: [
                      IconButton(
                        tooltip: i18n.cancel,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        icon: Icon(icons.closeEditor),
                        onPressed: closeEditor,
                      ),
                      const Spacer(),
                      IconButton(
                        key: const ValueKey('TextEditorMainUndoButton'),
                        tooltip: i18n.undo,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        icon: Icon(
                          icons.undoAction,
                          color: _stateManager.editPosition > 0
                              ? imageEditorTheme.appBarForegroundColor
                              : imageEditorTheme.appBarForegroundColor
                                  .withAlpha(80),
                        ),
                        onPressed: undoAction,
                      ),
                      IconButton(
                        key: const ValueKey('TextEditorMainRedoButton'),
                        tooltip: i18n.redo,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        icon: Icon(
                          icons.redoAction,
                          color: _stateManager.editPosition <
                                  stateHistory.length - 1
                              ? imageEditorTheme.appBarForegroundColor
                              : imageEditorTheme.appBarForegroundColor
                                  .withAlpha(80),
                        ),
                        onPressed: redoAction,
                      ),
                      IconButton(
                        key: const ValueKey('TextEditorMainDoneButton'),
                        tooltip: i18n.done,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        icon: Icon(icons.doneIcon),
                        iconSize: 28,
                        onPressed: doneEditing,
                      ),
                    ],
                  )
                : null);
  }

  Widget _buildBody() {
    var editorImage = _buildImageWithFilter();

    return LayoutBuilder(builder: (context, constraints) {
      _screenSize.bodySize = constraints.biggest;
      return Listener(
        onPointerSignal: isDesktop
            ? (event) {
                if (_activeLayer == null) return;
                _desktopInteractionManager.mouseScroll(
                  event,
                  activeLayer: _activeLayer!,
                  selectedLayerIndex: _selectedLayerIndex,
                );
              }
            : null,
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            if (_layerInteraction.selectedLayerId.isNotEmpty) {
              _layerInteraction.selectedLayerId = '';
              setState(() {});
            }
          },
          onScaleStart: _onScaleStart,
          onScaleUpdate: _onScaleUpdate,
          onScaleEnd: _onScaleEnd,
          child: Stack(
            alignment: Alignment.center,
            fit: StackFit.expand,
            clipBehavior: Clip.none,
            children: [
              Transform.scale(
                transformHitTests: false,
                scale: 1 /
                    constraints.maxHeight *
                    (constraints.maxHeight -
                        _whatsAppHelper.filterShowHelper * 2),
                child: Stack(
                  alignment: Alignment.center,
                  fit: StackFit.expand,
                  clipBehavior: Clip.none,
                  children: [
                    Center(
                      child: SizedBox(
                        height: _screenSize.imageHeight,
                        width: _screenSize.imageWidth,
                        child: StreamBuilder<bool>(
                            stream: _controllers.mouseMoveStream.stream,
                            initialData: false,
                            builder: (context, snapshot) {
                              return MouseRegion(
                                hitTestBehavior: HitTestBehavior.translucent,
                                cursor: snapshot.data != true
                                    ? SystemMouseCursors.basic
                                    : imageEditorTheme
                                        .layerInteraction.hoverCursor,
                                onHover: isDesktop
                                    ? (event) {
                                        var hasHit = activeLayers.indexWhere(
                                                (element) =>
                                                    element
                                                        is PaintingLayerData &&
                                                    element.item.hit) >=
                                            0;
                                        if (hasHit != snapshot.data) {
                                          _controllers.mouseMoveStream
                                              .add(hasHit);
                                        }
                                      }
                                    : null,
                                child: Screenshot(
                                  controller: _controllers.screenshot,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    clipBehavior: Clip.none,
                                    children: [
                                      Hero(
                                        tag: !_inited ? '--' : heroTag,
                                        createRectTween: (begin, end) =>
                                            RectTween(begin: begin, end: end),
                                        child: Offstage(
                                          offstage: !_inited,
                                          child: editorImage,
                                        ),
                                      ),
                                      if (_selectedLayerIndex < 0)
                                        _buildLayers(),
                                    ],
                                  ),
                                ),
                              );
                            }),
                      ),
                    ),
                    // show same image solong decoding that screenshot is ready
                    if (!_inited) editorImage,
                    if (_selectedLayerIndex >= 0) _buildLayers(),
                    _buildHelperLines(),
                    if (_selectedLayerIndex >= 0) _buildRemoveIcon(),
                  ],
                ),
              ),
              if (imageEditorTheme.editorMode == ThemeEditorMode.whatsapp &&
                  _selectedLayerIndex < 0)
                ..._buildWhatsAppWidgets()
            ],
          ),
        ),
      );
    });
  }

  List<Widget> _buildWhatsAppWidgets() {
    double opacity =
        max(0, min(1, 1 - 1 / 120 * _whatsAppHelper.filterShowHelper));
    return [
      WhatsAppAppBar(
        configs: widget.configs,
        onClose: closeEditor,
        onTapCropRotateEditor: openCropEditor,
        onTapStickerEditor: openWhatsAppStickerEditor,
        onTapPaintEditor: openPaintingEditor,
        onTapTextEditor: openTextEditor,
        onTapUndo: undoAction,
        canUndo: canUndo,
        openEditor: _isEditorOpen,
      ),
      if (designMode == ImageEditorDesignModeE.material)
        WhatsAppFilterBtn(
          configs: widget.configs,
          opacity: opacity,
        ),
      if (customWidgets.whatsAppBottomWidget != null)
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Opacity(
            opacity: opacity,
            child: customWidgets.whatsAppBottomWidget!,
          ),
        ),
      Positioned(
        left: 0,
        right: 0,
        bottom: -120 + _whatsAppHelper.filterShowHelper,
        child: Opacity(
          opacity: max(0, min(1, 1 / 120 * _whatsAppHelper.filterShowHelper)),
          child: Container(
            margin: const EdgeInsets.only(top: 7),
            color: imageEditorTheme.filterEditor.whatsAppBottomBarColor,
            child: FilterEditorItemList(
              itemScaleFactor:
                  max(0, min(1, 1 / 120 * _whatsAppHelper.filterShowHelper)),
              byteArray: widget.byteArray,
              file: widget.file,
              assetPath: widget.assetPath,
              networkUrl: widget.networkUrl,
              blurFactor: _stateManager.blurStateHistory.blur,
              activeFilters: _stateManager.filters,
              configs: widget.configs,
              selectedFilter: _stateManager.filters.isNotEmpty
                  ? _stateManager.filters.first.filter
                  : PresetFilters.none,
              onSelectFilter: (filter) {
                _stateManager.cleanForwardChanges();

                stateHistory.add(
                  EditorStateHistory(
                    transformConfigs: TransformConfigs.empty(),
                    bytesRefIndex: _stateManager.imgStateHistory.length - 1,
                    blur: _stateManager.blurStateHistory,
                    layers: activeLayers,
                    filters: [
                      FilterStateHistory(
                        filter: filter,
                        opacity: 1,
                      ),
                    ],
                  ),
                );
                _stateManager.editPosition++;

                setState(() {});
                widget.onUpdateUI?.call();
              },
            ),
          ),
        ),
      ),
    ];
  }

  Widget? _buildBottomNavBar() {
    var bottomTextStyle = const TextStyle(fontSize: 10.0, color: Colors.white);
    double bottomIconSize = 22.0;

    return _selectedLayerIndex >= 0
        ? null
        : customWidgets.bottomNavigationBar ??
            (imageEditorTheme.editorMode == ThemeEditorMode.simple
                ? Theme(
                    data: _theme,
                    child: Scrollbar(
                      controller: _controllers.bottomBarScroll,
                      scrollbarOrientation: ScrollbarOrientation.top,
                      thickness: isDesktop ? null : 0,
                      child: BottomAppBar(
                        height: _screenSize.bottomBarHeight,
                        color: imageEditorTheme.bottomBarBackgroundColor,
                        padding: EdgeInsets.zero,
                        child: Center(
                          child: SingleChildScrollView(
                            controller: _controllers.bottomBarScroll,
                            scrollDirection: Axis.horizontal,
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minWidth:
                                    min(_screenSize.lastScreenSize.width, 600),
                                maxWidth: 600,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    if (paintEditorConfigs.enabled)
                                      FlatIconTextButton(
                                        key: const ValueKey(
                                            'open-painting-editor-btn'),
                                        label: Text(
                                            i18n.paintEditor
                                                .bottomNavigationBarText,
                                            style: bottomTextStyle),
                                        icon: Icon(
                                          icons.paintingEditor.bottomNavBar,
                                          size: bottomIconSize,
                                          color: Colors.white,
                                        ),
                                        onPressed: openPaintingEditor,
                                      ),
                                    if (textEditorConfigs.enabled)
                                      FlatIconTextButton(
                                        key: const ValueKey(
                                            'open-text-editor-btn'),
                                        label: Text(
                                            i18n.textEditor
                                                .bottomNavigationBarText,
                                            style: bottomTextStyle),
                                        icon: Icon(
                                          icons.textEditor.bottomNavBar,
                                          size: bottomIconSize,
                                          color: Colors.white,
                                        ),
                                        onPressed: openTextEditor,
                                      ),
                                    if (cropRotateEditorConfigs.enabled)
                                      FlatIconTextButton(
                                        key: const ValueKey(
                                            'open-crop-rotate-editor-btn'),
                                        label: Text(
                                            i18n.cropRotateEditor
                                                .bottomNavigationBarText,
                                            style: bottomTextStyle),
                                        icon: Icon(
                                          icons.cropRotateEditor.bottomNavBar,
                                          size: bottomIconSize,
                                          color: Colors.white,
                                        ),
                                        onPressed: openCropEditor,
                                      ),
                                    if (filterEditorConfigs.enabled)
                                      FlatIconTextButton(
                                        key: const ValueKey(
                                            'open-filter-editor-btn'),
                                        label: Text(
                                            i18n.filterEditor
                                                .bottomNavigationBarText,
                                            style: bottomTextStyle),
                                        icon: Icon(
                                          icons.filterEditor.bottomNavBar,
                                          size: bottomIconSize,
                                          color: Colors.white,
                                        ),
                                        onPressed: openFilterEditor,
                                      ),
                                    if (blurEditorConfigs.enabled)
                                      FlatIconTextButton(
                                        key: const ValueKey(
                                            'open-blur-editor-btn'),
                                        label: Text(
                                            i18n.blurEditor
                                                .bottomNavigationBarText,
                                            style: bottomTextStyle),
                                        icon: Icon(
                                          icons.blurEditor.bottomNavBar,
                                          size: bottomIconSize,
                                          color: Colors.white,
                                        ),
                                        onPressed: openBlurEditor,
                                      ),
                                    if (emojiEditorConfigs.enabled)
                                      FlatIconTextButton(
                                        key: const ValueKey(
                                            'open-emoji-editor-btn'),
                                        label: Text(
                                            i18n.emojiEditor
                                                .bottomNavigationBarText,
                                            style: bottomTextStyle),
                                        icon: Icon(
                                          icons.emojiEditor.bottomNavBar,
                                          size: bottomIconSize,
                                          color: Colors.white,
                                        ),
                                        onPressed: openEmojiEditor,
                                      ),
                                    if (stickerEditorConfigs?.enabled == true)
                                      FlatIconTextButton(
                                        key: const ValueKey(
                                            'open-sticker-editor-btn'),
                                        label: Text(
                                            i18n.stickerEditor
                                                .bottomNavigationBarText,
                                            style: bottomTextStyle),
                                        icon: Icon(
                                          icons.stickerEditor.bottomNavBar,
                                          size: bottomIconSize,
                                          color: Colors.white,
                                        ),
                                        onPressed: openStickerEditor,
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                : null);
  }

  Widget _buildLayers() {
    int loopHelper = 0;
    return IgnorePointer(
      ignoring: _selectedLayerIndex >= 0,
      child: DeferredPointerHandler(
        child: Stack(
          children: activeLayers.map((layerItem) {
            var i = loopHelper;
            loopHelper++;

            return LayerWidget(
              key: ValueKey('${layerItem.id}-$i'),
              configs: configs,
              padding: _selectedLayerIndex < 0
                  ? EdgeInsets.zero
                  : _screenSize.screenPaddingHelper,
              layerData: layerItem,
              enableHitDetection: _layerInteraction.enabledHitDetection,
              freeStyleHighPerformanceScaling:
                  _layerInteraction.freeStyleHighPerformanceScaling,
              freeStyleHighPerformanceMoving:
                  _layerInteraction.freeStyleHighPerformanceMoving,
              selected: _layerInteraction.selectedLayerId == layerItem.id,
              isInteractive: !_isEditorOpen,
              onEditTap: () {
                if (layerItem is TextLayerData) {
                  _onTextLayerTap(layerItem);
                }
              },
              onTap: (layer) async {
                if (_layerInteraction.layersAreSelectable(configs)) {
                  _layerInteraction.selectedLayerId =
                      layer.id == _layerInteraction.selectedLayerId
                          ? ''
                          : layer.id;
                } else if (layer is TextLayerData) {
                  _onTextLayerTap(layer);
                }
              },
              onTapUp: () {
                setState(() {
                  if (_layerInteraction.hoverRemoveBtn) {
                    removeLayer(_selectedLayerIndex);
                  }
                  _selectedLayerIndex = -1;
                });
                widget.onUpdateUI?.call();
              },
              onTapDown: () {
                _selectedLayerIndex = i;
              },
              onScaleRotateDown: (details, layerOriginalSize) {
                _selectedLayerIndex = i;
                _layerInteraction.rotateScaleLayerSizeHelper =
                    layerOriginalSize;
                _layerInteraction.rotateScaleLayerScaleHelper = layerItem.scale;
              },
              onScaleRotateUp: (details) {
                _layerInteraction.rotateScaleLayerSizeHelper = null;
                _layerInteraction.rotateScaleLayerScaleHelper = null;
                setState(() {
                  _selectedLayerIndex = -1;
                });
                widget.onUpdateUI?.call();
              },
              onRemoveTap: () {
                setState(() {
                  removeLayer(
                      activeLayers
                          .indexWhere((element) => element.id == layerItem.id),
                      layer: layerItem);
                });
                widget.onUpdateUI?.call();
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildHelperLines() {
    double screenH = _screenSize.screen.height;
    double screenW = _screenSize.screen.width;
    double lineH = 1.25;
    int duration = 100;
    if (!_layerInteraction.showHelperLines) return const SizedBox.shrink();
    return Stack(
      children: [
        if (helperLines.showVerticalLine)
          Align(
            alignment: Alignment.center,
            child: AnimatedContainer(
              duration: Duration(milliseconds: duration),
              width: _layerInteraction.showVerticalHelperLine ? lineH : 0,
              height: screenH,
              color: imageEditorTheme.helperLine.verticalColor,
            ),
          ),
        if (helperLines.showHorizontalLine)
          Align(
            alignment: Alignment.center,
            child: AnimatedContainer(
              duration: Duration(milliseconds: duration),
              width: screenW,
              height: _layerInteraction.showHorizontalHelperLine ? lineH : 0,
              color: imageEditorTheme.helperLine.horizontalColor,
            ),
          ),
        if (helperLines.showRotateLine)
          Positioned(
            left: _layerInteraction.rotationHelperLineX,
            top: _layerInteraction.rotationHelperLineY,
            child: FractionalTranslation(
              translation: const Offset(-0.5, -0.5),
              child: Transform.rotate(
                angle: _layerInteraction.rotationHelperLineDeg,
                child: AnimatedContainer(
                  duration: Duration(milliseconds: duration),
                  width: _layerInteraction.showRotationHelperLine ? lineH : 0,
                  height: screenH * 2,
                  color: imageEditorTheme.helperLine.rotateColor,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildRemoveIcon() {
    return customWidgets.removeLayer ??
        Positioned(
          top: 0,
          left: 0,
          child: SafeArea(
            bottom: false,
            child: Container(
              height: kToolbarHeight,
              width: kToolbarHeight,
              decoration: BoxDecoration(
                color: _layerInteraction.hoverRemoveBtn
                    ? Colors.red
                    : (imageEditorTheme.editorMode == ThemeEditorMode.simple
                        ? Colors.grey.shade800
                        : Colors.black12),
                borderRadius:
                    const BorderRadius.only(bottomRight: Radius.circular(100)),
              ),
              padding: const EdgeInsets.only(right: 12, bottom: 7),
              child: Center(
                child: Icon(
                  icons.removeElementZone,
                  size: 28,
                ),
              ),
            ),
          ),
        );
  }

  Widget _buildImageWithFilter() {
    return TransformedContentGenerator(
      configs: _stateManager.transformConfigs,
      child: LayoutBuilder(builder: (context, constraints) {
        _screenSize.renderedImageSize = constraints.biggest;
        return ImageWithMultipleFilters(
          width: _screenSize.imageWidth,
          height: _screenSize.imageHeight,
          designMode: designMode,
          image: _stateManager.image,
          filters: _stateManager.filters,
          blurFactor: _stateManager.blurStateHistory.blur,
        );
      }),
    );
  }
}
