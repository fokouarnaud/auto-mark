part of 'ocr_bloc.dart';

abstract class OCRState extends Equatable {
  const OCRState();
  
  @override
  List<Object?> get props => [];
}

class OCRInitial extends OCRState {}

class OCRLoading extends OCRState {}

class OCRLoaded extends OCRState {
  final OCRResult ocrResult;
  final List<DocumentSegment> segments;

  const OCRLoaded({
    required this.ocrResult,
    required this.segments,
  });

  @override
  List<Object> get props => [ocrResult, segments];
}

class OCRError extends OCRState {
  final String message;

  const OCRError(this.message);

  @override
  List<Object> get props => [message];
}
