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
    debugPrint("Getting recent tasks from workspace directory");
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
    final s3Url = S3UrlModel.fromJson(res.data);
    // Download zip asset's dataset batch
    final Directory tempDir = await getTemporaryDirectory();
    final savedPath = "${tempDir.path}/${asset.datasetId}.zip";
    try {
      await Dio().download(
        s3Url.url,
        savedPath,
        onReceiveProgress: (count, total) {
          debugPrint("$total/$count");
        },
      );
      // final res = await Dio().get(S3UrlModel.url);
      // if (res.statusCode != 200) {
      //   throw Exception("Failed to download dataset batch - 1");
      // }
      // final file = File(savedPath);
      // await file.writeAsBytes(res.data);
    } catch (e) {
      debugPrint(s3Url.url);
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

  Future<void> publishTask({required AnnotateTaskModel task}) async {
    final res = await client.post(
      "assets/publish-upload-url",
      data: {"asset_id": task.id},
    );
    if (res.statusCode != 200) {
      throw Exception("Failed to get publish url");
    }
    final s3Url = S3UrlModel.fromJson(res.data);
    // Zip only task.json and outputs directory
    final taskPath = await task.taskPath;
    final zipFile = File("${taskPath.path}.zip");

    final archive = Archive();

    // Add task.json
    final taskFile = File("${taskPath.path}/task.json");
    if (await taskFile.exists()) {
      debugPrint("Adding task.json to archive");
      final bytes = await taskFile.readAsBytes();
      archive.addFile(ArchiveFile('task.json', bytes.length, bytes));
    } else {
      debugPrint("task.json not found at ${taskFile.path}");
    }

    // Add outputs directory recursively
    final outputsDir = Directory("${taskPath.path}/outputs");
    if (await outputsDir.exists()) {
      debugPrint("Adding outputs directory contents to archive");
      final List<FileSystemEntity> entities = await outputsDir
          .list(recursive: true)
          .toList();
      for (var entity in entities) {
        if (entity is File) {
          // Calculate relative path from taskPath and ensure forward slashes
          final relativePath = entity.path
              .substring(taskPath.path.length + 1)
              .replaceAll('\\', '/');
          debugPrint("Adding file to archive: $relativePath");
          final bytes = await entity.readAsBytes();
          archive.addFile(ArchiveFile(relativePath, bytes.length, bytes));
        }
      }
    } else {
      debugPrint("outputs directory not found at ${outputsDir.path}");
    }

    // Encode the archive to zip format
    final zipData = ZipEncoder().encode(archive);
    await zipFile.writeAsBytes(zipData);

    // Upload to S3 using PUT request
    // We use a fresh Dio instance to avoid repository headers (like Auth)
    // being added to the S3 request which would cause signature mismatch.
    try {
      final uploadRes = await Dio().put(
        s3Url.url,
        data: zipFile.openRead(),
        options: Options(
          headers: {
            HttpHeaders.contentTypeHeader: "application/zip",
            HttpHeaders.contentLengthHeader: await zipFile.length(),
          },
        ),
      );

      if (uploadRes.statusCode != 200 && uploadRes.statusCode != 201) {
        throw Exception(
          "Failed to upload task data to S3: ${uploadRes.statusMessage}",
        );
      }
    } finally {
      // Clean up the temporary zip file after upload (or failure)
      if (await zipFile.exists()) {
        await zipFile.delete();
      }
    }
    await client.post(
      "assets/acknowledge-publish",
      data: {"asset_id": task.id},
    );
  }
}
