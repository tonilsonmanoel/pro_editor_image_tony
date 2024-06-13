import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/layer_widget.dart';
import 'paint_editor/painted_model.dart';

/// Represents a layer with common properties for widgets.
class Layer {
  /// The position offset of the widget.
  late Offset offset;

  /// The rotation and scale values of the widget.
  late double rotation, scale;

  /// Flags to control horizontal and vertical flipping.
  late bool flipX, flipY;

  /// A unique identifier for the layer.
  late String id;

  /// Creates a new layer with optional properties.
  ///
  /// The [id] parameter can be used to provide a custom identifier for the layer.
  /// The [offset] parameter determines the position offset of the widget.
  /// The [rotation] parameter sets the rotation angle of the widget in degrees (default is 0).
  /// The [scale] parameter sets the scale factor of the widget (default is 1).
  /// The [flipX] parameter controls horizontal flipping (default is false).
  /// The [flipY] parameter controls vertical flipping (default is false).
  Layer({
    String? id,
    Offset? offset,
    double? rotation,
    double? scale,
    bool? flipX,
    bool? flipY,
  }) {
    // Initialize properties with provided values or defaults.
    this.id = id ?? _generateUniqueId();
    this.offset = offset ?? const Offset(64, 64);
    this.rotation = rotation ?? 0;
    this.scale = scale ?? 1;
    this.flipX = flipX ?? false;
    this.flipY = flipY ?? false;
  }

