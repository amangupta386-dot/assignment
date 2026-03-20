import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../models/revision_item.dart';
import '../../../repositories/revision_repository.dart';

abstract class RevisionEvent extends Equatable {
  const RevisionEvent();
  @override
  List<Object?> get props => [];
}

class LoadTodayRevisions extends RevisionEvent {}

class CompleteRevisionTask extends RevisionEvent {
  const CompleteRevisionTask(this.problemId);
  final int problemId;
  @override
  List<Object?> get props => [problemId];
}

class FailRevisionTask extends RevisionEvent {
  const FailRevisionTask(this.problemId);
  final int problemId;
  @override
  List<Object?> get props => [problemId];
}

class RevisionState extends Equatable {
  const RevisionState({this.isLoading = false, this.items = const [], this.error});

  final bool isLoading;
  final List<RevisionItem> items;
  final String? error;

  RevisionState copyWith({bool? isLoading, List<RevisionItem>? items, String? error}) {
    return RevisionState(
      isLoading: isLoading ?? this.isLoading,
      items: items ?? this.items,
      error: error,
    );
  }

  @override
  List<Object?> get props => [isLoading, items, error];
}

class RevisionBloc extends Bloc<RevisionEvent, RevisionState> {
  RevisionBloc(this._repository) : super(const RevisionState()) {
    on<LoadTodayRevisions>(_onLoad);
    on<CompleteRevisionTask>(_onComplete);
    on<FailRevisionTask>(_onFail);
  }

  final RevisionRepository _repository;

  Future<void> _onLoad(LoadTodayRevisions event, Emitter<RevisionState> emit) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final items = await _repository.getTodayRevisions();
      emit(state.copyWith(isLoading: false, items: items));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onComplete(CompleteRevisionTask event, Emitter<RevisionState> emit) async {
    await _repository.completeRevision(event.problemId);
    add(LoadTodayRevisions());
  }

  Future<void> _onFail(FailRevisionTask event, Emitter<RevisionState> emit) async {
    await _repository.failRevision(event.problemId);
    add(LoadTodayRevisions());
  }
}
