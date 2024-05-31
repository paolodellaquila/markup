import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';

import '/bootstrap/app.dart';
import '/bootstrap/boot.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Nylo nylo = await Nylo.init(setup: Boot.nylo, setupFinished: Boot.finished);
  //VideoManager().initialize();

  runApp(
    AppBuild(
      navigatorKey: NyNavigator.instance.router.navigatorKey,
      onGenerateRoute: nylo.router!.generator(),
      initialRoute: nylo.getInitialRoute(),
      navigatorObservers: [
        ...nylo.getNavigatorObservers(),
      ],
      debugShowCheckedModeBanner: false,
    ),
  );
}