  factory Layer.fromMap(
    Map map,
    List<Uint8List> stickers,
  ) {
    TextStyle getTextStyleGoogle(String fontName) {
      TextStyle? fontStyle;

      if (fontName.startsWith("abrilfatface")) {
        fontStyle = GoogleFonts.abrilFatface();
      } else if (fontName.startsWith("aclonica")) {
        fontStyle = GoogleFonts.aclonica();
      } else if (fontName.startsWith("alegreyasans")) {
        fontStyle = GoogleFonts.alegreyaSans();
      } else if (fontName.startsWith("architectsdaughter")) {
        fontStyle = GoogleFonts.architectsDaughter();
      } else if (fontName.startsWith("archivo")) {
        fontStyle = GoogleFonts.archivo();
      } else if (fontName.startsWith("archivonarrow")) {
        fontStyle = GoogleFonts.archivoNarrow();
      } else if (fontName.startsWith("bebasneue")) {
        fontStyle = GoogleFonts.bebasNeue();
      } else if (fontName.startsWith("bitter")) {
        fontStyle = GoogleFonts.bitter();
      } else if (fontName.startsWith("breeserif")) {
        fontStyle = GoogleFonts.breeSerif();
      } else if (fontName.startsWith("bungee")) {
        fontStyle = GoogleFonts.bungee();
      } else if (fontName.startsWith("cabin")) {
        fontStyle = GoogleFonts.cabin();
      } else if (fontName.startsWith("cairo")) {
        fontStyle = GoogleFonts.cairo();
      } else if (fontName.startsWith("coda")) {
        fontStyle = GoogleFonts.coda();
      } else if (fontName.startsWith("comfortaa")) {
        fontStyle = GoogleFonts.comfortaa();
      } else if (fontName.startsWith("comicneue")) {
        fontStyle = GoogleFonts.comicNeue();
      } else if (fontName.startsWith("cousine")) {
        fontStyle = GoogleFonts.cousine();
      } else if (fontName.startsWith("croissantone")) {
        fontStyle = GoogleFonts.croissantOne();
      } else if (fontName.startsWith("fasterone")) {
        fontStyle = GoogleFonts.fasterOne();
      } else if (fontName.startsWith("forum")) {
        fontStyle = GoogleFonts.forum();
      } else if (fontName.startsWith("permanentmarker")) {
        fontStyle = GoogleFonts.permanentMarker();
      } else if (fontName.startsWith("greatvibes")) {
        fontStyle = GoogleFonts.greatVibes();
      } else if (fontName.startsWith("heebo")) {
        fontStyle = GoogleFonts.heebo();
      } else if (fontName.startsWith("inconsolata")) {
        fontStyle = GoogleFonts.inconsolata();
      } else if (fontName.startsWith("josefinslab")) {
        fontStyle = GoogleFonts.josefinSlab();
      } else if (fontName.startsWith("lato")) {
        fontStyle = GoogleFonts.lato();
      } else if (fontName.startsWith("librebaskerville")) {
        fontStyle = GoogleFonts.libreBaskerville();
      } else if (fontName.startsWith("lobster")) {
        fontStyle = GoogleFonts.lobster();
      } else if (fontName.startsWith("lora")) {
        fontStyle = GoogleFonts.lora();
      } else if (fontName.startsWith("merriweather")) {
        fontStyle = GoogleFonts.merriweather();
      } else if (fontName.startsWith("montserrat")) {
        fontStyle = GoogleFonts.montserrat();
      } else if (fontName.startsWith("mukta")) {
        fontStyle = GoogleFonts.mukta();
      } else if (fontName.startsWith("nunito")) {
        fontStyle = GoogleFonts.nunito();
      } else if (fontName.startsWith("offside")) {
        fontStyle = GoogleFonts.offside();
      } else if (fontName.startsWith("opensans")) {
        fontStyle = GoogleFonts.openSans();
      } else if (fontName.startsWith("oswald")) {
        fontStyle = GoogleFonts.oswald();
      } else if (fontName.startsWith("overlock")) {
        fontStyle = GoogleFonts.overlock();
      } else if (fontName.startsWith("pacifico")) {
        fontStyle = GoogleFonts.pacifico();
      } else if (fontName.startsWith("playfairdisplay")) {
        fontStyle = GoogleFonts.playfairDisplay();
      } else if (fontName.startsWith("poppins")) {
        fontStyle = GoogleFonts.poppins();
      } else if (fontName.startsWith("raleway")) {
        fontStyle = GoogleFonts.raleway();
      } else if (fontName.startsWith("roboto")) {
        fontStyle = GoogleFonts.roboto();
      } else if (fontName.startsWith("robotomono")) {
        fontStyle = GoogleFonts.robotoMono();
      } else if (fontName.startsWith("sourcesanspro")) {
        fontStyle = GoogleFonts.sourceSans3();
      } else if (fontName.startsWith("spacemono")) {
        fontStyle = GoogleFonts.spaceMono();
      } else if (fontName.startsWith("spicyrice")) {
        fontStyle = GoogleFonts.spicyRice();
      } else if (fontName.startsWith("squadaone")) {
        fontStyle = GoogleFonts.squadaOne();
      } else if (fontName.startsWith("sueellenfrancisco")) {
        fontStyle = GoogleFonts.sueEllenFrancisco();
      } else if (fontName.startsWith("tradewinds")) {
        fontStyle = GoogleFonts.tradeWinds();
      } else if (fontName.startsWith("ubuntu")) {
        fontStyle = GoogleFonts.ubuntu();
      } else if (fontName.startsWith("varela")) {
        fontStyle = GoogleFonts.varela();
      } else if (fontName.startsWith("vollkorn")) {
        fontStyle = GoogleFonts.vollkorn();
      } else if (fontName.startsWith("worksans")) {
        fontStyle = GoogleFonts.workSans();
      } else if (fontName.startsWith("zillaslab")) {
        fontStyle = GoogleFonts.zillaSlab();
      } else if (fontName.startsWith("mplusrounded1c")) {
        fontStyle = GoogleFonts.mPlusRounded1c();
      } else if (fontName.startsWith("almarai")) {
        fontStyle = GoogleFonts.almarai();
      } else if (fontName.startsWith("tajawal")) {
        fontStyle = GoogleFonts.tajawal();
      } else if (fontName.startsWith("oleoscript")) {
        fontStyle = GoogleFonts.oleoScript();
      } else if (fontName.startsWith("viga")) {
        fontStyle = GoogleFonts.viga();
      } else if (fontName.startsWith("homemadeapple")) {
        fontStyle = GoogleFonts.homemadeApple();
      } else if (fontName.startsWith("fredoka")) {
        fontStyle = GoogleFonts.fredoka();
      } else if (fontName.startsWith("oleoscriptswashcaps")) {
        fontStyle = GoogleFonts.oleoScriptSwashCaps();
      } else if (fontName.startsWith("magra")) {
        fontStyle = GoogleFonts.magra();
      } else if (fontName.startsWith("kaiseidecol")) {
        fontStyle = GoogleFonts.kaiseiDecol();
      } else if (fontName.startsWith("dotgothic16")) {
        fontStyle = GoogleFonts.dotGothic16();
      } else if (fontName.startsWith("fresca")) {
        fontStyle = GoogleFonts.fresca();
      } else if (fontName.startsWith("pottaone")) {
        fontStyle = GoogleFonts.pottaOne();
      } else if (fontName.startsWith("mochiypopone")) {
        fontStyle = GoogleFonts.mochiyPopOne();
      } else if (fontName.startsWith("cherrycreamsoda")) {
        fontStyle = GoogleFonts.cherryCreamSoda();
      } else if (fontName.startsWith("cutefont")) {
        fontStyle = GoogleFonts.cuteFont();
      } else if (fontName.startsWith("shipporiantique")) {
        fontStyle = GoogleFonts.shipporiAntique();
      } else if (fontName.startsWith("trainone")) {
        fontStyle = GoogleFonts.trainOne();
      } else {
        fontStyle = GoogleFonts.roboto();
      }
      return fontStyle;
    }

    Layer layer = Layer(
      flipX: map['flipX'] ?? false,
      flipY: map['flipY'] ?? false,
      offset: Offset(map['x'] ?? 0, map['y'] ?? 0),
      rotation: map['rotation'] ?? 0,
      scale: map['scale'] ?? 1,
    );

    switch (map['type']) {
      case 'text':
        String fontName =
            map['fontStyle'].toString().replaceAll(" ", "").toLowerCase();

        TextStyle fontStyleMap = getTextStyleGoogle(fontName);

        return TextLayerData(
          flipX: layer.flipX,
          flipY: layer.flipY,
          offset: layer.offset,
          rotation: layer.rotation,
          scale: layer.scale,
          text: map['text'] ?? '-',
          fontStyle: fontStyleMap,
          colorMode: LayerBackgroundColorModeE.values
              .firstWhere((element) => element.name == map['colorMode']),
          color: Color(map['color']),
          background: Color(map['background']),
          colorPickerPosition: map['colorPickerPosition'] ?? 0,
          align: TextAlign.values
              .firstWhere((element) => element.name == map['align']),
        );
      case 'emoji':
        return EmojiLayerData(
          flipX: layer.flipX,
          flipY: layer.flipY,
          offset: layer.offset,
          rotation: layer.rotation,
          scale: layer.scale,
          emoji: map['emoji'],
        );
      case 'painting':
        return PaintingLayerData(
          flipX: layer.flipX,
          flipY: layer.flipY,
          offset: layer.offset,
          rotation: layer.rotation,
          scale: layer.scale,
          rawSize: Size(
            map['rawSize']?['w'] ?? 0,
            map['rawSize']?['h'] ?? 0,
          ),
          item: PaintedModel.fromMap(map['item'] ?? {}),
        );
      case 'sticker':
        int stickerPosition = map['listPosition'] ?? -1;
        Widget sticker = kDebugMode
            ? Text(
                'Sticker $stickerPosition not found',
                style: const TextStyle(color: Colors.red, fontSize: 24),
              )
            : const SizedBox.shrink();
        if (stickers.isNotEmpty && stickers.length > stickerPosition) {
          sticker = Image.memory(
            stickers[stickerPosition],
            width: 100,
            height: 100,
          );
        }

        return StickerLayerData(
          flipX: layer.flipX,
          flipY: layer.flipY,
          offset: layer.offset,
          rotation: layer.rotation,
          scale: layer.scale,
          sticker: sticker,
        );
      default:
        return layer;
    }
  }

