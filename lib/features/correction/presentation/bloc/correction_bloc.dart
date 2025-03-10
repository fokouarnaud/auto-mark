import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:correction_auto/domain/entities/correction.dart';
import 'package:correction_auto/domain/entities/reference.dart';
import 'package:correction_auto/features/correction/domain/correction_service.dart';

part 'correction_event.dart';
part 'correction_state.dart';

@injectable
class CorrectionBloc extends Bloc<CorrectionEvent, CorrectionState> {
  final CorrectionService _correctionService;
  
  CorrectionBloc(this._correctionService) : super(CorrectionInitial()) {
    on<StartCorrection>(_onStartCorrection);
    on<AnalyzeStudentPaper>(_onAnalyzeStudentPaper);
    on<UpdateAnswerEvaluation>(_onUpdateAnswerEvaluation);
    on<SaveCorrection>(_onSaveCorrection);
    on<ExportCorrection>(_onExportCorrection);
  }
  
  Future<void> _onStartCorrection(
    StartCorrection event,
    Emitter<CorrectionState> emit,
  ) async {
    emit(CorrectionInProgress(
      reference: event.reference,
      studentName: event.studentName,
    ));
  }
  
  Future<void> _onAnalyzeStudentPaper(
    AnalyzeStudentPaper event,
    Emitter<CorrectionState> emit,
  ) async {
    if (state is CorrectionInProgress) {
      final currentState = state as CorrectionInProgress;
      
      emit(CorrectionAnalyzing(
        reference: currentState.reference,
        studentName: currentState.studentName,
      ));
      
      try {
        final correction = await _correctionService.analyzeStudentPaper(
          imageFile: event.imageFile,
          reference: currentState.reference,
          studentName: currentState.studentName,
        );
        
        emit(CorrectionAnalyzed(
          reference: currentState.reference,
          correction: correction,
        ));
      } catch (e) {
        emit(CorrectionError(
          reference: currentState.reference,
          studentName: currentState.studentName,
          message: 'Erreur lors de l\'analyse: ${e.toString()}',
        ));
      }
    }
  }
  
  Future<void> _onUpdateAnswerEvaluation(
    UpdateAnswerEvaluation event,
    Emitter<CorrectionState> emit,
  ) async {
    if (state is CorrectionAnalyzed) {
      final currentState = state as CorrectionAnalyzed;
      
      try {
        final updatedCorrection = await _correctionService.updateAnswerEvaluation(
          correction: currentState.correction,
          answerId: event.answerId,
          earnedPoints: event.earnedPoints,
          feedback: event.feedback,
        );
        
        emit(CorrectionAnalyzed(
          reference: currentState.reference,
          correction: updatedCorrection,
        ));
      } catch (e) {
        emit(CorrectionError(
          reference: currentState.reference,
          studentName: currentState.correction.studentName,
          message: 'Erreur lors de la mise à jour: ${e.toString()}',
          previousState: currentState,
        ));
      }
    }
  }
  
  Future<void> _onSaveCorrection(
    SaveCorrection event,
    Emitter<CorrectionState> emit,
  ) async {
    if (state is CorrectionAnalyzed) {
      final currentState = state as CorrectionAnalyzed;
      
      // In a real app, this would save to a repository
      emit(CorrectionSaved(
        reference: currentState.reference,
        correction: currentState.correction,
      ));
    }
  }
  
  Future<void> _onExportCorrection(
    ExportCorrection event,
    Emitter<CorrectionState> emit,
  ) async {
    if (state is CorrectionAnalyzed || state is CorrectionSaved) {
      final Correction correction;
      final Reference reference;
      
      if (state is CorrectionAnalyzed) {
        final currentState = state as CorrectionAnalyzed;
        correction = currentState.correction;
        reference = currentState.reference;
      } else {
        final currentState = state as CorrectionSaved;
        correction = currentState.correction;
        reference = currentState.reference;
      }
      
      emit(CorrectionExporting(
        reference: reference,
        correction: correction,
      ));
      
      try {
        final pdfFile = await _correctionService.exportToPdf(correction, reference);
        
        emit(CorrectionExported(
          reference: reference,
          correction: correction,
          exportedFile: pdfFile,
        ));
      } catch (e) {
        emit(CorrectionError(
          reference: reference,
          studentName: correction.studentName,
          message: 'Erreur lors de l\'export: ${e.toString()}',
          previousState: state,
        ));
      }
    }
  }
}
