import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import 'package:correction_auto/features/ocr/domain/ocr_service.dart';

part 'ocr_event.dart';
part 'ocr_state.dart';

@injectable
class OCRBloc extends Bloc<OCREvent, OCRState> {
  final OCRService _ocrService;
  final Logger _logger;

  OCRBloc(this._ocrService, this._logger) : super(OCRInitial()) {
    on<ProcessImageOCR>(_onProcessImageOCR);
    on<UpdateSegmentText>(_onUpdateSegmentText);
    on<UpdateSegmentType>(_onUpdateSegmentType);
    on<UpdateSegmentQuestionNumber>(_onUpdateSegmentQuestionNumber);
  }

  Future<void> _onProcessImageOCR(
    ProcessImageOCR event,
    Emitter<OCRState> emit,
  ) async {
    emit(OCRLoading());

    try {
      _logger.i('Processing image OCR: ${event.imageFile.path}');
      
      // 1. Perform OCR on the image
      final ocrResult = await _ocrService.recognizeText(event.imageFile);
      
      // 2. Segment the document
      final segments = await _ocrService.segmentDocument(ocrResult);
      
      emit(OCRLoaded(
        ocrResult: ocrResult,
        segments: segments,
      ));
    } catch (e, stackTrace) {
      _logger.e('Error processing OCR: ${e.toString()}');
      emit(OCRError('La reconnaissance de texte a échoué: ${e.toString()}'));
    }
  }

  void _onUpdateSegmentText(
    UpdateSegmentText event,
    Emitter<OCRState> emit,
  ) {
    final currentState = state;
    if (currentState is OCRLoaded) {
      final updatedSegments = List<DocumentSegment>.from(currentState.segments);
      
      // Ensure the index is valid
      if (event.index >= 0 && event.index < updatedSegments.length) {
        final oldSegment = updatedSegments[event.index];
        
        // Create a new segment with updated text
        // Note: Since DocumentSegment is immutable, we need to create a new instance
        // In a real implementation, you would need to properly update the TextBlock as well
        final updatedSegment = DocumentSegment(
          id: oldSegment.id,
          type: oldSegment.type,
          text: event.text,
          block: oldSegment.block,
          questionNumber: oldSegment.questionNumber,
        );
        
        updatedSegments[event.index] = updatedSegment;
        
        emit(OCRLoaded(
          ocrResult: currentState.ocrResult,
          segments: updatedSegments,
        ));
      }
    }
  }

  void _onUpdateSegmentType(
    UpdateSegmentType event,
    Emitter<OCRState> emit,
  ) {
    final currentState = state;
    if (currentState is OCRLoaded) {
      final updatedSegments = List<DocumentSegment>.from(currentState.segments);
      
      // Ensure the index is valid
      if (event.index >= 0 && event.index < updatedSegments.length) {
        final oldSegment = updatedSegments[event.index];
        
        // Create a new segment with updated type
        final updatedSegment = DocumentSegment(
          id: oldSegment.id,
          type: event.segmentType,
          text: oldSegment.text,
          block: oldSegment.block,
          questionNumber: oldSegment.questionNumber,
        );
        
        updatedSegments[event.index] = updatedSegment;
        
        emit(OCRLoaded(
          ocrResult: currentState.ocrResult,
          segments: updatedSegments,
        ));
      }
    }
  }

  void _onUpdateSegmentQuestionNumber(
    UpdateSegmentQuestionNumber event,
    Emitter<OCRState> emit,
  ) {
    final currentState = state;
    if (currentState is OCRLoaded) {
      final updatedSegments = List<DocumentSegment>.from(currentState.segments);
      
      // Ensure the index is valid
      if (event.index >= 0 && event.index < updatedSegments.length) {
        final oldSegment = updatedSegments[event.index];
        
        // Create a new segment with updated question number
        final updatedSegment = DocumentSegment(
          id: oldSegment.id,
          type: oldSegment.type,
          text: oldSegment.text,
          block: oldSegment.block,
          questionNumber: event.questionNumber,
        );
        
        updatedSegments[event.index] = updatedSegment;
        
        emit(OCRLoaded(
          ocrResult: currentState.ocrResult,
          segments: updatedSegments,
        ));
      }
    }
  }
}
