import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../models/problem_model.dart';
import '../../../repositories/problem_repository.dart';

abstract class ProblemEvent extends Equatable {
  const ProblemEvent();
  @override
  List<Object?> get props => [];
}

class LoadProblems extends ProblemEvent {}

class AddProblem extends ProblemEvent {
  const AddProblem({
    required this.title,
    required this.platform,
    required this.difficulty,
    required this.pattern,
    required this.initialStatus,
  });

  final String title;
  final String platform;
  final String difficulty;
  final String pattern;
  final String initialStatus;

  @override
  List<Object?> get props => [title, platform, difficulty, pattern, initialStatus];
}

class ProblemState extends Equatable {
  const ProblemState({
    this.isLoading = false,
    this.items = const [],
    this.error,
  });

  final bool isLoading;
  final List<ProblemModel> items;
  final String? error;

  ProblemState copyWith({bool? isLoading, List<ProblemModel>? items, String? error}) {
    return ProblemState(
      isLoading: isLoading ?? this.isLoading,
      items: items ?? this.items,
      error: error,
    );
  }

  @override
  List<Object?> get props => [isLoading, items, error];
}

class ProblemBloc extends Bloc<ProblemEvent, ProblemState> {
  ProblemBloc(this._repository) : super(const ProblemState()) {
    on<LoadProblems>(_onLoad);
    on<AddProblem>(_onAddProblem);
  }

  final ProblemRepository _repository;

  Future<void> _onLoad(LoadProblems event, Emitter<ProblemState> emit) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final items = await _repository.getProblems();
      emit(state.copyWith(isLoading: false, items: items));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onAddProblem(AddProblem event, Emitter<ProblemState> emit) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      await _repository.addProblem(
        title: event.title,
        platform: event.platform,
        difficulty: event.difficulty,
        pattern: event.pattern,
        initialStatus: event.initialStatus,
      );
      final items = await _repository.getProblems();
      emit(state.copyWith(isLoading: false, items: items));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }
}
