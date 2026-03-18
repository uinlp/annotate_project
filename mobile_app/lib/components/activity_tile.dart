import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uinlp_annotate/components/status_card.dart';
import 'package:uinlp_annotate/features/annotate_task/bloc/annotate_task_bloc.dart';
import 'package:uinlp_annotate/features/annotate_task/screens/annotate_editor_screen.dart';
import 'package:uinlp_annotate/models/annotate_task.dart';
import 'package:uinlp_annotate/utilities/helper.dart';

class ActivityTile extends StatelessWidget {
  const ActivityTile({
    super.key,
    required this.task,
    this.margin = const .symmetric(horizontal: 16, vertical: 8),
  });

  final AnnotateTaskModel task;
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      clipBehavior: .antiAlias,
      margin: margin,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        isThreeLine: true,
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: getModalityColor(task.modality).withAlpha(25),
          child: Icon(
            getModalityIcon(task.modality),
            color: getModalityColor(task.modality),
            size: 20,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                task.name.toTitleCase(),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.delete, color: theme.colorScheme.error),
              onPressed: () {
                showInfoDialog(
                  context,
                  "This task (${task.name}) is about to be deleted. Are you sure?",
                  title: "Delete Task",
                  actions: [
                    TextButton(
                      onPressed: () => context.pop(),
                      child: const Text("Cancel"),
                    ),
                    TextButton(
                      onPressed: () {
                        context.read<AnnotateTaskBloc>().add(
                          DeleteAnnotateTaskEvent(id: task.id),
                        );
                        context.pop();
                      },
                      child: const Text("Delete"),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              task.description.capitalized,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildStatusBadge(theme, task.status),
                const Spacer(),
                Text(
                  DateFormat('MMM d, h:mm a').format(task.lastUpdated),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
        onTap: () {
          if (task.status == TaskStatusEnum.published) {
            showInfoDialog(
              context,
              "This task is published and cannot be edited.",
            );
            return;
          }
          context.goNamed(
            AnnotateEditorScreen.routeName,
            queryParameters: {AnnotateEditorScreen.idQueryParam: task.id},
          );
        },
      ),
    );
  }

  Widget _buildStatusBadge(ThemeData theme, TaskStatusEnum status) {
    Color color;
    String label;
    switch (status) {
      case TaskStatusEnum.published:
        color = Colors.green;
        label = "Published";
        break;
      case TaskStatusEnum.inProgress:
        color = Colors.blue;
        label = "In Progress";
        break;
      case TaskStatusEnum.todo:
        color = Colors.grey;
        label = "To Do";
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
