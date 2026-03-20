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

class SaveGoal extends GoalEvent {
  const SaveGoal({required this.targetProblems, required this.targetRevisions, required this.focusPatterns});

  final int targetProblems;
  final int targetRevisions;
  final List<String> focusPatterns;

  @override
  List<Object?> get props => [targetProblems, targetRevisions, focusPatterns];
}

class GoalState extends Equatable {
  const GoalState({this.isLoading = false, this.goal, this.error});

  final bool isLoading;
  final WeeklyGoalModel? goal;
  final String? error;

  GoalState copyWith({bool? isLoading, WeeklyGoalModel? goal, String? error}) {
    return GoalState(isLoading: isLoading ?? this.isLoading, goal: goal ?? this.goal, error: error);
  }

  @override
  List<Object?> get props => [isLoading, goal, error];
}

class GoalBloc extends Bloc<GoalEvent, GoalState> {
  GoalBloc(this._repository) : super(const GoalState()) {
    on<LoadCurrentGoal>(_onLoad);
    on<SaveGoal>(_onSave);
  }

  final GoalRepository _repository;

  Future<void> _onLoad(LoadCurrentGoal event, Emitter<GoalState> emit) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final goal = await _repository.getCurrentWeeklyGoal();
      emit(state.copyWith(isLoading: false, goal: goal));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onSave(SaveGoal event, Emitter<GoalState> emit) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      await _repository.upsertWeeklyGoal(
        targetProblems: event.targetProblems,
        targetRevisions: event.targetRevisions,
        focusPatterns: event.focusPatterns,
      );
      final goal = await _repository.getCurrentWeeklyGoal();
      emit(state.copyWith(isLoading: false, goal: goal));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }
}
