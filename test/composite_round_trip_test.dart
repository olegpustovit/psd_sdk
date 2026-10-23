import 'dart:typed_data';
import 'package:psd_sdk/psd_sdk.dart' as psd;
import 'package:test/test.dart';

void main() {
  for (final depth in [8, 16, 32]) {
    test('$depth-bit composite survives export and offset-backed input', () {
      final List<TypedData> channels;
      if (depth == 8) {
        channels = [
          Uint8List.fromList([255, 0, 64, 128]),
          Uint8List.fromList([0, 255, 128, 64]),
          Uint8List.fromList([10, 20, 30, 40])
        ];
      } else if (depth == 16) {
        channels = [
          Uint16List.fromList([32768, 1, 16384, 8192]),
          Uint16List.fromList([1, 32768, 8192, 16384]),
          Uint16List.fromList([256, 512, 768, 1024])
        ];
      } else {
        channels = [
          Float32List.fromList([1, 0, 0.5, 0.25]),
          Float32List.fromList([0, 1, 0.25, 0.5]),
          Float32List.fromList([0.125, 0.25, 0.5, 1])
        ];
      }
      final output = psd.ExportDocument(2, 2, depth, psd.ExportColorMode.rgb);
      output.updateMergedImage(channels[0], channels[1], channels[2]);
      final encoded = psd.File();
      output.write(encoded);
      final bytes = Uint8List(encoded.bytes!.length + 16);
      bytes.setRange(7, 7 + encoded.bytes!.length, encoded.bytes!);
      final input = psd.File.fromByteData(
          Uint8List.sublistView(bytes, 7, 7 + encoded.bytes!.length));
      final decoded = psd.Document.fromFile(input);
      expect(decoded.width, 2);
      expect(decoded.height, 2);
      final composite = decoded.parseImageDataSection(input)!;
      for (var i = 0; i < 3; i++) {
        expect(composite.images![i]!.data,
            orderedEquals(channels[i].buffer.asUint8List()));
      }
    });
  }
}
