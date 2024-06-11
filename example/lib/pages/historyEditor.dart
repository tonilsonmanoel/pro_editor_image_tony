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
  //Fim Build Stick

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          ListTile(
            onTap: () async {},
            leading: const Icon(Icons.pan_tool_alt_outlined),
            title: const Text('Movable background image'),
            trailing: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }
}