  /// Generates a unique ID based on the current time.
  String _generateUniqueId() {
    const String characters =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';

    final Random random = Random();
    final String timestamp = (DateTime.now().millisecondsSinceEpoch ~/ 1000)
        .toRadixString(36)
        .padLeft(8, '0');

    String randomPart = '';
    for (int i = 0; i < 20; i++) {
      randomPart += characters[random.nextInt(characters.length)];
    }

    return '$timestamp$randomPart';
  }

  /// Converts this transform object to a Map.
  ///
  /// Returns a Map representing the properties of this layer object,
  /// including the X and Y coordinates, rotation angle, scale factors, and
  /// flip flags.
  Map toMap() {
    return {
      'x': offset.dx,
      'y': offset.dy,
      'rotation': rotation,
      'scale': scale,
      'flipX': flipX,
      'flipY': flipY,
      'type': 'default',
    };
  }
}

/// Represents a text layer with customizable properties.
class TextLayerData extends Layer {
  /// The text content of the layer.
  String text;

  /// The color mode for the text.
  LayerBackgroundColorModeE? colorMode;

  /// The text color.
  Color color;

  /// The background color for the text.
  Color background;

  /// The position of the color picker (if applicable).
  double? colorPickerPosition;

  /// The text alignment within the layer.
  TextAlign align;

  /// The font scale for text, to make text bigger or smaller.
  double fontScale;

  /// A custom text style for the text. Be careful the editor allow not to import
  /// and export this style.
  TextStyle? fontStyle = GoogleFonts.roboto();

