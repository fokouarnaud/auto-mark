import 'dart:io';
import 'package:injectable/injectable.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:uuid/uuid.dart';
import 'package:logger/logger.dart';
import 'package:correction_auto/features/ocr/domain/ocr_service.dart' as domain;

@LazySingleton(as: domain.OCRService)
class MLKitOCRService implements domain.OCRService {
  final TextRecognizer _textRecognizer;
  final Logger _logger;
  
  MLKitOCRService(this._logger) : _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
  
  @override
  Future<domain.OCRResult> recognizeText(File imageFile) async {
    _logger.i('Starting OCR on image: ${imageFile.path}');
    
    try {
      final InputImage inputImage = InputImage.fromFile(imageFile);
      final recognizedText = await _textRecognizer.processImage(inputImage);
      
      return _mapToOCRResult(recognizedText);
    } catch (e) {
      _logger.e('Error during OCR processing: ${e.toString()}');
      throw Exception('OCR processing failed: $e');
    }
  }
  
  @override
  Future<List<domain.DocumentSegment>> segmentDocument(domain.OCRResult ocrResult) async {
    _logger.i('Segmenting document with ${ocrResult.blocks.length} blocks');
    
    final List<domain.DocumentSegment> segments = [];
    final RegExp questionNumberRegex = RegExp(r'^\s*(\d+)[\.:\)]?\s*');
    
    for (final block in ocrResult.blocks) {
      // Check if the block is a question number
      final String blockText = block.text.trim();
      final RegExpMatch? match = questionNumberRegex.firstMatch(blockText);
      
      if (match != null) {
        // This block contains a question number
        final int questionNumber = int.parse(match.group(1)!);
        
        // Extract the question number part
        final String questionNumberText = match.group(0)!;
        segments.add(domain.DocumentSegment(
          id: const Uuid().v4(),
          type: domain.SegmentType.questionNumber,
          text: questionNumberText.trim(),
          block: block,
          questionNumber: questionNumber,
        ));
        
        // The rest is likely the question text
        if (blockText.length > questionNumberText.length) {
          final String questionText = blockText.substring(questionNumberText.length).trim();
          if (questionText.isNotEmpty) {
            segments.add(domain.DocumentSegment(
              id: const Uuid().v4(),
              type: domain.SegmentType.questionText,
              text: questionText,
              block: block,
              questionNumber: questionNumber,
            ));
          }
        }
      } else {
        // Check if this block could be an answer to a previous question
        final int? lastQuestionNumber = _findLastQuestionNumber(segments);
        if (lastQuestionNumber != null) {
          segments.add(domain.DocumentSegment(
            id: const Uuid().v4(),
            type: domain.SegmentType.answerText,
            text: blockText,
            block: block,
            questionNumber: lastQuestionNumber,
          ));
        } else {
          // Fallback - unknown segment type
          segments.add(domain.DocumentSegment(
            id: const Uuid().v4(),
            type: domain.SegmentType.unknown,
            text: blockText,
            block: block,
          ));
        }
      }
    }
    
    _logger.i('Document segmentation completed. Found ${segments.length} segments');
    return segments;
  }
  
  int? _findLastQuestionNumber(List<domain.DocumentSegment> segments) {
    // Find the last question number in the segments
    for (int i = segments.length - 1; i >= 0; i--) {
      if (segments[i].questionNumber != null) {
        return segments[i].questionNumber;
      }
    }
    return null;
  }
  
  domain.OCRResult _mapToOCRResult(RecognizedText recognizedText) {
    final List<domain.TextBlock> blocks = [];
    
    for (final TextBlock block in recognizedText.blocks) {
      final List<domain.TextLine> lines = [];
      
      for (final TextLine line in block.lines) {
        final List<domain.TextElement> elements = [];
        
        for (final TextElement element in line.elements) {
          elements.add(domain.TextElement(
            id: const Uuid().v4(),
            text: element.text,
            boundingBox: _mapToRect(element.boundingBox),
            confidence: 0, // ML Kit doesn't provide confidence scores for elements
          ));
        }
        
        lines.add(domain.TextLine(
          id: const Uuid().v4(),
          text: line.text,
          boundingBox: _mapToRect(line.boundingBox),
          elements: elements,
          confidence: 0, // ML Kit doesn't provide confidence scores for lines
        ));
      }
      
      blocks.add(domain.TextBlock(
        id: const Uuid().v4(),
        text: block.text,
        boundingBox: _mapToRect(block.boundingBox),
        lines: lines,
        confidence: 0, // ML Kit doesn't provide confidence scores for blocks
      ));
    }
    
    return domain.OCRResult(
      text: recognizedText.text,
      blocks: blocks,
    );
  }
  
  domain.Rect _mapToRect(dynamic originalRect) {
    // Utiliser directement les propriétés du rectangle sans vérifier son type
    double left = 0, top = 0, right = 0, bottom = 0;
    
    try {
      left = originalRect.left.toDouble();
      top = originalRect.top.toDouble();
      right = originalRect.right.toDouble();
      bottom = originalRect.bottom.toDouble();
    } catch (e) {
      // Si un problème survient, on utilise un rectangle par défaut
      _logger.e('Error mapping rectangle: ${e.toString()}');
    }
    
    return domain.Rect(
      left: left,
      top: top,
      right: right,
      bottom: bottom,
    );
  }
}
