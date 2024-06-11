import 'dart:io';
import 'dart:typed_data';

import 'package:example/pages/preview_img.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pro_image_editor_tony/models/layer.dart';
import 'package:pro_image_editor_tony/modules/paint_editor/utils/draw/draw_canvas.dart';
import 'package:pro_image_editor_tony/pro_image_editor.dart';
import 'dart:ui' as ui;

class HistoryEditor extends StatefulWidget {
  const HistoryEditor({super.key, required this.editorHistory});
  final File editorHistory;
  @override
  State<HistoryEditor> createState() => _HistoryEditorState();
}

class _HistoryEditorState extends State<HistoryEditor> {
  late Uint8List _transparentBytes;
  double _transparentAspectRatio = -1;
  Uint8List? editedBytes;

  /// Better sense of scale when we start with a large number
  final double _initScale = 20;

  Future<void> _createTransparentImage(double aspectRatio) async {
    if (_transparentAspectRatio == aspectRatio) return;

    /// The larger the value, the more precise but also slower.
    double minSize = 500;

    double width = aspectRatio < 1 ? minSize : minSize * aspectRatio;
    double height = aspectRatio < 1 ? minSize / aspectRatio : minSize;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(
        recorder, Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()));
    final paint = Paint()..color = Colors.transparent;
    canvas.drawRect(
        Rect.fromLTWH(0.0, 0.0, width.toDouble(), height.toDouble()), paint);

    final picture = recorder.endRecording();
    final img = await picture.toImage(width.toInt(), height.toInt());
    final pngBytes = await img.toByteData(format: ui.ImageByteFormat.png);

