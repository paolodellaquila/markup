import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/bootstrap/helpers.dart';
import 'package:flutter_app/resources/pages/home_page.dart';
import 'package:flutter_app/resources/widgets/shared/bottomsheet/rounded_bottomsheet.dart';
import 'package:flutter_app/utils/video_manager.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:video_player/video_player.dart';

import '../../utils/app_version_comparator.dart';

class SplashScreen extends StatefulWidget {
  static String path = "/splash";

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  VideoPlayerController? _controller;
  bool _checkIsAppLocked = false;
  bool _isSplashCompleted = false;

  _navigateToHome() {
    _isSplashCompleted = true;
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    routeTo(HomePage.path, navigationType: NavigationType.pushReplace, pageTransition: PageTransitionType.fade);
  }

  _checkVideos() async {
    await _initializeVideoPlayer();

    Future.delayed(Duration(seconds: 5), () {
      if (_isSplashCompleted || _checkIsAppLocked) return;
      _navigateToHome();
    });
  }

  Future<bool> _isAppLocked() async {
    var minAppVersion = "";
    var minBuildVersion = "";

    try {
      final ref = FirebaseDatabase.instance.ref("settings").child('minAppVersion');
      final snapshot = await ref.get();
      if (snapshot.exists) {
        minAppVersion = snapshot.value.toString();
      } else {
        return true;
      }

      final ref2 = FirebaseDatabase.instance.ref("settings").child('minBuildVersion');
      final snapshot2 = await ref2.get();
      if (snapshot2.exists) {
        minBuildVersion = snapshot2.value.toString();
      } else {
        return true;
      }

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

  _checkAppVersion() async {
    var isAppLocked = await this._isAppLocked();

    if (isAppLocked) {
      _checkIsAppLocked = true;
      return showRoundedBottomSheet(
        context: context,
        primaryButtonText: "Update".tr(),
        isDismissible: false,
        onTapPrimaryButton: () => Platform.isIOS
            ? openBrowserTab(url: "https://apps.apple.com/app/markup-italia/id6538726254")
            : openBrowserTab(url: 'https://play.google.com/store/search?q=Markup%20Italia&c=apps&hl=it'),
        title: "App Blocked".tr(),
        message: "App Blocked Desc".tr(),
        icon: const Icon(Icons.report_outlined, size: 48),
      );
    }
  }

  @override
  void initState() {
    super.initState();

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    _checkAppVersion();
    _checkVideos();
  }

  Future<void> _initializeVideoPlayer() async {
    try {
      File? videoFile = await VideoManager().getRandomVideo();
      if (videoFile == null) {
        print("Error loading video: video file is null");
        return;
      }

      _controller = VideoPlayerController.file(videoFile)
        ..initialize().then((_) {
          setState(() {});
          _controller?.setVolume(0);
          _controller?.play();
        });
    } catch (e) {
      print("Error loading video: $e");
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      body: GestureDetector(
        onTap: () => _navigateToHome(),
        child: Center(
          child: _controller != null && _controller!.value.isInitialized
              ? VideoPlayer(_controller!)
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(width: 196, height: 196, "public/assets/app_icon/appicon.png"),
                    SizedBox(height: 4),
                    CircularProgressIndicator(),
                  ],
                ),
        ),
      ),
    );
  }
}
