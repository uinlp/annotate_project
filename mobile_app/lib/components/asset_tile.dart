import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:uinlp_annotate/features/annotate_task/bloc/annotate_task_bloc.dart';
import 'package:uinlp_annotate/models/annotate_task.dart';
import 'package:uinlp_annotate/utilities/helper.dart';

class AssetTile extends StatelessWidget {
  const AssetTile({
    super.key,
    required this.asset,
    this.onTap,
    this.margin = const .symmetric(horizontal: 16, vertical: 8),
  });

  final AnnotateAssetModel asset;
  final VoidCallback? onTap;
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
          backgroundColor: getModalityColor(asset.modality).withAlpha(25),
          child: Icon(
            getModalityIcon(asset.modality),
            color: getModalityColor(asset.modality),
            size: 20,
          ),
        ),
        title: Text(
          asset.name.toTitleCase(),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              asset.description.capitalized,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                // _buildStatusBadge(theme, asset.status),
                Text(
                  asset.tags.map((e) => e.toTitleCase()).join(", "),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const Spacer(),
                Text(
                  DateFormat('MMM d, h:mm a').format(asset.updatedAt),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
        onTap: () {
          showModalBottomSheet(
            context: context,
            showDragHandle: true,
            builder: (context) => AnnotateAssetModal(asset: asset),
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

class AnnotateAssetModal extends StatelessWidget {
  const AnnotateAssetModal({super.key, required this.asset});

  final AnnotateAssetModel asset;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: getModalityColor(
                    asset.modality,
                  ).withAlpha(25),
                  child: Icon(
                    getModalityIcon(asset.modality),
                    color: getModalityColor(asset.modality),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        asset.name,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Created: ${DateFormat.yMMMd().format(asset.createdAt)}",
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              "Description",
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              asset.description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Annotation Modalities",
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (var modality in asset.modalitySet)
                  Chip(
                    label: Text(modality),
                    side: BorderSide(color: theme.colorScheme.outlineVariant),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              "Tags",
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (var tag in asset.tags)
                  Chip(
                    label: Text(tag.toTitleCase()),
                    side: BorderSide(color: theme.colorScheme.outlineVariant),
                  ),
              ],
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () {
                Navigator.pop(context);
                context.read<AnnotateTaskBloc>().add(
                  CreateAnnotateTaskEvent(asset: asset),
                );
              },
              icon: const Icon(Icons.play_arrow),
              label: const Text("Start Annotating"),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
