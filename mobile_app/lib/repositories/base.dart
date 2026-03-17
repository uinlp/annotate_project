import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

base class BaseRepository {
  late Dio client;
  String? accessToken;
  Future<String> Function()? accessTokenRetriever;
  final Completer isInitialized = Completer();

  void init({Future<String> Function()? accessTokenRetriever}) {
    debugPrint("Initializing $runtimeType");
    if (isInitialized.isCompleted) {
      debugPrint("$runtimeType already initialized");
      return;
    }
    this.accessTokenRetriever = accessTokenRetriever;
    final baseUrl = const String.fromEnvironment("API_BASE_URL");
    print("API_BASE_URL: $baseUrl");
    client = Dio(
      BaseOptions(baseUrl: "$baseUrl/v1/", validateStatus: (status) => true),
    );
    client.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          debugPrint("Request: ${options.method} ${options.path}");
          if (accessToken != null) {
            debugPrint("Using access token");
            options.headers["Authorization"] = "Bearer $accessToken";
          } else if (accessTokenRetriever != null) {
            debugPrint("Getting access token");
            accessToken = await accessTokenRetriever();
            debugPrint("Got access token");
            options.headers["Authorization"] = "Bearer $accessToken";
          } else {
            debugPrint("No access token");
          }
          handler.next(options);
        },
        onResponse: (response, handler) async {
          debugPrint("Response: ${response.statusCode}");
          if (response.statusCode == 401 && this.accessTokenRetriever != null) {
            debugPrint("Refreshing access token");
            accessToken = await this.accessTokenRetriever!();
            response.headers.add("Authorization", "Bearer $accessToken");
            handler.resolve(response);
          } else {
            handler.next(response);
          }
        },
      ),
    );
    isInitialized.complete();
    debugPrint("$runtimeType initialized");
  }

  static Future<Directory> getWorkspaceDirectory() async {
    // final appDocDir = await getApplicationDocumentsDirectory();
    final appDocDir = await getExternalStorageDirectory();
    final workspaceDir = Directory("${appDocDir!.path}/uinlp_workspace");
    if (!await workspaceDir.exists()) {
      await workspaceDir.create(recursive: true);
    }
    return workspaceDir;
  }
}
