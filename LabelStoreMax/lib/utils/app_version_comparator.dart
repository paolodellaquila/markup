import 'package:flutter/foundation.dart';

/// Compare 2 strings that contains a MAJOR.MINOR.PATCH system, and then it
/// return [storeVersion] if [localVersion] is lower then [storeVersion]. It
/// return an empty string otherwise
/// If we are in release mode, we check the build number too
String compareVersions({
  required String localVersion,
  required String storeVersion,
  required int localBuildNumber,
  required int storeBuildNumber,
}) {
  bool checkBuildNumber = kReleaseMode;

  var localVersionSplit = localVersion.split(".");
  var storeVersionSplit = storeVersion.split(".");
  var majorVersionUpdated = int.parse(localVersionSplit[0]) == int.parse(storeVersionSplit[0]);
  var minorVersionUpdated = int.parse(localVersionSplit[1]) == int.parse(storeVersionSplit[1]);
  var patchVersionUpdated = int.parse(localVersionSplit[2]) == int.parse(storeVersionSplit[2]);
  var buildNumberUpdated = checkBuildNumber ? localBuildNumber == storeBuildNumber : true;

  if (majorVersionUpdated && minorVersionUpdated && patchVersionUpdated && buildNumberUpdated) {
    return "";
  }

  for (int i = 0; i < localVersionSplit.length; i++) {
    if (int.parse(localVersionSplit[i]) > int.parse(storeVersionSplit[i])) {
      return "";
    }
  }
  if (checkBuildNumber) {
    if (localBuildNumber > storeBuildNumber) {
      return "";
    }
  }
  return "$storeVersion${checkBuildNumber ? " ($storeBuildNumber)" : ""}";
}
