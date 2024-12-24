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
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/config/firebase-messaging/firebase_notification_handler.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  _initDependencies() async {
    await _enableFcmNotifications();

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool? logAutoEnable = prefs.getBool('ADV_META_3_logAutoEnable');

    if (Platform.isIOS) {
      ///TRACKING ADV iOS
      await _trackingAdv_iOS(logAutoEnable, prefs);
    } else {
      ///TRACKING ADV ANDROID
      await _trackingAdv_Android(logAutoEnable, prefs);
    }
  }

  @override
  init() {
    _initDependencies();
  }

  Future<void> _trackingAdv_iOS(bool? logAutoEnable, SharedPreferences prefs) async {
    // If the system can show an authorization request dialog
    if (await AppTrackingTransparency.trackingAuthorizationStatus == TrackingStatus.notDetermined || logAutoEnable == null) {
      // Show a custom explainer dialog before the system dialog
      await _showCustomTrackingDialog(context);
      // Wait for dialog popping animation
      await Future.delayed(const Duration(milliseconds: 200));
      // Request system's tracking authorization dialog
      AppTrackingTransparency.requestTrackingAuthorization();
      await AppTrackingTransparency.requestTrackingAuthorization();
    }

    final result = await AppTrackingTransparency.trackingAuthorizationStatus == TrackingStatus.authorized;
    await _checkADVAndEnabledIt(advTracking: result, logApp: result, prefs: prefs);
  }

  Future<void> _trackingAdv_Android(bool? logAutoEnable, SharedPreferences prefs) async {
    if (logAutoEnable == null) {
      final result = await _showCustomTrackingDialog(context);
      if (result != null) {
        await _checkADVAndEnabledIt(advTracking: result, logApp: result, prefs: prefs);
      }
    }
  }

  _checkADVAndEnabledIt({required bool advTracking, required bool logApp, required SharedPreferences prefs}) async {
    FacebookAppEvents().setAdvertiserTracking(enabled: advTracking);
    FacebookAppEvents().setAutoLogAppEventsEnabled(logApp);
    FirebaseAnalytics.instance.setConsent(
      adStorageConsentGranted: advTracking,
      analyticsStorageConsentGranted: logApp,
      adPersonalizationSignalsConsentGranted: advTracking,
      adUserDataConsentGranted: advTracking,
      functionalityStorageConsentGranted: advTracking,
      personalizationStorageConsentGranted: advTracking,
      securityStorageConsentGranted: advTracking,
    );
    await prefs.setBool('ADV_META_3_logAutoEnable', advTracking);
  }

  Future<bool?> _showCustomTrackingDialog(BuildContext context) async => showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => PopScope(
          onPopInvoked: (popResult) {
            return;
          },
          child: AlertDialog(title: Text('Normativa Trasparenza Pubblicitaria V3'.tr()), content: Text("${'Caro utente'.tr()}\n${'cookie'.tr()}"), actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Rifiuto'.tr()),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text('Accept'.tr()),
            ),
          ]),
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
