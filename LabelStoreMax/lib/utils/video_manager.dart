import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

class VideoManager {
  final Dio _dio = Dio();
  final String _url = "https://markupitalia.com/wp-content/uploads/reel-campaign/";
  Directory? _localDir;

  static final VideoManager _singleton = VideoManager._internal();

  factory VideoManager() {
    return _singleton;
  }

  VideoManager._internal();

  Future<void> initialize() async {
    final path = await getApplicationSupportDirectory();
    if (!Directory("${path.path}/markup").existsSync()) {
      await Directory("${path.path}/markup").create();
    }
    _localDir = Directory("${path.path}/markup");
    final result = await areVideosDownloaded();
    if (!result) {
      await _downloadVideos();
    }
    await _checkForUpdates();
  }

  Future<void> _downloadVideos() async {
    try {
      Response response = await _dio.get<List<dynamic>>(
        _url,
        options: Options(responseType: ResponseType.json),
      );
      List<String> remoteVideos = (response.data as List).map((e) => e.toString()).toList();
      for (String video in remoteVideos) {
        await _downloadFile(video);
      }
    } catch (e) {
      print("Error downloading videos: $e");
    }
  }

  Future<void> _downloadFile(String fileName) async {
    String fileUrl = '$_url$fileName';
    String filePath = '${_localDir!.path}/$fileName';
    try {
      await _dio.download(fileUrl, filePath);
    } catch (e) {
      print("Error downloading file $fileName: $e");
    }
  }

  Future<void> _checkForUpdates() async {
    try {
      Response response = await _dio.get<List<dynamic>>(
        _url,
        options: Options(responseType: ResponseType.json),
      );
      List<String> remoteVideos = (response.data as List).map((e) => e.toString()).toList();
      if (_isUpdateRequired(remoteVideos)) {
        await _deleteLocalVideos();
        await _downloadVideos();
      }
    } catch (e) {
      print("Error checking for updates: $e");
    }
  }

  bool _isUpdateRequired(List<String> remoteVideos) {
    List<String> localVideos = _localDir!.listSync().map((e) => e.path.split('/').last).toList();
    return !remoteVideos.every((element) => localVideos.contains(element));
  }

  Future<void> _deleteLocalVideos() async {
    for (FileSystemEntity file in _localDir!.listSync()) {
      if (file is File) {
        await file.delete();
      }
    }
  }

  Future<File?> getRandomVideo() async {
    List<FileSystemEntity> files = _localDir!.listSync();
    if (files.isEmpty) {
      return null;
    }
    Random random = Random();
    int index = random.nextInt(files.length);
    return files[index] as File;
  }

  Future<bool> areVideosDownloaded() async {
    List<FileSystemEntity> files = _localDir!.listSync();
    return files.isNotEmpty;
  }
}
