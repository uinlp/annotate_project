import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uinlp_annotate/components/activity_tile.dart';
import 'package:uinlp_annotate/components/status_card.dart';
import 'package:uinlp_annotate/features/annotate_task/bloc/annotate_task_bloc.dart';
import 'package:uinlp_annotate/features/annotate_task/screens/annotate_editor_screen.dart';
import 'package:uinlp_annotate/utilities/status.dart';

class RecentTasksScreen extends StatelessWidget {
  const RecentTasksScreen({super.key});

  static const routeName = 'recent-tasks';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Recent Tasks")),
      body: BlocBuilder<AnnotateTaskBloc, AnnotateTaskState>(
        builder: (context, state) {
          if (state.status is LoadingStatus) {
            return LoadingCard();
          }
          if (state.tasks.isEmpty) {
            return ErrorCard(title: "Error", message: "No recent tasks");
          }
          return GridView.extent(
            padding: const EdgeInsets.all(16),
            maxCrossAxisExtent: 800,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio:
                MediaQuery.sizeOf(context).width /
                (MediaQuery.sizeOf(context).width < 850 ? 125 : 250),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: List.generate(state.tasks.length, (index) {
              final task = state.tasks[index];
              return ActivityTile(task: task, margin: .zero);
            }),
          );
        },
      ),
    );
  }
}
