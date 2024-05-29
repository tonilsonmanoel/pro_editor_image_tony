import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:pro_image_editor_tony/utils/converters.dart';

import '../fake/fake_image.dart';

void main() {
  group('converters tests', () {
    test('fetchImageAsUint8List', () async {
      mockNetworkImagesFor(() async {
        final Uint8List imageBytes =
            await fetchImageAsUint8List(fakeNetworkImage);

        expect(imageBytes, isNotNull);
      });
    });

    test('readFileAsUint8List', () async {
      final Uint8List fileBytes = await readFileAsUint8List(fakeFileImage);

      expect(fileBytes, isNotNull);
    });
  });
}
