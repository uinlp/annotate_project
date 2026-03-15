import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import '../models/annotate_task.dart';
import '../models/user_stats.dart';

abstract base class UinlpAnnotateRepository {
  const UinlpAnnotateRepository();

  // Future<void> init();

  // Future<void> dispose();

  Future<UserStatsModel> getUserStatsModel();
  Future<List<AnnotateTaskModel>> getRecentTasks({
    int limit = 10,
    int offset = 0,
    TaskTypeEnum? type,
  }) async {
    // return store.selectTasks();
    print("Getting recent tasks from workspace directory");
    final workspaceDir = await getWorkspaceDirectory();
    final tasks = <AnnotateTaskModel>[];
    debugPrint("Workspace list: ${workspaceDir.listSync().map((e) => e.path)}");
    for (final file in workspaceDir.listSync()) {
      if (file is Directory) {
        final taskFile = File("${file.path}/task.json");
        if (taskFile.existsSync()) {
          final taskJson = jsonDecode(taskFile.readAsStringSync());
          tasks.add(AnnotateTaskModel.fromJson(taskJson));
        }
      }
    }
    return tasks;
  }

  Future<List<AnnotateAssetModel>> getRecentAssets({
    int limit = 10,
    int offset = 0,
  });
  Future<AnnotateTaskModel> createAnnotateTask({
    required AnnotateAssetModel asset,
  });
  // Future<List<TaskTypeEnum>> getAvailableTaskTypeEnums(); // TaskTypeEnum is an enum, maybe just hardcode or return list of available ones if dynamic.
}

Future<Directory> getWorkspaceDirectory() async {
  final appDocDir = await getApplicationDocumentsDirectory();
  final workspaceDir = Directory("${appDocDir.path}/uinlp_workspace");
  if (!await workspaceDir.exists()) {
    await workspaceDir.create(recursive: true);
  }
  return workspaceDir;
}
