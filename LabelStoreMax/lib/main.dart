import 'dart:ui' as ui;

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/firebase_options.dart';
import 'package:flutter_app/utils/video_manager.dart';
import 'package:nylo_framework/nylo_framework.dart';

import '/bootstrap/app.dart';
import '/bootstrap/boot.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Nylo nylo = await Nylo.init(setup: Boot.nylo, setupFinished: Boot.finished);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  VideoManager().initialize();

  runApp(
    MediaQuery(
      data: MediaQueryData.fromWindow(ui.window),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: AppBuild(
          navigatorKey: NyNavigator.instance.router.navigatorKey,
          onGenerateRoute: nylo.router!.generator(),
          initialRoute: nylo.getInitialRoute(),
          navigatorObservers: [
            ...nylo.getNavigatorObservers(),
          ],
          debugShowCheckedModeBanner: false,
        ),
      ),
    ),
  );
}
