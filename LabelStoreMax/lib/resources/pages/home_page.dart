//  Label StoreMax
//
//  Created by Anthony Gordon.
//  2024, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/config/firebase-messaging/firebase_notification_handler.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:woosignal/models/response/woosignal_app.dart';

import '/bootstrap/app_helper.dart';
import '/resources/widgets/compo_theme_widget.dart';
import '/resources/widgets/mello_theme_widget.dart';
import '/resources/widgets/notic_theme_widget.dart';

class HomePage extends StatefulWidget {
  static String path = "/home";
  HomePage();

  @override
  createState() => _HomePageState();
}

class _HomePageState extends NyState<HomePage> {
  _HomePageState();

  final WooSignalApp? _wooSignalApp = AppHelper.instance.appConfig;

  @override
  init() async {
    await _enableFcmNotifications();
  }

  _enableFcmNotifications() async {
    bool? firebaseFcmIsEnabled = AppHelper.instance.appConfig?.firebaseFcmIsEnabled;
    firebaseFcmIsEnabled ??= getEnv('FCM_ENABLED', defaultValue: false);

    if (firebaseFcmIsEnabled != true) return;

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {});

    ///INNESTING FCM Custom Class
    FirebaseNotifications().setUpFirebase(context);
  }

  @override
  Widget build(BuildContext context) {
    return match(
        AppHelper.instance.appConfig?.theme,
        () => {
              "notic": NoticThemeWidget(wooSignalApp: _wooSignalApp),
              "compo": CompoThemeWidget(wooSignalApp: _wooSignalApp),
              "mello": MelloThemeWidget(wooSignalApp: _wooSignalApp),
            },
        defaultValue: MelloThemeWidget(wooSignalApp: _wooSignalApp));
  }
}
