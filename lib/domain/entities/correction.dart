import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';
import 'package:correction_auto/domain/entities/reference.dart';

class Correction extends Equatable {
  final String id;
  final String referenceId;
  final String studentName;
  final DateTime correctionDate;
  final List<AnswerEvaluation> answers;
  final String imagePath;
  final double score;
  final String? comments;

  const Correction({
    required this.id,
    required this.referenceId,
    required this.studentName,
    required this.correctionDate,
    required this.answers,
    required this.imagePath,
    required this.score,
    this.comments,
  });

  factory Correction.create({
    required String referenceId,
    required String studentName,
    required String imagePath,
    required List<AnswerEvaluation> answers,
    String? comments,
  }) {
    // Calculate score based on answers
    final totalPoints = answers.fold(0, (sum, answer) => sum + answer.maxPoints);
    final earnedPoints = answers.fold(0, (sum, answer) => sum + answer.earnedPoints);
    final score = totalPoints > 0 ? (earnedPoints / totalPoints) * 100 : 0;

    return Correction(
      id: const Uuid().v4(),
      referenceId: referenceId,
      studentName: studentName,
      correctionDate: DateTime.now(),
      answers: answers,
      imagePath: imagePath,
      score: double.parse(score.toStringAsFixed(2)),
      comments: comments,
    );
  }

  Correction copyWith({
    String? studentName,
    List<AnswerEvaluation>? answers,
    String? imagePath,
    String? comments,
  }) {
    // Recalculate score if answers change
    double newScore = score;
    if (answers != null) {
      final totalPoints = answers.fold(0, (sum, answer) => sum + answer.maxPoints);
      final earnedPoints = answers.fold(0, (sum, answer) => sum + answer.earnedPoints);
      newScore = totalPoints > 0 ? (earnedPoints / totalPoints) * 100 : 0;
      newScore = double.parse(newScore.toStringAsFixed(2));
    }

    return Correction(
      id: id,
      referenceId: referenceId,
      studentName: studentName ?? this.studentName,
      correctionDate: correctionDate,
      answers: answers ?? this.answers,
      imagePath: imagePath ?? this.imagePath,
      score: newScore,
      comments: comments ?? this.comments,
    );
  }

  @override
  List<Object?> get props => [
        id,
        referenceId,
        studentName,
        correctionDate,
        answers,
        imagePath,
        score,
        comments,
      ];
}

class AnswerEvaluation extends Equatable {
  final String id;
  final String questionId;
  final int questionNumber;
  final String questionText;
  final String expectedAnswer;
  final String studentAnswer;
  final int maxPoints;
  final int earnedPoints;
  final double confidence;
  final String? feedback;

  const AnswerEvaluation({
    required this.id,
    required this.questionId,
    required this.questionNumber,
    required this.questionText,
    required this.expectedAnswer,
    required this.studentAnswer,
    required this.maxPoints,
    required this.earnedPoints,
    required this.confidence,
    this.feedback,
  });

  factory AnswerEvaluation.create({
    required Question question,
    required String studentAnswer,
    required int earnedPoints,
    required double confidence,
    String? feedback,
  }) {
    return AnswerEvaluation(
      id: const Uuid().v4(),
      questionId: question.id,
      questionNumber: question.number,
      questionText: question.text,
      expectedAnswer: question.expectedAnswer,
      studentAnswer: studentAnswer,
      maxPoints: question.points,
      earnedPoints: earnedPoints,
      confidence: confidence,
      feedback: feedback,
    );
  }

  AnswerEvaluation copyWith({
    String? studentAnswer,
    int? earnedPoints,
    double? confidence,
    String? feedback,
  }) {
    return AnswerEvaluation(
      id: id,
      questionId: questionId,
      questionNumber: questionNumber,
      questionText: questionText,
      expectedAnswer: expectedAnswer,
      studentAnswer: studentAnswer ?? this.studentAnswer,
      maxPoints: maxPoints,
      earnedPoints: earnedPoints ?? this.earnedPoints,
      confidence: confidence ?? this.confidence,
      feedback: feedback ?? this.feedback,
    );
  }

  @override
  List<Object?> get props => [
        id,
        questionId,
        questionNumber,
        questionText,
        expectedAnswer,
        studentAnswer,
        maxPoints,
        earnedPoints,
        confidence,
        feedback,
      ];
}
