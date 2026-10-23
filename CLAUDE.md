# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is `psd_sdk`, a Dart library for reading and manipulating Photoshop PSD files. It's a port of the original C++ psd_sdk by Molecular Matters.

## Development Commands

### Build and Dependencies
```bash
# Install dependencies
dart pub get

# Update dependencies
dart pub upgrade
```

### Testing
```bash
# Run all tests
dart test

# Run a specific test file
dart test test/psd_sdk_test.dart

# Run tests with coverage
dart test --coverage=coverage
```

### Code Quality
```bash
# Run static analysis
dart analyze

# Check code formatting
dart format --output=none --set-exit-if-changed lib test

# Format code
dart format lib test

# Run both analyze and format check (recommended before commits)
dart analyze && dart format --output=none --set-exit-if-changed lib test
```

### Running Examples
```bash
# Run the main example
dart run example/psd_sdk_example.dart

# Run the TGA exporter example
dart run example/tga_exporter.dart
```

## Architecture

### Core Structure
The library is organized into parsing and exporting functionality:

- **Parsing**: `Document` class and related parsers handle reading PSD files
- **Exporting**: `ExportDocument` class handles creating new PSD files
- **Data Model**: Classes represent PSD components (layers, channels, masks)

### Key Components

1. **Document Processing Pipeline**:
   - `File` class handles binary data operations
   - `Document.fromFile()` parses PSD header and structure
   - Section parsers (`parse_layer_mask_section`, `parse_image_data_section`, `parse_image_resources_section`) extract specific data

2. **Layer System**:
   - `Layer` represents individual layers with properties and pixel data
   - `LayerMask` and `VectorMask` handle layer masking
   - `Channel` represents color channels within layers
   - Blend modes and layer types are supported through enums

3. **Image Data Handling**:
   - `ImageUtil` provides utilities for pixel data manipulation
   - Compression enums and individual section handlers have different coverage. The merged-image parser handles RAW and RLE; do not infer complete ZIP composite support from an enum.
   - Raw merged-channel round-trip tests cover 8-bit, 16-bit and 32-bit data; this is not coverage of every PSD feature at those depths.
   - Color modes: Grayscale, RGB (CMYK reading supported but not export)

4. **Export System**:
   - `ExportDocument` builds new PSD files programmatically
   - `ExportLayer` manages layer creation
   - Supports updating layer data and writing to file

### Data Flow
1. PSD file → `File` (binary wrapper) → `Document` (parsed structure)
2. `Document` → Section parsers → Structured data (layers, resources, image data)
3. For export: `ExportDocument` → Add layers/data → `write()` → PSD file

### Important Patterns
- Immutable parsing: Original file data is preserved during parsing
- Lazy extraction: Layer pixel data extracted on-demand via `layer.extract()`
- Section-based structure: PSD file divided into logical sections per Adobe spec
- Null safety: All public APIs use Dart's null safety features

## Dependencies

- `archive: ^4.0.7` - Used for ZIP compression/decompression of image data
- Development: `lints: ^6.0.0`, `test: ^1.26.2`

## Dart SDK Constraints

The manifest keeps the existing Dart 2.17 language level. The archive 4.x dependency requires Dart 3 or newer; development lints/tests used Dart 3.8.0. Do not advertise the older manifest lower bound as a working dependency combination.

Use the tested example/round_trip.dart for documentation. Qualify export as limited: a self-round-trip does not prove Photoshop interoperability. Preserve Molecular Matters attribution and the actual BSD 2-Clause license. Never replace source fixtures with client documents or claim enum values establish complete format support.
