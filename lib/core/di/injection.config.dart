// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/correction/domain/correction_service.dart';
import '../../features/correction/presentation/bloc/correction_bloc.dart';
import '../../features/ocr/data/ml_kit_ocr_service.dart';
import '../../features/ocr/domain/ocr_service.dart';
import '../../features/ocr/presentation/bloc/ocr_bloc.dart';
import '../../features/text_analysis/data/simple_text_analyzer.dart';
import '../../features/text_analysis/domain/text_analyzer.dart';
import '../utils/logger_util.dart';
import '../theme/app_theme.dart';
import '../../presentation/bloc/theme/theme_bloc.dart';

Future<GetIt> init(GetIt getIt) async {
  // Register external dependencies
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);
  
  // Register logger
  getIt.registerSingleton<Logger>(getLoggerInstance());
  
  // Register services
  getIt.registerLazySingleton<OCRService>(() => MLKitOCRService(getIt<Logger>()));
  getIt.registerLazySingleton<TextAnalyzer>(() => SimpleTextAnalyzer(getIt<Logger>()));
  getIt.registerLazySingleton<CorrectionService>(() => CorrectionServiceImpl(
    getIt<OCRService>(), 
    getIt<TextAnalyzer>(),
  ));
  
  // Register blocs
  getIt.registerSingleton<ThemeBloc>(ThemeBloc(getIt<SharedPreferences>()));
  getIt.registerFactory<OCRBloc>(() => OCRBloc(getIt<OCRService>(), getIt<Logger>()));
  getIt.registerFactory<CorrectionBloc>(() => CorrectionBloc(getIt<CorrectionService>()));
  
  return getIt;
}
