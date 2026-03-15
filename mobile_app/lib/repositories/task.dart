import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uinlp_annotate/models/annotate_task.dart';
import 'package:uinlp_annotate/repositories/base.dart';

final class TaskRepository extends BaseRepository {
  TaskRepository() : super();

  Future<List<AnnotateTaskModel>> getRecentTasks({
    int limit = 10,
    int offset = 0,
    TaskTypeEnum? type,
  }) async {
    // return store.selectTasks();
    print("Getting recent tasks from workspace directory");
    final workspaceDir = await BaseRepository.getWorkspaceDirectory();
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

  Future<AnnotateTaskModel> createAnnotateTask({
    required AnnotateAssetModel asset,
  }) async {
    // Get asset's dataset batch url
    debugPrint("Dataset batch key: ${asset.datasetBatchKey}");
    final res = await client.post(
      "datasets/batch-download-url",
      data: {"batch_key": asset.datasetBatchKey},
    );
    if (res.statusCode != 200) {
      throw Exception("Failed to get dataset batch url");
    }
    debugPrint("Data: ${res.data}");
    final datasetBatchDownloadModel = DatasetBatchDownloadModel.fromJson(
      res.data,
    );
    // Download zip asset's dataset batch
    final Directory tempDir = await getTemporaryDirectory();
    final savedPath = "${tempDir.path}/${asset.datasetId}.zip";
    try {
      await Dio().download(
        datasetBatchDownloadModel.url,
        savedPath,
        onReceiveProgress: (count, total) {
          debugPrint("$total/$count");
        },
      );
      // final res = await Dio().get(datasetBatchDownloadModel.url);
      // if (res.statusCode != 200) {
      //   throw Exception("Failed to download dataset batch - 1");
      // }
      // final file = File(savedPath);
      // await file.writeAsBytes(res.data);
    } catch (e) {
      debugPrint(datasetBatchDownloadModel.url);
      debugPrint(
        "Failed to download dataset batch: datasets/batch-download-url/${asset.datasetBatchKey} \n $e",
      );
      throw Exception("Failed to download dataset batch");
    }
    // Unzip asset's dataset batch and save to workspace
    final assetDir = Directory(
      "${(await BaseRepository.getWorkspaceDirectory()).path}/${asset.id}",
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
