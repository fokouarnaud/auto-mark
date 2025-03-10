import 'dart:io';
import 'package:injectable/injectable.dart';

/// Contrat pour les services OCR
abstract class OCRService {
  /// Effectue la reconnaissance de texte sur une image
  Future<OCRResult> recognizeText(File imageFile);
  
  /// Segmente le document en sections (questions, réponses)
  Future<List<DocumentSegment>> segmentDocument(OCRResult ocrResult);
}

/// Résultat d'une opération OCR
class OCRResult {
  /// Le texte complet extrait
  final String text;
  
  /// Les blocs de texte identifiés
  final List<TextBlock> blocks;
  
  OCRResult({
    required this.text,
    required this.blocks,
  });
}

/// Bloc de texte identifié par l'OCR
class TextBlock {
  /// Identifiant unique du bloc
  final String id;
  
  /// Le texte du bloc
  final String text;
  
  /// La position et dimensions du bloc dans l'image
  final Rect boundingBox;
  
  /// Les lignes de texte contenues dans ce bloc
  final List<TextLine> lines;
  
  /// La confiance de la reconnaissance (0-100)
  final double confidence;

  TextBlock({
    required this.id,
    required this.text,
    required this.boundingBox,
    required this.lines,
    required this.confidence,
  });
}

/// Ligne de texte identifiée par l'OCR
class TextLine {
  /// Identifiant unique de la ligne
  final String id;
  
  /// Le texte de la ligne
  final String text;
  
  /// La position et dimensions de la ligne dans l'image
  final Rect boundingBox;
  
  /// Les éléments de texte (mots) contenus dans cette ligne
  final List<TextElement> elements;
  
  /// La confiance de la reconnaissance (0-100)
  final double confidence;

  TextLine({
    required this.id,
    required this.text,
    required this.boundingBox,
    required this.elements,
    required this.confidence,
  });
}

/// Élément de texte (mot) identifié par l'OCR
class TextElement {
  /// Identifiant unique de l'élément
  final String id;
  
  /// Le texte de l'élément
  final String text;
  
  /// La position et dimensions de l'élément dans l'image
  final Rect boundingBox;
  
  /// La confiance de la reconnaissance (0-100)
  final double confidence;

  TextElement({
    required this.id,
    required this.text,
    required this.boundingBox,
    required this.confidence,
  });
}

/// Rectangle définissant une zone
class Rect {
  final double left;
  final double top;
  final double right;
  final double bottom;

  Rect({
    required this.left,
    required this.top,
    required this.right,
    required this.bottom,
  });
  
  double get width => right - left;
  double get height => bottom - top;
}

/// Types de segments de document
enum SegmentType {
  questionNumber,
  questionText,
  answerText,
  unknown,
}

/// Segment de document identifié
class DocumentSegment {
  /// Identifiant unique du segment
  final String id;
  
  /// Le type de segment
  final SegmentType type;
  
  /// Le texte du segment
  final String text;
  
  /// Le bloc de texte associé
  final TextBlock block;
  
  /// Numéro de question associé (si applicable)
  final int? questionNumber;

  DocumentSegment({
    required this.id,
    required this.type,
    required this.text,
    required this.block,
    this.questionNumber,
  });
}
