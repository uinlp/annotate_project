import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uinlp_annotate/components/status_card.dart';
import 'package:uinlp_annotate/features/annotate_task/bloc/annotate_task_bloc.dart';
import 'package:uinlp_annotate/models/annotate_task.dart';

class AnnotateEditorGridView extends StatelessWidget {
  const AnnotateEditorGridView({
    super.key,
    required this.taskId,
    this.onDataIndexPressed,
    this.currentDataIndex,
  });
  final String? taskId;
  final void Function(int index)? onDataIndexPressed;
  final int? currentDataIndex;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text("Activity Grid", style: theme.textTheme.titleLarge),
            ),
            Expanded(
              child:
                  BlocSelector<
                    AnnotateTaskBloc,
                    AnnotateTaskState,
                    AnnotateTaskModel?
                  >(
                    selector: (state) {
                      return state.tasks
                          .where((e) => e.id == taskId)
                          .firstOrNull;
                    },
                    builder: (context, task) {
                      if (task == null) {
                        return LoadingCard();
                      }
                      return GridView.builder(
                        padding: EdgeInsets.all(8),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 5,
                          mainAxisSpacing: 4,
                          crossAxisSpacing: 4,
                        ),
                        itemCount: task.dataIds.length,
                        itemBuilder: (context, index) {
                          return FilledButton(
                            onPressed: () {
                              onDataIndexPressed?.call(index);
                            },
                            style: FilledButton.styleFrom(
                              backgroundColor:
                                  task.commits.containsKey(task.dataIds[index])
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.primary.withAlpha(25),
                              foregroundColor:
                                  task.commits.containsKey(task.dataIds[index])
                                  ? theme.colorScheme.onPrimary
                                  : theme.colorScheme.primary,
                              side: currentDataIndex == index
                                  ? BorderSide(
                                      color: theme.colorScheme.secondary,
                                      width: 2,
                                    )
                                  : BorderSide.none,
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text("${index + 1}"),
                          );
                        },
                      );
                    },
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
