import 'package:flutter/material.dart';
import 'package:uinlp_annotate/models/annotate_task.dart';
import 'package:uinlp_annotate/repositories/base.dart';

final class AssetRepository extends BaseRepository {
  AssetRepository() : super();

  Future<List<AnnotateAssetModel>> getRecentAssets({
    int limit = 10,
    int offset = 0,
    AnnotateModalityEnum? modality,
  }) async {
    debugPrint(
      "Getting assets with limit: $limit, offset: $offset, modality: $modality",
    );
    final response = await client.get(
      "assets/",
      queryParameters: {
        "limit": limit,
        "offset": offset,
        if (modality != null) "modality": modality.repr,
      },
    );
    debugPrint("Assets: ${response.data.toString()}");
    return (response.data as List)
        .map((e) => AnnotateAssetModel.fromJson(e))
        .toList();
  }
}
