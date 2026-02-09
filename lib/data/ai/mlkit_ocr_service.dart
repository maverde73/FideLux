import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:path_provider/path_provider.dart';

import '../../domain/repositories/ocr_repository.dart';

/// OCR implementation backed by Google ML Kit (on-device, no network).
class MlkitOcrService implements OcrRepository {
  @override
  Future<OcrResult> extractText(Uint8List imageBytes) async {
    final stopwatch = Stopwatch()..start();
    try {
      // ML Kit requires a file path — write bytes to a temp file.
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/ocr_${DateTime.now().millisecondsSinceEpoch}.jpg');
      await tempFile.writeAsBytes(imageBytes);

      final result = await extractTextFromFile(tempFile.path);

      // Clean up temp file.
      try {
        await tempFile.delete();
      } catch (_) {}

      return result;
    } catch (e) {
      stopwatch.stop();
      return OcrResult.failure('OCR failed: $e', stopwatch.elapsed);
    }
  }

  @override
  Future<OcrResult> extractTextFromFile(String filePath) async {
    final stopwatch = Stopwatch()..start();
    final recognizer = TextRecognizer(script: TextRecognitionScript.latin);

    try {
      final inputImage = InputImage.fromFilePath(filePath);
      final recognized = await recognizer.processImage(inputImage);
      stopwatch.stop();

      final blocks = recognized.blocks.map((block) {
        final lines = block.lines.map((line) {
          return OcrTextLine(
            text: line.text,
            boundingBox: _toRect(line.boundingBox),
            confidence: line.confidence ?? 0.0,
          );
        }).toList();

        // TextBlock doesn't expose confidence — average from its lines.
        final avgConfidence = lines.isEmpty
            ? 0.0
            : lines.map((l) => l.confidence).reduce((a, b) => a + b) / lines.length;

        return OcrTextBlock(
          text: block.text,
          boundingBox: _toRect(block.boundingBox),
          confidence: avgConfidence,
          lines: lines,
        );
      }).toList();

      return OcrResult(
        fullText: recognized.text,
        blocks: blocks,
        processingTime: stopwatch.elapsed,
        success: true,
      );
    } catch (e) {
      stopwatch.stop();
      return OcrResult.failure('OCR failed: $e', stopwatch.elapsed);
    } finally {
      await recognizer.close();
    }
  }

  Rect _toRect(Rect? rect) {
    return rect ?? Rect.zero;
  }
}
