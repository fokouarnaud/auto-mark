import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

class Reference extends Equatable {
  final String id;
  final String title;
  final String subject;
  final String description;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<Question> questions;
  final String? imagePath;

  const Reference({
    required this.id,
    required this.title,
    required this.subject,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
    required this.questions,
    this.imagePath,
  });

  factory Reference.create({
    required String title,
    required String subject,
    required String description,
    required List<Question> questions,
    String? imagePath,
  }) {
    final now = DateTime.now();
    return Reference(
      id: const Uuid().v4(),
      title: title,
      subject: subject,
      description: description,
      createdAt: now,
      updatedAt: now,
      questions: questions,
      imagePath: imagePath,
    );
  }

  Reference copyWith({
    String? title,
    String? subject,
    String? description,
    List<Question>? questions,
    String? imagePath,
  }) {
    return Reference(
      id: id,
      title: title ?? this.title,
      subject: subject ?? this.subject,
      description: description ?? this.description,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      questions: questions ?? this.questions,
      imagePath: imagePath ?? this.imagePath,
    );
  }

  int get totalPoints => questions.fold(0, (sum, q) => sum + q.points);
  
  int get questionsCount => questions.length;

  @override
  List<Object?> get props => [
        id,
        title,
        subject,
        description,
        createdAt,
        updatedAt,
        questions,
        imagePath,
      ];
}

class Question extends Equatable {
  final String id;
  final int number;
  final String text;
  final String expectedAnswer;
  final int points;
  final List<String> keywords;

  const Question({
    required this.id,
    required this.number,
    required this.text,
    required this.expectedAnswer,
    required this.points,
    required this.keywords,
  });

  factory Question.create({
    required int number,
    required String text,
    required String expectedAnswer,
    required int points,
    List<String>? keywords,
  }) {
    return Question(
      id: const Uuid().v4(),
      number: number,
      text: text,
      expectedAnswer: expectedAnswer,
      points: points,
      keywords: keywords ?? [],
    );
  }

  Question copyWith({
    int? number,
    String? text,
    String? expectedAnswer,
    int? points,
    List<String>? keywords,
  }) {
    return Question(
      id: id,
      number: number ?? this.number,
      text: text ?? this.text,
      expectedAnswer: expectedAnswer ?? this.expectedAnswer,
      points: points ?? this.points,
      keywords: keywords ?? this.keywords,
    );
  }

  @override
  List<Object> get props => [id, number, text, expectedAnswer, points, keywords];
}
