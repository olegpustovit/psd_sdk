# PSD round-trip capture

Recorded on 23 October 2026 from the cleanup checkout. The commit containing these files identifies the reviewed source. Dart 3.8.0 ran on Linux ARM64.

```sh
dart pub get
dart test
dart analyze
dart run example/round_trip.dart docs/demo/example-colors.psd
```

The original 35 tests passed, but the new synthetic round trip exposed composite reads returning header bytes instead of pixels. File/reader views now retain offsets, and composite conversion reads PSD big-endian values. The three new 8-/16-/32-bit offset-input regressions failed before the fix; all 38 tests and static analysis passed afterward.

The example generates a fictional 2 × 2 RGB PSD, writes one named layer and a merged image, reopens it through the public API, and checks the dimensions, layer name and all three composite channel buffers. example-colors.psd is the actual 156-byte output. output.txt is actual stdout; round-trip.png is a rendered transcript, not Photoshop or an invented app UI.

No real client image, Photoshop session, package publication, complete compression matrix, layer compositing, large-file workload or older SDK was tested. Existing tests cover their own sample cases, including Unicode names; that does not prove every PSD feature. Existing fixtures, license and upstream attribution are preserved.

The existing Dart 2.17 library language level is preserved. The archive 4.0.7 dependency requires Dart 3.0, verified from its [registry metadata](https://pub.dev/api/packages/archive/versions/4.0.7). Development checks used Dart 3.8.0; the manifest lower bound alone is not a working older-SDK dependency combination.
