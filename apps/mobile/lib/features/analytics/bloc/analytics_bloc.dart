import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../models/pattern_analytics_model.dart';
import '../../../models/weekly_analytics_model.dart';
import '../../../repositories/analytics_repository.dart';

abstract class AnalyticsEvent extends Equatable {
  const AnalyticsEvent();
  @override
  List<Object?> get props => [];
}

class LoadAnalytics extends AnalyticsEvent {}

class AnalyticsState extends Equatable {
  const AnalyticsState({this.isLoading = false, this.weekly, this.patterns = const [], this.error});

  final bool isLoading;
  final WeeklyAnalytics? weekly;
  final List<PatternAnalytics> patterns;
  final String? error;

  AnalyticsState copyWith({bool? isLoading, WeeklyAnalytics? weekly, List<PatternAnalytics>? patterns, String? error}) {
    return AnalyticsState(
      isLoading: isLoading ?? this.isLoading,
      weekly: weekly ?? this.weekly,
      patterns: patterns ?? this.patterns,
      error: error,
    );
  }

  @override
  List<Object?> get props => [isLoading, weekly, patterns, error];
}

class AnalyticsBloc extends Bloc<AnalyticsEvent, AnalyticsState> {
  AnalyticsBloc(this._repository) : super(const AnalyticsState()) {
    on<LoadAnalytics>(_onLoad);
  }

  final AnalyticsRepository _repository;

  Future<void> _onLoad(LoadAnalytics event, Emitter<AnalyticsState> emit) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final weekly = await _repository.getWeeklyAnalytics();
      final patterns = await _repository.getPatternAnalytics();
      emit(state.copyWith(isLoading: false, weekly: weekly, patterns: patterns));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }
}
