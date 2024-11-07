import 'package:flutter/foundation.dart';

/// Compare 2 strings that contains a MAJOR.MINOR.PATCH system, and then it
/// returns [storeVersion] if [localVersion] is lower than [storeVersion]. It
/// returns an empty string otherwise.
/// If we are in release mode, it also compares the build number.
String compareVersions({
  required String localVersion,
  required String storeVersion,
  required int localBuildNumber,
  required int storeBuildNumber,
}) {
  bool checkBuildNumber = kReleaseMode;

  var localVersionSplit = localVersion.split(".").map(int.parse).toList();
  var storeVersionSplit = storeVersion.split(".").map(int.parse).toList();

  // Ensure both version arrays have exactly 3 elements for major, minor, and patch
  while (localVersionSplit.length < 3) localVersionSplit.add(0);
  while (storeVersionSplit.length < 3) storeVersionSplit.add(0);

  // Compare major, minor, and patch versions
  for (int i = 0; i < 3; i++) {
    if (localVersionSplit[i] < storeVersionSplit[i]) {
      return "$storeVersion${checkBuildNumber ? " ($storeBuildNumber)" : ""}";
    } else if (localVersionSplit[i] > storeVersionSplit[i]) {
      return "";
    }
  }

  // Compare build numbers if in release mode
  if (checkBuildNumber && localBuildNumber < storeBuildNumber) {
    return "$storeVersion ($storeBuildNumber)";
  }

  return "";
}
