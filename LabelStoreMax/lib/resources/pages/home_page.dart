//  Label StoreMax
//
//  Created by Anthony Gordon.
//  2024, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'dart:io';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:facebook_app_events/facebook_app_events.dart';
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

    ///TRACKING ADV iOS
    if (Platform.isIOS) {
      await _trackingAdv();
    }
  }

  Future<void> _trackingAdv() async {
    // If the system can show an authorization request dialog
    if (await AppTrackingTransparency.trackingAuthorizationStatus == TrackingStatus.notDetermined) {
      // Show a custom explainer dialog before the system dialog
      await _showCustomTrackingDialog(context);
      // Wait for dialog popping animation
      await Future.delayed(const Duration(milliseconds: 200));
      // Request system's tracking authorization dialog
      await AppTrackingTransparency.requestTrackingAuthorization();
    }

    await _checkADVAndEnabledIt();
  }

  _checkADVAndEnabledIt() async {
    if (await AppTrackingTransparency.trackingAuthorizationStatus == TrackingStatus.authorized) {
      FacebookAppEvents().setAdvertiserTracking(enabled: true);
      FacebookAppEvents().setAutoLogAppEventsEnabled(true);
    }
  }

  Future<void> _showCustomTrackingDialog(BuildContext context) async => await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Caro utente'.tr()),
          content: Text('cookie'.tr()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Continue'.tr()),
            ),
          ],
        ),
      );

  _enableFcmNotifications() async {
    bool? firebaseFcmIsEnabled = AppHelper.instance.appConfig?.firebaseFcmIsEnabled;
    firebaseFcmIsEnabled ??= getEnv('FCM_ENABLED', defaultValue: false);

    if (firebaseFcmIsEnabled != true) return;

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
