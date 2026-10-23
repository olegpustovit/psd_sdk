import 'dart:io' as io;
import 'dart:typed_data';
import 'package:psd_sdk/psd_sdk.dart' as psd;

void main(List<String> arguments) {
  final outputPath =
      arguments.isEmpty ? 'example-colors.psd' : arguments.single;
  final red = Uint8List.fromList([255, 0, 0, 255]);
  final green = Uint8List.fromList([0, 255, 0, 255]);
  final blue = Uint8List.fromList([0, 0, 255, 255]);
  final document = psd.ExportDocument(2, 2, 8, psd.ExportColorMode.rgb);
  final layer = document.addLayer(document, 'Example colors');
  if (layer == null) throw StateError('Layer creation failed');
  for (final entry in {
    psd.ExportChannel.red: red,
    psd.ExportChannel.green: green,
    psd.ExportChannel.blue: blue,
  }.entries) {
    document.updateLayer(
        layer, entry.key, 0, 0, 2, 2, entry.value, psd.CompressionType.raw);
  }
  document.updateMergedImage(red, green, blue);
  final encoded = psd.File();
  document.write(encoded);
  io.File(outputPath).writeAsBytesSync(encoded.bytes!);

  final input = psd.File.fromByteData(io.File(outputPath).readAsBytesSync());
  final decoded = psd.Document.fromFile(input);
  final layers = decoded.parseLayerMaskSection(input);
  final image = decoded.parseImageDataSection(input);
  if (decoded.width != 2 ||
      decoded.height != 2 ||
      decoded.bitsPerChannel != 8 ||
      layers?.layers?.single?.name != 'Example colors') {
    throw StateError('Document metadata did not round-trip');
  }
  final expected = [red, green, blue];
  for (var channel = 0; channel < 3; channel++) {
    final data = image?.images?[channel]?.data;
    if (data == null ||
        data.length != 4 ||
        List.generate(4, (i) => data[i] == expected[channel][i])
            .any((matches) => !matches)) {
      throw StateError(
          'Merged channel $channel: $data, expected ${expected[channel]}');
    }
  }
  print('Wrote and reopened a fictional 2 x 2 RGB PSD.');
  print('Depth: ${decoded.bitsPerChannel} bits/channel');
  print(
      'Layers: ${layers!.layers!.length}, name: ${layers.layers!.single!.name}');
  print('Pixels: red, green, blue, white');
  print('All three merged channel buffers match the original bytes.');
  print('PSD size: ${encoded.bytes!.length} bytes');
  print('No Photoshop installation or external file was used.');
}