    _transparentAspectRatio = aspectRatio;
    _transparentBytes = pngBytes!.buffer.asUint8List();
  }

  // Build Stick
  final _editor = GlobalKey<ProImageEditorState>();
  var statHistory;
  XFile? galaryXFile;
  XFile? cameraXFile;

  @override
  void initState() {
    super.initState();
  }

  Future selectImgGalery() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    galaryXFile = image;
  }

  Future selectImgCamera() async {
    final ImagePicker picker = ImagePicker();
    final XFile? photo = await picker.pickImage(source: ImageSource.camera);
    if (photo == null) return;

    cameraXFile = photo;
  }

  //Fim Build Stick

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () async {
        var width = MediaQuery.of(context).size.width;
        var height = MediaQuery.of(context).size.height;

        double imgRatio = 1; // set the aspect ratio from your image.
        Size editorSize = Size(
          width - MediaQuery.of(context).padding.horizontal,
          height -
              kToolbarHeight -
              kBottomNavigationBarHeight -
              MediaQuery.of(context).padding.vertical,
        );

        await _createTransparentImage(editorSize.aspectRatio);

        if (!context.mounted) return;
        bool inited = false;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                LayoutBuilder(builder: (context, constraints) {
              return Stack(
                children: [
                  CustomPaint(
                    size: Size(constraints.maxWidth, constraints.maxHeight),
                    painter: PixelTransparentPainter(),
                    child: ProImageEditor.memory(
                      _transparentBytes,
                      key: _editor,
                      onImageEditingComplete: (bytes) async {
                        File? document = await _editor.currentState
                            ?.exportStateHistory(
                              // All configurations are optional
                              configs: const ExportEditorConfigs(
                                exportPainting: true,
                                exportText: true,
                                exportCropRotate: false,
                                exportFilter: true,
                                exportEmoji: true,
                                exportSticker: true,
                                historySpan: ExportHistorySpan.all,
                              ),
                            )
                            .toFile()
                            .then(
                          (value) {
                            print("Salve Exportação ${value.path}");
                          },
                        );
                        if (document != null) {
                          print("Parh: ${document.path}");
                        }
                        if (editedBytes != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return PreviewImgPage(imgBytes: editedBytes!);
                              },
                            ),
                          ).whenComplete(() {
                            editedBytes = null;
                          });
                        }
                      },
                      onCloseEditor: () async {
                        if (editedBytes == null) {
                          Navigator.pop(context);
                        }
                      },
                      onUpdateUI: () {
                        if (!inited) {
                          inited = true;
                        }
                      },
                      configs: ProImageEditorConfigs(
                        initStateHistory: ImportStateHistory.fromJsonFile(
                          widget.editorHistory,
                          configs: ImportEditorConfigs(
                              recalculateSizeAndPosition: true),
                        ),
                        layerInteraction: LayerInteraction(
                          /// Choose between `auto`, `enabled` and `disabled`.
                          ///
                          /// Mode `auto`:
                          /// Automatically determines if the layer is selectable based on the device type.
                          /// If the device is a desktop-device, the layer is selectable; otherwise, the layer is not selectable.
                          selectable: LayerInteractionSelectable.enabled,
                          initialSelected: true,
                        ),
                        removeTransparentAreas: true,

                        /// Crop-Rotate, Filter and Blur editors are not supported
                        cropRotateEditorConfigs:
                            const CropRotateEditorConfigs(enabled: false),
                        filterEditorConfigs:
                            const FilterEditorConfigs(enabled: false),
                        blurEditorConfigs:
                            const BlurEditorConfigs(enabled: false),
                        imageEditorTheme: const ImageEditorTheme(
                          uiOverlayStyle: SystemUiOverlayStyle(
                            statusBarColor: Colors.black,
                          ),
                          background: Colors.transparent,

                          /// Optionally remove background
                          /// paintingEditor: PaintingEditorTheme(background: Colors.transparent),
                          /// cropRotateEditor: CropRotateEditorTheme(background: Colors.transparent),
                          /// filterEditor: FilterEditorTheme(background: Colors.transparent),
                          /// blurEditor: BlurEditorTheme(background: Colors.transparent),
                        ),
                        i18n: const I18n(
                            cancel: "Cancelar",
                            done: "Feito",
                            doneLoadingMsg:
                                "As alterações estão sendo aplicadas",
                            emojiEditor: I18nEmojiEditor(search: "Procurar"),
                            layerInteraction: I18nLayerInteraction(
                              edit: "Editar",
                              remove: "Remover",
                              rotateScale: "Girar",
                            ),
                            paintEditor: const I18nPaintingEditor(
                              arrow: "Seta",
                              back: "Voltar",
                              circle: "Círculo",
                              done: "Feito",
                              bottomNavigationBarText: "Desenho",
                              line: "Linha",
                              lineWidth: "Tamanho da linha",
                              rectangle: "Retângulo",
                              redo: "Refazer",
                              toggleFill: "Alternar Preenchimento",
                              undo: "Desfazer",
                            ),
                            redo: "Refazer",
                            remove: "Remover",
                            undo: "Desfazer",
                            textEditor: I18nTextEditor(
                                back: "Voltar",
                                backgroundMode: "Modo de Fundo",
                                bottomNavigationBarText: "Texto",
                                done: "Feito",
                                fontScale: "Escala da Fonte",
                                inputHintText: "Digite um Texto",
                                textAlign: "Alinhamento de Texto"),
                            stickerEditor: I18nStickerEditor(
                                bottomNavigationBarText: "Add Imagem")),
                        stickerEditorConfigs: StickerEditorConfigs(
                          enabled: true,
                          buildStickers: (setLayer) {
                            /*
                            return Container(
                              child: ElevatedButton(
                                  onPressed: () {
                                    Widget widgetImg = Image.asset(
                                      'assets/demo.png',
                                      fit: BoxFit.contain,
                                    );

                                    setLayer(widgetImg);
                                  },
                                  child: Text("Add Imagem")),
                            );
                            */

                            return ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(15)),
                              child: Container(
                                  width: 800,
                                  // ignore: prefer_const_constructors
                                  color: Color.fromARGB(255, 5, 5, 5),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(top: 10),
                                        child: Text(
                                          "Selecione uma Imagem ",
                                          style: GoogleFonts.roboto(
                                              fontSize: 20,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          ElevatedButton.icon(
                                              style: const ButtonStyle(
                                                  backgroundColor:
                                                      WidgetStatePropertyAll(
                                                          Colors.white)),
                                              onPressed: () async {
                                                Widget widgetImg;

                                                await selectImgCamera()
                                                    .then((value) {
                                                  if (cameraXFile != null) {
                                                    showDialog(
                                                      context: context,
                                                      builder: (context) {
                                                        return AlertDialog(
                                                          actionsPadding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  right: 20),
                                                          contentPadding:
                                                              EdgeInsets.zero,
                                                          backgroundColor:
                                                              const Color
                                                                  .fromARGB(
                                                                  255, 5, 5, 5),
                                                          surfaceTintColor:
                                                              const Color
                                                                  .fromARGB(
                                                                  255, 5, 5, 5),
                                                          actions: [
                                                            TextButton(
                                                                onPressed: () {
                                                                  Navigator.pop(
                                                                      context);
                                                                },
                                                                child: Text(
                                                                  "Cancelar",
                                                                  style: GoogleFonts
                                                                      .roboto(
                                                                          color:
                                                                              Colors.red),
                                                                )),
                                                            TextButton(
                                                                onPressed: () {
                                                                  widgetImg =
                                                                      Image
                                                                          .file(
                                                                    File(cameraXFile!
                                                                        .path),
                                                                    height: 300,
                                                                    width: 600,
                                                                    fit: BoxFit
                                                                        .contain,
                                                                  );
                                                                  Navigator.pop(
                                                                      context);
                                                                  setLayer(
                                                                      widgetImg);
                                                                  setState(() {
                                                                    cameraXFile =
                                                                        null;
                                                                  });
                                                                },
                                                                child: Text(
                                                                  "Confirmar",
                                                                  style: GoogleFonts
                                                                      .roboto(),
                                                                ))
                                                          ],
                                                          content: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    top: 5),
                                                            child: Image.file(
                                                              File(cameraXFile!
                                                                  .path),
                                                              height: 300,
                                                              width: 600,
                                                              fit: BoxFit
                                                                  .contain,
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    );
                                                  }
                                                });
                                              },
                                              icon: const Icon(
                                                  Icons.photo_camera),
                                              label: const Text("Tirar foto")),
                                          ElevatedButton.icon(
                                              style: const ButtonStyle(
                                                  backgroundColor:
                                                      WidgetStatePropertyAll(
                                                          Colors.white)),
                                              onPressed: () async {
                                                Widget widgetImg;

                                                await selectImgGalery()
                                                    .then((value) {
                                                  if (galaryXFile != null) {
                                                    showDialog(
                                                      context: context,
                                                      builder: (context) {
                                                        return AlertDialog(
                                                          actionsPadding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  right: 20),
                                                          backgroundColor:
                                                              const Color
                                                                  .fromARGB(
                                                                  255, 5, 5, 5),
                                                          surfaceTintColor:
                                                              const Color
                                                                  .fromARGB(
                                                                  255, 5, 5, 5),
                                                          actions: [
                                                            TextButton(
                                                                onPressed: () {
                                                                  Navigator.pop(
                                                                      context);
                                                                },
                                                                child: Text(
                                                                  "Cancelar",
                                                                  style: GoogleFonts
                                                                      .roboto(
                                                                          color:
                                                                              Colors.red),
                                                                )),
                                                            TextButton(
                                                                onPressed: () {
                                                                  widgetImg =
                                                                      Image
                                                                          .file(
                                                                    File(galaryXFile!
                                                                        .path),
                                                                    fit: BoxFit
                                                                        .contain,
                                                                  );
                                                                  Navigator.pop(
                                                                      context);
                                                                  setLayer(
                                                                      widgetImg);
                                                                  setState(() {
                                                                    galaryXFile =
                                                                        null;
                                                                  });
                                                                },
                                                                child: Text(
                                                                  "Confirma",
                                                                  style: GoogleFonts
                                                                      .roboto(),
                                                                ))
                                                          ],
                                                          content: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    top: 5),
                                                            child: Image.file(
                                                              File(galaryXFile!
                                                                  .path),
                                                              fit: BoxFit
                                                                  .contain,
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    );
                                                  }
                                                });
                                              },
                                              icon: const Icon(Icons.image),
                                              label: const Text(
                                                  "Escolher existente...")),
                                        ],
                                      ),
                                    ],
                                  )),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 2 * kBottomNavigationBarHeight,
                    left: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.lightBlue.shade200,
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(100),
                          bottomRight: Radius.circular(100),
                        ),
                      ),
                      child: IconButton(
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (context) {
                              return ReorderLayerSheet(
                                layers: _editor.currentState!.activeLayers,
                                onReorder: (oldIndex, newIndex) {
                                  _editor.currentState!.moveLayerListPosition(
                                    oldIndex: oldIndex,
                                    newIndex: newIndex,
                                  );
                                  Navigator.pop(context);
                                },
                              );
                            },
                          );
                        },
                        icon: const Icon(Icons.reorder),
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),
        );
      },
      leading: const Icon(Icons.pan_tool_alt_outlined),
      title: const Text('Movable background image'),
      trailing: const Icon(Icons.chevron_right),
    );
  }
}

class PixelTransparentPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const cellSize = 22.0; // Size of each square
    final numCellsX = size.width / cellSize;
    final numCellsY = size.height / cellSize;
    const grayColor = Color(0xFFE2E2E2); // Gray color
    const whiteColor = Colors.white; // White color

    for (int row = 0; row < numCellsY; row++) {
      for (int col = 0; col < numCellsX; col++) {
        final color = (row + col) % 2 == 0 ? whiteColor : grayColor;
        canvas.drawRect(
          Rect.fromLTWH(col * cellSize, row * cellSize, cellSize, cellSize),
          Paint()..color = color,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class ReorderLayerSheet extends StatefulWidget {
  final List<Layer> layers;
  final ReorderCallback onReorder;

  const ReorderLayerSheet({
    super.key,
    required this.layers,
    required this.onReorder,
  });

  @override
  State<ReorderLayerSheet> createState() => _ReorderLayerSheetState();
}

class _ReorderLayerSheetState extends State<ReorderLayerSheet> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Camadas',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
          ),
        ),
        Expanded(
          child: ReorderableListView.builder(
            itemBuilder: (context, index) {
              Layer layer = widget.layers[index];
              return ListTile(
                key: ValueKey(layer),
                title: layer.runtimeType == TextLayerData
                    ? Text(
                        (layer as TextLayerData).text,
                        style: const TextStyle(fontSize: 20),
                      )
                    : layer.runtimeType == EmojiLayerData
                        ? Text(
                            (layer as EmojiLayerData).emoji,
                            style: const TextStyle(fontSize: 24),
                          )
                        : layer.runtimeType == PaintingLayerData
                            ? SizedBox(
                                height: 40,
                                child: FittedBox(
                                  alignment: Alignment.centerLeft,
                                  child: CustomPaint(
                                    size: (layer as PaintingLayerData).size,
                                    willChange: true,
                                    isComplex:
                                        layer.item.mode == PaintModeE.freeStyle,
                                    painter: DrawCanvas(
                                      item: layer.item,
                                      scale: layer.scale,
                                      enabledHitDetection: false,
                                      freeStyleHighPerformanceScaling: false,
                                      freeStyleHighPerformanceMoving: false,
                                    ),
                                  ),
                                ),
                              )
                            : layer.runtimeType == StickerLayerData
                                ? SizedBox(
                                    height: 40,
                                    child: FittedBox(
                                      alignment: Alignment.centerLeft,
                                      child:
                                          (layer as StickerLayerData).sticker,
                                    ),
                                  )
                                : Text(layer.id.toString()),
              );
            },
            itemCount: widget.layers.length,
            onReorder: widget.onReorder,
          ),
        ),
      ],
    );
  }
}
