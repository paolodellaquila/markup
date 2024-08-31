import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_app/resources/pages/splash_page.dart';
import 'package:flutter_app/utils/remote_config_manager.dart';
import 'package:flutter_app/utils/repository/remote_config_repository.dart';
import 'package:nylo_framework/nylo_framework.dart';

class FirebaseRemoteConfigRepository implements RemoteConfigRepository {
  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;

  @override
  Future<bool> initialize({Map<String, dynamic>? defaultParameters}) async {
    await _remoteConfig.ensureInitialized();

    await _remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(seconds: 10),
      minimumFetchInterval: kDebugMode ? Duration.zero : const Duration(hours: 1),
    ));

    if (defaultParameters != null) {
      await _remoteConfig.setDefaults(defaultParameters);
    }

    final success = await _fetchingAndActive();

    ///Enable Persist RealTime Listener
    _remoteConfig.onConfigUpdated.listen((event) async {
      if (event.updatedKeys.contains(RemoteConfigManager.MIN_APP_VERSION_KEY) || event.updatedKeys.contains(RemoteConfigManager.MIN_BUILD_NUMBER_KEY)) {
        await _remoteConfig.activate();

        routeTo(SplashScreen.path, navigationType: NavigationType.pushReplace, pageTransition: PageTransitionType.fade);
      }
    });

    return success;
  }

  Future<bool> _fetchingAndActive() async {
    bool success = true;
    try {
      await _remoteConfig.fetchAndActivate();
    } on FirebaseException catch (firebaseException) {
      //logger.e('Fetch and activate error: ${firebaseException.message}');
      success = false;
    }

    return success;
  }

  @override
  String getString(String key) => _remoteConfig.getString(key);

  @override
  bool getBool(String key) => _remoteConfig.getBool(key);

  @override
  int getInt(String key) => _remoteConfig.getInt(key);

  @override
  double getDouble(String key) => _remoteConfig.getDouble(key);

  @override
  T getMap<T>(String key, {ModelFromJson<T>? fromJson}) {
    final Map<String, dynamic> map = jsonDecode(_remoteConfig.getString(key)) as Map<String, dynamic>;
    if (fromJson == null) return map as T;
    return fromJson(map);
  }

  @override
  List<T> getList<T>(String key, {ModelFromJson<T>? fromJson}) {
    final List<dynamic> list = jsonDecode(_remoteConfig.getString(key)) as List<dynamic>;

    final finalList = list.map((dynamic e) {
      if (fromJson == null) return e as T;
      return fromJson(e as Map<String, dynamic>);
    }).toList();

    return finalList;
  }
}
