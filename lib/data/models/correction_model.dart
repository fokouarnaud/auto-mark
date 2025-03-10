import 'package:correction_auto/domain/entities/correction.dart';
import 'package:uuid/uuid.dart';

class CorrectionModel {
  final String id;
  final String referenceId;
  final String studentName;
  final DateTime correctionDate;
  final String imagePath;
  final double score;
  final String? comments;

  CorrectionModel({
    required this.id,
    required this.referenceId,
    required this.studentName,
    required this.correctionDate,
    required this.imagePath,
    required this.score,
    this.comments,
  });

  factory CorrectionModel.fromJson(Map<String, dynamic> json) {
    return CorrectionModel(
      id: json['id'],
      referenceId: json['referenceId'],
      studentName: json['studentName'],
      correctionDate: DateTime.parse(json['correctionDate']),
      imagePath: json['imagePath'],
      score: json['score'],
      comments: json['comments'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'referenceId': referenceId,
      'studentName': studentName,
      'correctionDate': correctionDate.toIso8601String(),
      'imagePath': imagePath,
      'score': score,
      'comments': comments,
    };
  }

  factory CorrectionModel.fromEntity(Correction correction) {
    return CorrectionModel(
      id: correction.id,
      referenceId: correction.referenceId,
      studentName: correction.studentName,
      correctionDate: correction.correctionDate,
      imagePath: correction.imagePath,
      score: correction.score,
      comments: correction.comments,
    );
  }

  Correction toEntity(List<AnswerEvaluationModel> answers) {
    return Correction(
      id: id,
      referenceId: referenceId,
      studentName: studentName,
      correctionDate: correctionDate,
      answers: answers.map((a) => a.toEntity()).toList(),
      imagePath: imagePath,
      score: score,
      comments: comments,
    );
  }
}

class AnswerEvaluationModel {
  final String id;
  final String correctionId;
  final String questionId;
  final int questionNumber;
  final String questionText;
  final String expectedAnswer;
  final String studentAnswer;
  final int maxPoints;
  final int earnedPoints;
  final double confidence;
  final String? feedback;

  AnswerEvaluationModel({
    required this.id,
    required this.correctionId,
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

  factory AnswerEvaluationModel.fromJson(Map<String, dynamic> json) {
    return AnswerEvaluationModel(
      id: json['id'],
      correctionId: json['correctionId'],
      questionId: json['questionId'],
      questionNumber: json['questionNumber'],
      questionText: json['questionText'],
      expectedAnswer: json['expectedAnswer'],
      studentAnswer: json['studentAnswer'],
      maxPoints: json['maxPoints'],
      earnedPoints: json['earnedPoints'],
      confidence: json['confidence'],
      feedback: json['feedback'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'correctionId': correctionId,
      'questionId': questionId,
      'questionNumber': questionNumber,
      'questionText': questionText,
      'expectedAnswer': expectedAnswer,
      'studentAnswer': studentAnswer,
      'maxPoints': maxPoints,
      'earnedPoints': earnedPoints,
      'confidence': confidence,
      'feedback': feedback,
    };
  }

  factory AnswerEvaluationModel.fromEntity(AnswerEvaluation answer, String correctionId) {
    return AnswerEvaluationModel(
      id: answer.id,
      correctionId: correctionId,
      questionId: answer.questionId,
      questionNumber: answer.questionNumber,
      questionText: answer.questionText,
      expectedAnswer: answer.expectedAnswer,
      studentAnswer: answer.studentAnswer,
      maxPoints: answer.maxPoints,
      earnedPoints: answer.earnedPoints,
      confidence: answer.confidence,
      feedback: answer.feedback,
    );
  }

  AnswerEvaluation toEntity() {
    return AnswerEvaluation(
      id: id,
      questionId: questionId,
      questionNumber: questionNumber,
      questionText: questionText,
      expectedAnswer: expectedAnswer,
      studentAnswer: studentAnswer,
      maxPoints: maxPoints,
      earnedPoints: earnedPoints,
      confidence: confidence,
      feedback: feedback,
    );
  }
}
