import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uinlp_annotate_repository/models/annotate_task.dart';
import 'package:uinlp_annotate_repository/models/user_stats.dart';
import 'package:uinlp_annotate_repository/repositories/base.dart';

final class UinlpAnnotateRepositoryMock extends UinlpAnnotateRepository {
  final client = Dio(BaseOptions(baseUrl: "http://10.54.227.218:8000/v1/"));

  @override
  Future<UserStatsModel> getUserStatsModel() async {
    await Future.delayed(const Duration(seconds: 1));
    return const UserStatsModel(
      tasksCompleted: 142,
      tasksInProgress: 5,
      hoursSpent: 28,
      accuracy: 0.94,
    );
  }

  @override
  Future<List<AnnotateAssetModel>> getRecentAssets({
    int limit = 10,
    int offset = 0,
    TaskTypeEnum? type,
  }) async {
    final response = await client.get("assets");
    return (response.data as List)
        .map((e) => AnnotateAssetModel.fromJson(e))
        .toList();
  }

  @override
  Future<AnnotateTaskModel> createAnnotateTask({
    required AnnotateAssetModel asset,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    // Download zip asset
    final Directory tempDir = await getTemporaryDirectory();
    final savedPath = "${tempDir.path}/${asset.datasetId}.zip";
    await client.download("assets/${asset.datasetId}/download", savedPath);
    // Unzip asset and save to workspace
    final assetDir = Directory(
      "${(await getWorkspaceDirectory()).path}/${asset.id}",
    );
    await assetDir.create(recursive: true);
    await extractFileToDisk(savedPath, assetDir.path);
    List<String> dataIds = [];
    final dataDir = Directory("${assetDir.path}/data");
    if (dataDir.existsSync()) {
      dataIds = dataDir
          .listSync()
          .whereType<File>()
          .map((e) => e.path.split(Platform.pathSeparator).last)
          .toList();
    }
    // Update task with metadata info
    final task = AnnotateTaskModel(
      id: asset.id,
      datasetId: asset.datasetId,
      datasetBatchKey: asset.datasetBatchKey,
      name: asset.name,
      description: asset.description,
      modality: asset.modality,
      status: TaskStatusEnum.inProgress,
      dataIds: dataIds,
      lastUpdated: DateTime.now(),
      annotateFields: asset.annotateFields,
      tags: asset.tags,
    );
    // Store task as a task.json file in assetDir
    await task.saveTaskFile();
    // Return updated task
    return task;
  }
}
