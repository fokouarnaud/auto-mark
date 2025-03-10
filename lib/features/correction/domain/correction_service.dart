import 'dart:io';
import 'package:injectable/injectable.dart';
import 'package:correction_auto/domain/entities/reference.dart';
import 'package:correction_auto/domain/entities/correction.dart';
import 'package:correction_auto/features/ocr/domain/ocr_service.dart';
import 'package:correction_auto/features/text_analysis/domain/text_analyzer.dart';

abstract class CorrectionService {
  /// Analyse une copie d'élève à partir d'une image et d'une référence
  Future<Correction> analyzeStudentPaper({
    required File imageFile,
    required Reference reference,
    required String studentName,
  });
  
  /// Met à jour la correction manuelle d'une réponse
  Future<Correction> updateAnswerEvaluation({
    required Correction correction,
    required String answerId,
    required int earnedPoints,
    String? feedback,
  });
  
  /// Exporte une correction au format PDF
  Future<File> exportToPdf(Correction correction, Reference reference);
}

@Injectable(as: CorrectionService)
class CorrectionServiceImpl implements CorrectionService {
  final OCRService _ocrService;
  final TextAnalyzer _textAnalyzer;
  
  CorrectionServiceImpl(this._ocrService, this._textAnalyzer);
  
  @override
  Future<Correction> analyzeStudentPaper({
    required File imageFile,
    required Reference reference,
    required String studentName,
  }) async {
    // 1. Effectuer la reconnaissance OCR
    final ocrResult = await _ocrService.recognizeText(imageFile);
    
    // 2. Segmenter le document
    final segments = await _ocrService.segmentDocument(ocrResult);
    
    // 3. Associer les segments aux questions
    final Map<int, String> questionAnswers = {};
    
    for (final segment in segments) {
      if (segment.type == SegmentType.answerText && segment.questionNumber != null) {
        // Récupérer ou créer la réponse pour cette question
        questionAnswers[segment.questionNumber!] = 
            (questionAnswers[segment.questionNumber] ?? '') + ' ' + segment.text;
      }
    }
    
    // 4. Analyser les réponses et calculer les scores
    final List<AnswerEvaluation> evaluations = [];
    
    for (final question in reference.questions) {
      final String studentAnswer = questionAnswers[question.number] ?? '';
      
      // Analyser la similarité entre la réponse attendue et la réponse de l'élève
      final analysisResult = await _textAnalyzer.analyzeSimilarity(
        question.expectedAnswer, 
        studentAnswer
      );
      
      // Calculer le score basé sur la similarité
      final double scorePercentage = analysisResult.similarityScore;
      final int earnedPoints = (scorePercentage * question.points).round();
      
      // Créer l'évaluation
      final evaluation = AnswerEvaluation.create(
        question: question,
        studentAnswer: studentAnswer,
        earnedPoints: earnedPoints,
        confidence: analysisResult.confidence,
        feedback: _generateFeedback(
          analysisResult: analysisResult,
          earnedPoints: earnedPoints,
          maxPoints: question.points,
        ),
      );
      
      evaluations.add(evaluation);
    }
    
    // 5. Créer et retourner la correction
    return Correction.create(
      referenceId: reference.id,
      studentName: studentName,
      imagePath: imageFile.path,
      answers: evaluations,
    );
  }
  
  @override
  Future<Correction> updateAnswerEvaluation({
    required Correction correction,
    required String answerId,
    required int earnedPoints,
    String? feedback,
  }) async {
    // Trouver et mettre à jour l'évaluation correspondante
    final List<AnswerEvaluation> updatedAnswers = correction.answers.map((answer) {
      if (answer.id == answerId) {
        return answer.copyWith(
          earnedPoints: earnedPoints,
          feedback: feedback,
        );
      }
      return answer;
    }).toList();
    
    // Créer une version mise à jour de la correction
    return correction.copyWith(answers: updatedAnswers);
  }
  
  @override
  Future<File> exportToPdf(Correction correction, Reference reference) async {
    // Cette fonctionnalité sera implémentée plus tard
    throw UnimplementedError('Export PDF not implemented yet');
  }
  
  String? _generateFeedback({
    required TextAnalysisResult analysisResult,
    required int earnedPoints,
    required int maxPoints,
  }) {
    if (earnedPoints >= maxPoints) {
      return 'Excellent travail !';
    } else if (earnedPoints > maxPoints * 0.7) {
      return 'Bonne réponse, mais quelques éléments manquants.';
    } else if (earnedPoints > maxPoints * 0.4) {
      final missingKeywordsList = analysisResult.missingKeywords.take(3).join(', ');
      return 'Réponse partielle. Éléments manquants: $missingKeywordsList';
    } else {
      return 'Réponse incorrecte ou incomplète.';
    }
  }
}
