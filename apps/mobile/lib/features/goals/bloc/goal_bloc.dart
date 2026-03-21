import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../models/weekly_goal_model.dart';
import '../../../repositories/goal_repository.dart';

abstract class GoalEvent extends Equatable {
  const GoalEvent();
  @override
  List<Object?> get props => [];
}

class LoadCurrentGoal extends GoalEvent {}

class ResetGoalState extends GoalEvent {}

class LoadGoalPlanningInsights extends GoalEvent {}

class SaveGoal extends GoalEvent {
  const SaveGoal({
    required this.fromDate,
    required this.toDate,
    required this.goalProblems,
  });

  final DateTime fromDate;
  final DateTime toDate;
  final List<GoalProblemItem> goalProblems;

  @override
  List<Object?> get props => [fromDate, toDate, goalProblems];
}

class LoadMonthlyTimeline extends GoalEvent {
  const LoadMonthlyTimeline({required this.month});
  final DateTime month;

  @override
  List<Object?> get props => [month];
}

class GoalState extends Equatable {
  const GoalState({
    this.isLoading = false,
    this.goal,
    this.timelines = const [],
    this.planningInsights,
    this.error,
    this.saveVersion = 0,
  });

  final bool isLoading;
  final WeeklyGoalModel? goal;
  final List<WeeklyGoalModel> timelines;
  final WeeklyGoalPlanningInsights? planningInsights;
  final String? error;
  final int saveVersion;

  GoalState copyWith({
    bool? isLoading,
    WeeklyGoalModel? goal,
    List<WeeklyGoalModel>? timelines,
    WeeklyGoalPlanningInsights? planningInsights,
    String? error,
    int? saveVersion,
  }) {
    return GoalState(
      isLoading: isLoading ?? this.isLoading,
      goal: goal ?? this.goal,
      timelines: timelines ?? this.timelines,
      planningInsights: planningInsights ?? this.planningInsights,
      error: error,
      saveVersion: saveVersion ?? this.saveVersion,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        goal,
        timelines,
        planningInsights,
        error,
        saveVersion,
      ];
}

class GoalBloc extends Bloc<GoalEvent, GoalState> {
  GoalBloc(this._repository) : super(const GoalState()) {
    on<ResetGoalState>(_onReset);
    on<LoadGoalPlanningInsights>(_onLoadPlanningInsights);
    on<LoadCurrentGoal>(_onLoad);
    on<SaveGoal>(_onSave);
    on<LoadMonthlyTimeline>(_onLoadMonthlyTimeline);
  }

  final GoalRepository _repository;

  void _onReset(ResetGoalState event, Emitter<GoalState> emit) {
    emit(const GoalState());
  }

  Future<void> _onLoadPlanningInsights(
      LoadGoalPlanningInsights event, Emitter<GoalState> emit) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final planningInsights = await _repository.getPlanningInsights();
      emit(state.copyWith(
        isLoading: false,
        planningInsights: planningInsights,
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onLoad(LoadCurrentGoal event, Emitter<GoalState> emit) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final goal = await _repository.getCurrentWeeklyGoal();
      emit(state.copyWith(isLoading: false, goal: goal, error: null));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onSave(SaveGoal event, Emitter<GoalState> emit) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      await _repository.upsertWeeklyGoal(
        fromDate: event.fromDate,
        toDate: event.toDate,
        goalProblems: event.goalProblems,
      );
      final timelines = await _repository.getMonthlyTimeline(event.fromDate);
      emit(GoalState(
        timelines: timelines,
        saveVersion: state.saveVersion + 1,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onLoadMonthlyTimeline(
      LoadMonthlyTimeline event, Emitter<GoalState> emit) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final timelines = await _repository.getMonthlyTimeline(event.month);
      emit(state.copyWith(isLoading: false, timelines: timelines, error: null));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }
}
