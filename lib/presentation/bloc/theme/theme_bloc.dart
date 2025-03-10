import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Events
abstract class ThemeEvent extends Equatable {
  const ThemeEvent();

  @override
  List<Object> get props => [];
}

class InitTheme extends ThemeEvent {}

class ToggleTheme extends ThemeEvent {}

class SetThemeMode extends ThemeEvent {
  final ThemeMode themeMode;

  const SetThemeMode(this.themeMode);

  @override
  List<Object> get props => [themeMode];
}

// State
class ThemeState extends Equatable {
  final ThemeMode themeMode;

  const ThemeState({required this.themeMode});

  factory ThemeState.initial() => const ThemeState(themeMode: ThemeMode.system);

  ThemeState copyWith({ThemeMode? themeMode}) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
    );
  }

  @override
  List<Object> get props => [themeMode];
}

// BLoC
@singleton
class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  final SharedPreferences _prefs;

  ThemeBloc(this._prefs) : super(ThemeState.initial()) {
    on<InitTheme>(_onInitTheme);
    on<ToggleTheme>(_onToggleTheme);
    on<SetThemeMode>(_onSetThemeMode);
  }

  void _onInitTheme(InitTheme event, Emitter<ThemeState> emit) {
    final themeIndex = _prefs.getInt('themeMode') ?? 0;
    final themeMode = ThemeMode.values[themeIndex];
    emit(state.copyWith(themeMode: themeMode));
  }

  void _onToggleTheme(ToggleTheme event, Emitter<ThemeState> emit) {
    final newThemeMode = state.themeMode == ThemeMode.dark 
        ? ThemeMode.light 
        : ThemeMode.dark;
    
    _prefs.setInt('themeMode', newThemeMode.index);
    emit(state.copyWith(themeMode: newThemeMode));
  }

  void _onSetThemeMode(SetThemeMode event, Emitter<ThemeState> emit) {
    _prefs.setInt('themeMode', event.themeMode.index);
    emit(state.copyWith(themeMode: event.themeMode));
  }
}
