import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:uinlp_annotate/components/status_card.dart';
import 'package:uinlp_annotate/features/annotate_task/bloc/annotate_task_bloc.dart';
import 'package:uinlp_annotate/models/annotate_task.dart';
import 'package:uinlp_annotate/utilities/helper.dart';

Widget _buildSectionHeader(ThemeData theme, String title) {
  return Text(
    title,
    style: theme.textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.bold,
      color: theme.colorScheme.primary,
    ),
  );
}

class AnnotateEditorInfoView extends StatelessWidget {
  const AnnotateEditorInfoView({super.key, required this.taskId});

  final String? taskId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 500),
      child: Drawer(
        width: double.infinity,
        child: SafeArea(
          child: BlocBuilder<AnnotateTaskBloc, AnnotateTaskState>(
            builder: (context, state) {
              final task = state.tasks.where((e) => e.id == taskId).firstOrNull;
              if (task == null) {
                return LoadingCard();
              }
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: getModalityColor(
                              task.modality,
                            ).withAlpha(25),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            getModalityIcon(task.modality),
                            color: getModalityColor(task.modality),
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                task.name,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: getStatusColor(
                                    task.status,
                                  ).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  task.status.name.toUpperCase(),
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: getStatusColor(task.status),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        _buildSectionHeader(theme, "Progress"),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: task.progress,
                            minHeight: 12,
                            backgroundColor:
                                theme.colorScheme.surfaceContainerHighest,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "${(task.progress * 100).toInt()}% Completed",
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildSectionHeader(theme, "About this task"),
                        const SizedBox(height: 8),
                        Text(
                          task!.description,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 16,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Last Updated: ${DateFormat.yMMMd().add_jm().format(task!.lastUpdated)}",
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        _buildSectionHeader(theme, "Modalities"),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (var modality in task!.modalitySet)
                              Chip(
                                label: Text(modality),
                                side: BorderSide(
                                  color: theme.colorScheme.outlineVariant,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        _buildSectionHeader(theme, "Tags"),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (var tag in task.tags)
                              Chip(
                                label: Text(tag.toTitleCase()),
                                side: BorderSide(
                                  color: theme.colorScheme.outlineVariant,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        _buildSectionHeader(theme, "Input Fields"),
                        const SizedBox(height: 12),
                        for (var field in task.annotateFields)
                          Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            elevation: 0,
                            color: theme.colorScheme.surfaceContainer,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: theme.colorScheme.outlineVariant,
                                width: 1,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        field.name.toTitleCase(),
                                        style: theme.textTheme.titleSmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      const Spacer(),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: theme.colorScheme.primary
                                              .withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: Text(
                                          field.modality.repr.toTitleCase(
                                            sep: '_',
                                          ),
                                          style: theme.textTheme.labelSmall
                                              ?.copyWith(
                                                color:
                                                    theme.colorScheme.primary,
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    field.description,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
