import "package:flutter_bloc/flutter_bloc.dart";
import "../../data/workers_repository.dart";
import "../../domain/worker.dart";

sealed class WorkersEvent {}

final class WorkersRequested extends WorkersEvent {
  WorkersRequested({
    required this.latitude,
    required this.longitude,
  });

  final double latitude;
  final double longitude;
}

sealed class WorkersState {
  const WorkersState();
}

final class WorkersInitial extends WorkersState {
  const WorkersInitial();
}

final class WorkersLoading extends WorkersState {
  const WorkersLoading();
}

final class WorkersLoaded extends WorkersState {
  const WorkersLoaded(this.workers);

  final List<Worker> workers;
}

final class WorkersFailure extends WorkersState {
  const WorkersFailure(this.message);

  final String message;
}

class WorkersBloc extends Bloc<WorkersEvent, WorkersState> {
  WorkersBloc({required WorkersRepository workersRepository})
      : _workersRepository = workersRepository,
        super(const WorkersInitial()) {
    on<WorkersRequested>(_onWorkersRequested);
  }

  final WorkersRepository _workersRepository;

  Future<void> _onWorkersRequested(
    WorkersRequested event,
    Emitter<WorkersState> emit,
  ) async {
    emit(const WorkersLoading());

    try {
      final workers = await _workersRepository.fetchNearbyWorkers(
        event.latitude,
        event.longitude,
      );
      emit(WorkersLoaded(workers));
    } catch (_) {
      emit(const WorkersFailure("Could not load nearby workers."));
    }
  }
}
