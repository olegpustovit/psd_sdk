import 'dart:typed_data';

/// A base class that provides common functionality for handling binary file data.
///
/// This class serves as a foundation for working with binary data in memory,
/// providing convenient access to different representations of the data:
/// - Raw bytes as [Uint8List]
/// - Byte buffer as [ByteBuffer]
/// - Byte data as [ByteData]
///
/// The class maintains internal state to efficiently provide these different
/// representations while minimizing memory usage and conversions.
///
/// Example usage:
/// ```dart
/// final file = File();
/// file.setByteData(Uint8List.fromList([1, 2, 3, 4]));
/// print(file.bytes); // Uint8List(4) [1, 2, 3, 4]
/// print(file.getSize()); // 4
/// ```
class File {
  /// Returns the raw bytes of the file as a [Uint8List].
  ///
  /// Returns `null` if no data has been set.
  Uint8List? get bytes => uint8list;

  /// Returns the underlying [ByteBuffer] of the file data.
  ///
  /// This provides direct access to the buffer that contains the file's bytes.
  /// Returns `null` if no data has been set.
  ByteBuffer? get buffer => uint8list?.buffer;

  /// Returns the file data as a [ByteData] view.
  ///
  /// This provides a typed view of the underlying bytes, allowing for
  /// efficient reading of different numeric types.
  /// Returns `null` if no data has been set.
  ByteData? get byteData => _byteData;

  /// Returns the size of the file in bytes.
  ///
  /// Returns 0 if no data has been set.
  int getSize() => uint8list?.length ?? 0;

  /// Internal storage for the raw bytes of the file.
  Uint8List? uint8list;

  /// Internal storage for the byte data view of the file.
  ByteData? _byteData;

  /// Creates a new empty [File] instance.
  ///
  /// The instance will have no data until [setByteData] is called.
  File()
      : uint8list = null,
        _byteData = null;

  /// Creates a new [File] instance from the provided [Uint8List].
  ///
  /// This constructor initializes the file with the provided byte data,
  /// converting it to the appropriate internal representations.
  ///
  /// The [data] parameter must not be null.
  File.fromByteData(Uint8List data)
      : uint8list = data,
        _byteData = ByteData.sublistView(data);

  /// Sets the file data from a [Uint8List].
  ///
  /// This method updates all internal representations of the file data
  /// to match the provided bytes.
  ///
  /// The [data] parameter must not be null.
  void setByteData(Uint8List data) {
    uint8list = data;
    _byteData = ByteData.sublistView(data);
  }
}
