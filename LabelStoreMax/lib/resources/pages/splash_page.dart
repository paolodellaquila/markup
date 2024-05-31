import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/resources/pages/home_page.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:video_player/video_player.dart';

class SplashScreen extends StatefulWidget {
  static String path = "/splash";

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  VideoPlayerController? _controller;
  bool _isSplashCompleted = false;

  _navigateToHome() {
    _isSplashCompleted = true;
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    routeTo(HomePage.path, navigationType: NavigationType.pushReplace, pageTransition: PageTransitionType.fade);
  }

  _checkVideos() async {
    await _initializeVideoPlayer();

    Future.delayed(Duration(seconds: 5), () {
      if (_isSplashCompleted) return;
      _navigateToHome();
    });
  }

  @override
  void initState() {
    super.initState();

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    _checkVideos();
  }

  Future<void> _initializeVideoPlayer() async {
    try {
      /*File? videoFile = await VideoManager().getRandomVideo();
      if (videoFile == null) {
        print("Error loading video: video file is null");
        return;
      }*/

      int index = Random().nextInt(3) + 1;
      _controller = VideoPlayerController.asset("public/assets/videos/${index}.mp4")
        ..initialize().then((_) {
          setState(() {});
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
              : Image.asset(width: 96, height: 96, "public/assets/app_icon/appicon.png"),
        ),
      ),
    );
  }
}
