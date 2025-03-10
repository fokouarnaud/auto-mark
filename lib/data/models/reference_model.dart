import 'package:correction_auto/domain/entities/reference.dart';

class ReferenceModel {
  final String id;
  final String title;
  final String subject;
  final String description;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? imagePath;

  ReferenceModel({
    required this.id,
    required this.title,
    required this.subject,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
    this.imagePath,
  });

  factory ReferenceModel.fromJson(Map<String, dynamic> json) {
    return ReferenceModel(
      id: json['id'],
      title: json['title'],
      subject: json['subject'],
      description: json['description'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      imagePath: json['imagePath'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subject': subject,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'imagePath': imagePath,
    };
  }

  factory ReferenceModel.fromEntity(Reference reference) {
    return ReferenceModel(
      id: reference.id,
      title: reference.title,
      subject: reference.subject,
      description: reference.description,
      createdAt: reference.createdAt,
      updatedAt: reference.updatedAt,
      imagePath: reference.imagePath,
    );
  }

  Reference toEntity(List<QuestionModel> questions) {
    return Reference(
      id: id,
      title: title,
      subject: subject,
      description: description,
      createdAt: createdAt,
      updatedAt: updatedAt,
      questions: questions.map((q) => q.toEntity()).toList(),
      imagePath: imagePath,
    );
  }
}

class QuestionModel {
  final String id;
  final String referenceId;
  final int number;
  final String text;
  final String expectedAnswer;
  final int points;

  QuestionModel({
    required this.id,
    required this.referenceId,
    required this.number,
    required this.text,
    required this.expectedAnswer,
    required this.points,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json['id'],
      referenceId: json['referenceId'],
      number: json['number'],
      text: json['text'],
      expectedAnswer: json['expectedAnswer'],
      points: json['points'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'referenceId': referenceId,
      'number': number,
      'text': text,
      'expectedAnswer': expectedAnswer,
      'points': points,
    };
  }

  factory QuestionModel.fromEntity(Question question, String referenceId) {
    return QuestionModel(
      id: question.id,
      referenceId: referenceId,
      number: question.number,
      text: question.text,
      expectedAnswer: question.expectedAnswer,
      points: question.points,
    );
  }

  Question toEntity({List<KeywordModel>? keywords}) {
    return Question(
      id: id,
      number: number,
      text: text,
      expectedAnswer: expectedAnswer,
      points: points,
      keywords: keywords?.map((k) => k.word).toList() ?? [],
    );
  }
}

class KeywordModel {
  final String id;
  final String questionId;
  final String word;

  KeywordModel({
    required this.id,
    required this.questionId,
    required this.word,
  });

  factory KeywordModel.fromJson(Map<String, dynamic> json) {
    return KeywordModel(
      id: json['id'],
      questionId: json['questionId'],
      word: json['word'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'questionId': questionId,
      'word': word,
    };
  }
}
