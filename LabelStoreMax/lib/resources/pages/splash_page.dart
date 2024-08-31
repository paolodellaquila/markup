import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/bootstrap/helpers.dart';
import 'package:flutter_app/resources/pages/home_page.dart';
import 'package:flutter_app/resources/widgets/buttons.dart';
import 'package:flutter_app/utils/app_version/app_version_check.dart';
import 'package:flutter_app/utils/remote_config_manager.dart';
import 'package:flutter_app/utils/video_manager.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:video_player/video_player.dart';

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

  _checkAppVersion() async {
    await RemoteConfigManager.instance.init();
    _checkIsAppLocked = await AppVersionCheck.checkAppVersion();

    if (_checkIsAppLocked) {
      showModalBottomSheet(
          context: context,
          builder: (BuildContext context) => Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.report_outlined, size: 48),
                    SizedBox(height: 16),
                    Text(
                      "Update Needed".tr(),
                      style: context.textTheme().headlineMedium,
                    ),
                    SizedBox(height: 16),
                    Text(
                      "App Blocked Desc".tr(),
                      style: context.textTheme().bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16),
                    PrimaryButton(
                      title: "Update".tr(),
                      action: () => Platform.isIOS
                          ? openBrowserTab(url: RemoteConfigManager.instance.appStoreUrl)
                          : openBrowserTab(url: RemoteConfigManager.instance.playStoreUrl),
                    ),
                    SizedBox(height: 16),
                  ],
                ),
              ));
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
