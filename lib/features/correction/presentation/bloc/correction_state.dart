part of 'correction_bloc.dart';

abstract class CorrectionState extends Equatable {
  const CorrectionState();
  
  @override
  List<Object?> get props => [];
}

class CorrectionInitial extends CorrectionState {}

class CorrectionInProgress extends CorrectionState {
  final Reference reference;
  final String studentName;
  
  const CorrectionInProgress({
    required this.reference,
    required this.studentName,
  });
  
  @override
  List<Object> get props => [reference, studentName];
}

class CorrectionAnalyzing extends CorrectionState {
  final Reference reference;
  final String studentName;
  
  const CorrectionAnalyzing({
    required this.reference,
    required this.studentName,
  });
  
  @override
  List<Object> get props => [reference, studentName];
}

class CorrectionAnalyzed extends CorrectionState {
  final Reference reference;
  final Correction correction;
  
  const CorrectionAnalyzed({
    required this.reference,
    required this.correction,
  });
  
  @override
  List<Object> get props => [reference, correction];
}

class CorrectionSaved extends CorrectionState {
  final Reference reference;
  final Correction correction;
  
  const CorrectionSaved({
    required this.reference,
    required this.correction,
  });
  
  @override
  List<Object> get props => [reference, correction];
}

class CorrectionExporting extends CorrectionState {
  final Reference reference;
  final Correction correction;
  
  const CorrectionExporting({
    required this.reference,
    required this.correction,
  });
  
  @override
  List<Object> get props => [reference, correction];
}

class CorrectionExported extends CorrectionState {
  final Reference reference;
  final Correction correction;
  final File exportedFile;
  
  const CorrectionExported({
    required this.reference,
    required this.correction,
    required this.exportedFile,
  });
  
  @override
  List<Object> get props => [reference, correction, exportedFile];
}

class CorrectionError extends CorrectionState {
  final Reference reference;
  final String studentName;
  final String message;
  final CorrectionState? previousState;
  
  const CorrectionError({
    required this.reference,
    required this.studentName,
    required this.message,
    this.previousState,
  });
  
  @override
  List<Object?> get props => [reference, studentName, message, previousState];
}
