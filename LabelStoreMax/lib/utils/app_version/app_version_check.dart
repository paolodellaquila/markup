import 'package:flutter_app/utils/app_version_comparator.dart';
import 'package:flutter_app/utils/remote_config_manager.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppVersionCheck {
  static final AppVersionCheck _singleton = AppVersionCheck._internal();

  factory AppVersionCheck() {
    return _singleton;
  }

  AppVersionCheck._internal();

  static Future<bool> _isAppLocked() async {
    try {
      var minAppVersion = RemoteConfigManager.instance.appRemoteVersion;
      var minBuildVersion = RemoteConfigManager.instance.appRemoteBuildNumber.toString();

      // final ref = FirebaseDatabase.instance.ref("settings").child('minAppVersion');
      // final snapshot = await ref.get();
      // if (snapshot.exists) {
      //   minAppVersion = snapshot.value.toString();
      // } else {
      //   return true;
      // }
      //
      // final ref2 = FirebaseDatabase.instance.ref("settings").child('minBuildVersion');
      // final snapshot2 = await ref2.get();
      // if (snapshot2.exists) {
      //   minBuildVersion = snapshot2.value.toString();
      // } else {
      //   return true;
      // }

      var packageInfo = await PackageInfo.fromPlatform();
      String localVersion = packageInfo.version;
      String localBuildNumber = packageInfo.buildNumber;

      var checkVersion = compareVersions(
        localVersion: localVersion,
        storeVersion: minAppVersion,
        localBuildNumber: int.parse(localBuildNumber),
        storeBuildNumber: int.parse(minBuildVersion),
      );

      return checkVersion.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  static checkAppVersion() async {
    return await _isAppLocked();
  }
}
