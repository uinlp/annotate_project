import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uinlp_annotate/exceptions.dart';
import 'package:uinlp_annotate/models/annotate_task.dart';
import 'package:uinlp_annotate/repositories/asset.dart';
import 'package:uinlp_annotate/repositories/base.dart';
import 'package:uinlp_annotate/repositories/task.dart';
import 'package:uinlp_annotate/repositories/user.dart';
import 'package:uinlp_annotate/utilities/status.dart';

part 'annotate_task_event.dart';
part 'annotate_task_state.dart';

class AnnotateTaskBloc extends Bloc<AnnotateTaskEvent, AnnotateTaskState> {
  final TaskRepository taskRepo;
  final AssetRepository assetRepo;
  final UserRepository userRepo;
  AnnotateTaskBloc({
    required this.taskRepo,
    required this.assetRepo,
    required this.userRepo,
  }) : super(AnnotateTaskState()) {
    on<LoadAnnotateTaskEvent>((event, emit) async {
      debugPrint("Loading annotate tasks");
      emit(state.copyWith(status: LoadingStatus(event: event)));
      try {
        final tasks = await taskRepo.getRecentTasks();
        debugPrint("Loaded annotate tasks: ${tasks.length}");
        emit(
          state.copyWith(
            status: SuccessStatus(data: tasks, event: event),
            tasks: tasks,
          ),
        );
      } catch (e) {
        debugPrint("Failed to load annotate tasks: $e");
        emit(
          state.copyWith(
            status: ErrorStatus(
              event: event,
              data: RepositoryException.fromCatch(e),
            ),
          ),
        );
      }
      emit(state.copyWith(status: const IdleStatus()));
    });
    on<CreateAnnotateTaskEvent>((event, emit) async {
      debugPrint("Creating annotate task");
      emit(state.copyWith(status: LoadingStatus(event: event)));
      try {
        if (state.tasks.where((task) => task.id == event.asset.id).isNotEmpty) {
          throw RepositoryException(
            message: "You have already created an annotate task for this asset",
          );
        }
        final task = await taskRepo.createAnnotateTask(asset: event.asset);
        debugPrint("Created annotate task: ${task.id}");
        emit(
          state.copyWith(
            status: SuccessStatus(data: task.id, event: event),
            tasks: [task, ...state.tasks],
          ),
        );
      } catch (e) {
        emit(
          state.copyWith(
            status: ErrorStatus(
              event: event,
              data: RepositoryException.fromCatch(e),
            ),
          ),
        );
      }
      emit(state.copyWith(status: const IdleStatus()));
    });
  }
}
