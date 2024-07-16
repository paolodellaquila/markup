import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';

class VideoManager {
  Directory? _localDir;

  static final VideoManager _singleton = VideoManager._internal();

  factory VideoManager() {
    return _singleton;
  }

  VideoManager._internal();

  Future<void> loadDirectory() async {
    final path = await getApplicationSupportDirectory();
    if (!Directory("${path.path}/markup").existsSync()) {
      await Directory("${path.path}/markup").create();
    }
    _localDir = Directory("${path.path}/markup");
  }

  Future<void> initialize() async {
    await loadDirectory();
    final result = await areVideosDownloaded();
    if (!result) {
      await _downloadVideos();
    }
    await _checkForUpdates();
  }

  Future<void> _downloadVideos() async {
    final result = await FirebaseStorage.instance.ref().child('intro_videos').listAll();
    for (var ref in result.items) {
      _downloadFile(ref.name);
    }
  }

  Future<void> _downloadFile(String fileName) async {
    try {
      final ref = FirebaseStorage.instance.ref().child('intro_videos').child(fileName);
      final file = File('${_localDir!.path}/$fileName');
      await ref.writeToFile(file);
    } catch (e) {
      print("Error downloading file: $e");
    }
  }

  Future<void> _checkForUpdates() async {
    try {
      final result = await FirebaseStorage.instance.ref().child('intro_videos').listAll();
      List<String> remoteVideos = result.items.map((e) => e.name).toList();
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
    await loadDirectory();
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
