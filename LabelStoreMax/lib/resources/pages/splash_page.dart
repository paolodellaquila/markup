import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_app/bootstrap/helpers.dart';
import 'package:flutter_app/resources/pages/home_page.dart';
import 'package:flutter_app/resources/widgets/buttons.dart';
import 'package:flutter_app/utils/app_version/app_version_check.dart';
import 'package:flutter_app/utils/remote_config_manager.dart';
import 'package:nylo_framework/nylo_framework.dart';

class SplashScreen extends StatefulWidget {
  static String path = "/splash";

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _checkIsAppLocked = false;

  _navigateToHome() {
    routeTo(HomePage.path, navigationType: NavigationType.pushReplace, pageTransition: PageTransitionType.fade);
  }

  _initTimer() async {
    Future.delayed(Duration(seconds: 1), () {
      _navigateToHome();
    });
  }

  _checkAppVersion() async {
    await RemoteConfigManager.instance.init();
    _checkIsAppLocked = await AppVersionCheck.checkAppVersion();

    if (_checkIsAppLocked) {
      return showModalBottomSheet(
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

    _initTimer();
  }

  @override
  void initState() {
    super.initState();

    _checkAppVersion();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      body: GestureDetector(
        onTap: () => _navigateToHome(),
        child: Center(
          child: Column(
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
