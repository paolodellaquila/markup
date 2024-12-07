import 'dart:ui' as ui;

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/firebase_options.dart';
import 'package:flutter_app/utils/universal_manager_cubit.dart';
import 'package:nylo_framework/nylo_framework.dart';

import '/bootstrap/app.dart';
import '/bootstrap/boot.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  ///Deeplink
  UniversalLinkManagerCubit().init();

  ///Nylo Framework
  Nylo nylo = await Nylo.init(setup: Boot.nylo, setupFinished: Boot.finished);

  ///Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  FirebaseAnalyticsObserver observer = FirebaseAnalyticsObserver(analytics: analytics);
  analytics.logAppOpen();

  runApp(
    MediaQuery(
      data: MediaQueryData.fromWindow(ui.window).copyWith(
        textScaler: TextScaler.linear(1.0),
      ),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: AppBuild(
          navigatorKey: NyNavigator.instance.router.navigatorKey,
          onGenerateRoute: nylo.router!.generator(),
          initialRoute: nylo.getInitialRoute(),
          navigatorObservers: [
            ...nylo.getNavigatorObservers(),
            observer,
          ],
          debugShowCheckedModeBanner: false,
        ),
      ),
    ),
  );
}