  /// Creates a new text layer with customizable properties.
  ///
  /// The [text] parameter specifies the text content of the layer.
  /// The [colorMode] parameter sets the color mode for the text.
  /// The [colorPickerPosition] parameter sets the position of the color picker (if applicable).
  /// The [color] parameter specifies the text color (default is Colors.white).
  /// The [background] parameter defines the background color for the text (default is Colors.transparent).
  /// The [align] parameter determines the text alignment within the layer (default is TextAlign.left).
  /// The other optional parameters such as [textStyle], [offset], [rotation], [scale], [id], [flipX], and [flipY]
  /// can be used to customize the position, appearance, and behavior of the text layer.
  TextLayerData({
    required this.text,
    this.colorMode,
    this.colorPickerPosition,
    required this.fontStyle,
    this.color = Colors.white,
    this.background = Colors.transparent,
    this.align = TextAlign.left,
    this.fontScale = 1.0,
    super.offset,
    super.rotation,
    super.scale,
    super.id,
    super.flipX,
    super.flipY,
  });

  @override
  Map toMap() {
    return {
      ...super.toMap(),
      'text': text,
      'colorMode': LayerBackgroundColorModeE.values[colorMode?.index ?? 0].name,
      'color': color.value,
      'background': background.value,
      'colorPickerPosition': colorPickerPosition ?? 0,
      'align': align.name,
      'fontScale': fontScale,
      'fontStyle': fontStyle!.fontFamily!,
      'type': 'text',
    };
  }
}

/// A class representing a layer with emoji content.
///
/// EmojiLayerData is a subclass of [Layer] that allows you to display emoji
/// on a canvas. You can specify the emoji to display, along with optional
/// properties like offset, rotation, scale, and more.
///
/// Example usage:
/// ```dart
/// EmojiLayerData(
///   emoji: '😀',
///   offset: Offset(100.0, 100.0),
///   rotation: 45.0,
///   scale: 2.0,
/// );
/// ```
class EmojiLayerData extends Layer {
  /// The emoji to display on the layer.
  String emoji;

  /// Creates an instance of EmojiLayerData.
  ///
  /// The [emoji] parameter is required, and other properties are optional.
  EmojiLayerData({
    required this.emoji,
    super.offset,
    super.rotation,
    super.scale,
    super.id,
    super.flipX,
    super.flipY,
  });

  @override
  Map toMap() {
    return {
      ...super.toMap(),
      'emoji': emoji,
      'type': 'emoji',
    };
  }
}

/// A class representing a layer with custom painting content.
///
/// PaintingLayerData is a subclass of [Layer] that allows you to display
/// custom-painted content on a canvas. You can specify the painted item and
/// its raw size, along with optional properties like offset, rotation,
/// scale, and more.
///
/// Example usage:
/// ```dart
/// PaintingLayerData(
///   item: CustomPaintedItem(),
///   rawSize: Size(200.0, 150.0),
///   offset: Offset(50.0, 50.0),
///   rotation: -30.0,
///   scale: 1.5,
/// );
/// ```
class PaintingLayerData extends Layer {
  /// The custom-painted item to display on the layer.
  final PaintedModel item;

  /// The raw size of the painted item before applying scaling.
  final Size rawSize;

  /// Creates an instance of PaintingLayerData.
  ///
  /// The [item] and [rawSize] parameters are required, and other properties
  /// are optional.
  PaintingLayerData({
    required this.item,
    required this.rawSize,
    super.offset,
    super.rotation,
    super.scale,
    super.id,
    super.flipX,
    super.flipY,
  });

  /// Returns the size of the layer after applying the scaling factor.
  Size get size => Size(rawSize.width * scale, rawSize.height * scale);

  @override
  Map toMap() {
    return {
      ...super.toMap(),
      'item': item.toMap(),
      'rawSize': {
        'w': rawSize.width,
        'h': rawSize.height,
      },
      'type': 'painting',
    };
  }
}

/// A class representing a layer with custom sticker content.
///
/// StickerLayerData is a subclass of [Layer] that allows you to display
/// custom sticker content. You can specify properties like offset, rotation,
/// scale, and more.
///
/// Example usage:
/// ```dart
/// StickerLayerData(
///   offset: Offset(50.0, 50.0),
///   rotation: -30.0,
///   scale: 1.5,
/// );
/// ```
class StickerLayerData extends Layer {
  /// The sticker to display on the layer.
  Widget sticker;

  /// Creates an instance of StickerLayerData.
  ///
  /// The [sticker] parameter is required, and other properties are optional.
  StickerLayerData({
    required this.sticker,
    super.offset,
    super.rotation,
    super.scale,
    super.id,
    super.flipX,
    super.flipY,
  });

  /// Converts this transform object to a Map suitable for representing a sticker.
  ///
  /// Returns a Map representing the properties of this transform object, augmented
  /// with the specified [listPosition] indicating the position of the sticker in a list.
  Map toStickerMap(int listPosition) {
    return {
      ...toMap(),
      'listPosition': listPosition,
      'type': 'sticker',
    };
  }
}
