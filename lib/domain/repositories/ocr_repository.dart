import 'dart:typed_data';
import 'dart:ui';

/// Contract for OCR text extraction from images.
abstract class OcrRepository {
  /// Extracts text from raw image bytes.
  Future<OcrResult> extractText(Uint8List imageBytes);

  /// Extracts text from an image file on disk.
  Future<OcrResult> extractTextFromFile(String filePath);
}

/// Result of an OCR extraction.
class OcrResult {
  final String fullText;
  final List<OcrTextBlock> blocks;
  final Duration processingTime;
  final bool success;
  final String? errorMessage;

  const OcrResult({
    required this.fullText,
    required this.blocks,
    required this.processingTime,
    required this.success,
    this.errorMessage,
  });

  factory OcrResult.failure(String message, Duration time) => OcrResult(
        fullText: '',
        blocks: const [],
        processingTime: time,
        success: false,
        errorMessage: message,
      );
}

/// A block of recognized text with spatial information.
class OcrTextBlock {
  final String text;
  final Rect boundingBox;
  final double confidence;
  final List<OcrTextLine> lines;

  const OcrTextBlock({
    required this.text,
    required this.boundingBox,
    required this.confidence,
    required this.lines,
  });
}

/// A single line within an OCR text block.
class OcrTextLine {
  final String text;
  final Rect boundingBox;
  final double confidence;

  const OcrTextLine({
    required this.text,
    required this.boundingBox,
    required this.confidence,
  });
}
