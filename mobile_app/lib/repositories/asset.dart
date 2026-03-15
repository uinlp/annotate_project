import 'package:flutter/material.dart';
import 'package:uinlp_annotate/models/annotate_task.dart';
import 'package:uinlp_annotate/repositories/base.dart';

final class AssetRepository extends BaseRepository {
  AssetRepository() : super();

  Future<List<AnnotateAssetModel>> getRecentAssets({
    int limit = 10,
    int offset = 0,
    TaskTypeEnum? type,
  }) async {
    final response = await client.get("assets/");
    debugPrint("Assets: ${response.data.toString()}");
    return (response.data as List)
        .map((e) => AnnotateAssetModel.fromJson(e))
        .toList();
  }
}
