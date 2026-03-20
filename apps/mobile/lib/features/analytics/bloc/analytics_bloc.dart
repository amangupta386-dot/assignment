import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../models/analytics_dashboard_model.dart';
import '../../../repositories/analytics_repository.dart';

abstract class AnalyticsEvent extends Equatable {
  const AnalyticsEvent();
  @override
  List<Object?> get props => [];
}

class LoadAnalytics extends AnalyticsEvent {}

class AnalyticsState extends Equatable {
  const AnalyticsState({this.isLoading = false, this.dashboard, this.error});

  final bool isLoading;
  final AnalyticsDashboard? dashboard;
  final String? error;

  AnalyticsState copyWith(
      {bool? isLoading, AnalyticsDashboard? dashboard, String? error}) {
    return AnalyticsState(
      isLoading: isLoading ?? this.isLoading,
      dashboard: dashboard ?? this.dashboard,
      error: error,
    );
  }

  @override
  List<Object?> get props => [isLoading, dashboard, error];
}

class AnalyticsBloc extends Bloc<AnalyticsEvent, AnalyticsState> {
  AnalyticsBloc(this._repository) : super(const AnalyticsState()) {
    on<LoadAnalytics>(_onLoad);
  }

  final AnalyticsRepository _repository;

  Future<void> _onLoad(
      LoadAnalytics event, Emitter<AnalyticsState> emit) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final dashboard = await _repository.getDashboardAnalytics();
      emit(state.copyWith(isLoading: false, dashboard: dashboard));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }
}
