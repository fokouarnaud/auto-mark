part of 'ocr_bloc.dart';

abstract class OCREvent extends Equatable {
  const OCREvent();

  @override
  List<Object?> get props => [];
}

class ProcessImageOCR extends OCREvent {
  final File imageFile;

  const ProcessImageOCR(this.imageFile);

  @override
  List<Object> get props => [imageFile];
}

class UpdateSegmentText extends OCREvent {
  final int index;
  final String text;

  const UpdateSegmentText(this.index, this.text);

  @override
  List<Object> get props => [index, text];
}

class UpdateSegmentType extends OCREvent {
  final int index;
  final SegmentType segmentType;

  const UpdateSegmentType(this.index, this.segmentType);

  @override
  List<Object> get props => [index, segmentType];
}

class UpdateSegmentQuestionNumber extends OCREvent {
  final int index;
  final int? questionNumber;

  const UpdateSegmentQuestionNumber(this.index, this.questionNumber);

  @override
  List<Object?> get props => [index, questionNumber];
}
