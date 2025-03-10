part of 'correction_bloc.dart';

abstract class CorrectionEvent extends Equatable {
  const CorrectionEvent();
  
  @override
  List<Object?> get props => [];
}

class StartCorrection extends CorrectionEvent {
  final Reference reference;
  final String studentName;
  
  const StartCorrection({
    required this.reference,
    required this.studentName,
  });
  
  @override
  List<Object> get props => [reference, studentName];
}

class AnalyzeStudentPaper extends CorrectionEvent {
  final File imageFile;
  
  const AnalyzeStudentPaper(this.imageFile);
  
  @override
  List<Object> get props => [imageFile];
}

class UpdateAnswerEvaluation extends CorrectionEvent {
  final String answerId;
  final int earnedPoints;
  final String? feedback;
  
  const UpdateAnswerEvaluation({
    required this.answerId,
    required this.earnedPoints,
    this.feedback,
  });
  
  @override
  List<Object?> get props => [answerId, earnedPoints, feedback];
}

class SaveCorrection extends CorrectionEvent {}

class ExportCorrection extends CorrectionEvent {
  final String format;
  
  const ExportCorrection({this.format = 'pdf'});
  
  @override
  List<Object> get props => [format];
}
