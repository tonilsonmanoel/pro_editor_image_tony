import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pro_image_editor_tony/modules/crop_rotate_editor/crop_rotate_editor.dart';
import 'package:pro_image_editor_tony/modules/emoji_editor/emoji_editor.dart';
import 'package:pro_image_editor_tony/modules/filter_editor/filter_editor.dart';
import 'package:pro_image_editor_tony/modules/paint_editor/paint_editor.dart';

import 'package:pro_image_editor_tony/modules/main_editor/main_editor.dart';
import 'package:pro_image_editor_tony/modules/text_editor/text_editor.dart';
import 'package:pro_image_editor_tony/widgets/layer_widget.dart';

import 'fake/fake_image.dart';

void main() {
  testWidgets('ProImageEditor initializes correctly',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: ProImageEditor.memory(
        fakeMemoryImage,
        onImageEditingComplete: (Uint8List bytes) async {},
      ),
    ));

    expect(find.byType(ProImageEditor), findsOneWidget);
  });

  group('ProImageEditor open subeditors', () {
    testWidgets('ProImageEditor opens PaintingEditor',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
          home: ProImageEditor.memory(
        fakeMemoryImage,
        onImageEditingComplete: (Uint8List bytes) async {},
      )));

      final openBtn = find.byKey(const ValueKey('open-painting-editor-btn'));
      expect(openBtn, findsOneWidget);
      await tester.tap(openBtn);

      await tester.pumpAndSettle();
      expect(find.byType(PaintingEditor), findsOneWidget);
    });

    testWidgets('ProImageEditor opens TextEditor', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
          home: ProImageEditor.memory(
        fakeMemoryImage,
        onImageEditingComplete: (Uint8List bytes) async {},
      )));

      final openBtn = find.byKey(const ValueKey('open-text-editor-btn'));
      expect(openBtn, findsOneWidget);
      await tester.tap(openBtn);

      await tester.pumpAndSettle();
      expect(find.byType(TextEditor), findsOneWidget);
    });

    testWidgets('ProImageEditor opens CropRotateEditor',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
          home: ProImageEditor.memory(
        fakeMemoryImage,
        onImageEditingComplete: (Uint8List bytes) async {},
      )));

      final openBtn = find.byKey(const ValueKey('open-crop-rotate-editor-btn'));
      expect(openBtn, findsOneWidget);
      await tester.tap(openBtn);

      await tester.pumpAndSettle();
      expect(find.byType(CropRotateEditor), findsOneWidget);
    });

    testWidgets('ProImageEditor opens FilterEditor',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
          home: ProImageEditor.memory(
        fakeMemoryImage,
        onImageEditingComplete: (Uint8List bytes) async {},
      )));

      final openBtn = find.byKey(const ValueKey('open-filter-editor-btn'));
      expect(openBtn, findsOneWidget);
      await tester.tap(openBtn);

      await tester.pumpAndSettle();
      expect(find.byType(FilterEditor), findsOneWidget);
    });

    testWidgets('ProImageEditor opens EmojiEditor',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
          home: ProImageEditor.memory(
        fakeMemoryImage,
        onImageEditingComplete: (Uint8List bytes) async {},
      )));

      final openBtn = find.byKey(const ValueKey('open-emoji-editor-btn'));
      expect(openBtn, findsOneWidget);
      await tester.tap(openBtn);

      // Wait for the modal bottom sheet animation to complete
      await tester.pump(); // Start the animation
      await tester.pump(const Duration(seconds: 1)); // Wait for it to finish

      expect(find.byType(EmojiEditor), findsOneWidget);
    });
  });

  testWidgets('ProImageEditor performs undo and redo action',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
        home: ProImageEditor.memory(
      fakeMemoryImage,
      onImageEditingComplete: (Uint8List bytes) async {},
    )));

    // Open text editor
    final openBtn = find.byKey(const ValueKey('open-text-editor-btn'));
    expect(openBtn, findsOneWidget);
    await tester.tap(openBtn);

    await tester.pumpAndSettle();

    // Write text text
    await tester.enterText(find.byType(TextField), 'Hello, World!');
    expect(find.text('Hello, World!'), findsOneWidget);

    // Press done button
    final doneBtn = find.byKey(const ValueKey('TextEditorDoneButton'));
    expect(doneBtn, findsOneWidget);
    await tester.tap(doneBtn);
    await tester.pumpAndSettle();

    // Ensure layer is created
    final layers1 = find.byType(LayerWidget);
    expect(layers1, findsOneWidget);

    // Press undo button
    final undoBtn = find.byKey(const ValueKey('TextEditorMainUndoButton'));
    expect(undoBtn, findsOneWidget);
    await tester.tap(undoBtn);
    await tester.pumpAndSettle();

    // Ensure layer is removed
    final layers2 = find.byType(LayerWidget);
    expect(layers2, findsNothing);

    // Press redo button
    final redoBtn = find.byKey(const ValueKey('TextEditorMainRedoButton'));
    expect(redoBtn, findsOneWidget);
    await tester.tap(redoBtn);
    await tester.pumpAndSettle();

    // Ensure layer exist again
    final layers3 = find.byType(LayerWidget);
    expect(layers3, findsOneWidget);
  });

  testWidgets(
      'ProImageEditor performs done action with allowCompleteWithEmptyEditing',
      (WidgetTester tester) async {
    Future test({
      required bool givingAllowCompleteWithEmptyEditing,
      required bool expectedHasCompleteEdit,
    }) async {
      var hasCompleteEdit = false;
      await tester.pumpWidget(MaterialApp(
          home: ProImageEditor.memory(
        fakeMemoryImage,
        allowCompleteWithEmptyEditing: givingAllowCompleteWithEmptyEditing,
        onImageEditingComplete: (Uint8List bytes) async {
          hasCompleteEdit = true;
        },
      )));

      // Press done button without any editing;
      final doneBtn = find.byKey(const ValueKey('TextEditorMainDoneButton'));
      expect(doneBtn, findsOneWidget);
      await tester.tap(doneBtn);
      try {
        await tester.pumpAndSettle();
      } catch (_) {}

      expect(hasCompleteEdit, expectedHasCompleteEdit);
    }

    await test(
        givingAllowCompleteWithEmptyEditing: true,
        expectedHasCompleteEdit: true);
    await test(
        givingAllowCompleteWithEmptyEditing: false,
        expectedHasCompleteEdit: false);
  });
}
