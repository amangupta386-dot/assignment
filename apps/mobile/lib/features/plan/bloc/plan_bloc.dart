import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../models/daily_plan_model.dart';
import '../../../repositories/plan_repository.dart';

abstract class PlanEvent extends Equatable {
  const PlanEvent();
  @override
  List<Object?> get props => [];
}

class LoadTodayPlan extends PlanEvent {}

class GenerateWeekPlan extends PlanEvent {
  const GenerateWeekPlan({this.weekStart});
  final String? weekStart;
  @override
  List<Object?> get props => [weekStart];
}

class MarkTaskDone extends PlanEvent {
  const MarkTaskDone(this.key);
  final String key;
  @override
  List<Object?> get props => [key];
}

class PlanState extends Equatable {
  const PlanState({this.isLoading = false, this.plan, this.error});

  final bool isLoading;
  final DailyPlanModel? plan;
  final String? error;

  PlanState copyWith({bool? isLoading, DailyPlanModel? plan, String? error}) {
    return PlanState(isLoading: isLoading ?? this.isLoading, plan: plan ?? this.plan, error: error);
  }

  @override
  List<Object?> get props => [isLoading, plan, error];
}

class PlanBloc extends Bloc<PlanEvent, PlanState> {
  PlanBloc(this._repository) : super(const PlanState()) {
    on<LoadTodayPlan>(_onLoad);
    on<GenerateWeekPlan>(_onGenerate);
    on<MarkTaskDone>(_onMarkTaskDone);
  }

  final PlanRepository _repository;

  Future<void> _onLoad(LoadTodayPlan event, Emitter<PlanState> emit) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final plan = await _repository.getTodayPlan();
      emit(state.copyWith(isLoading: false, plan: plan));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onGenerate(GenerateWeekPlan event, Emitter<PlanState> emit) async {
    await _repository.generateWeek(weekStart: event.weekStart);
    add(LoadTodayPlan());
  }

  Future<void> _onMarkTaskDone(MarkTaskDone event, Emitter<PlanState> emit) async {
    final plan = await _repository.markTaskDone(event.key);
    emit(state.copyWith(plan: plan));
  }
}
