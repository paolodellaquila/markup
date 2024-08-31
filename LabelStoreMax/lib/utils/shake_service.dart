import 'package:flutter/material.dart';
import 'package:flutter_app/bootstrap/helpers.dart';
import 'package:flutter_app/resources/widgets/buttons.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:shake/shake.dart';

class ShakeService {
  static final ShakeService _instance = ShakeService._internal();
  ShakeDetector? _shakeDetector;

  factory ShakeService() {
    return _instance;
  }

  ShakeService._internal();

  void startListening(BuildContext context) {
    if (_shakeDetector == null) {
      _shakeDetector = ShakeDetector.autoStart(onPhoneShake: () {
        showModalBottomSheet(
          context: context,
          builder: (BuildContext context) => Container(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'You need help?'.tr(),
                    textAlign: TextAlign.center,
                    style: context.textTheme().headlineSmall,
                  ),
                  Text(
                    'Contact our support team'.tr(),
                    textAlign: TextAlign.center,
                    style: context.textTheme().bodyMedium,
                  ),
                  SizedBox(
                    height: 32,
                  ),
                  PrimaryButton(
                    title: "Continue".tr(),
                    action: () {
                      openBrowserTab(url: "https://markupitalia.com/contatti/");
                      Navigator.pop(context);
                    },
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  SecondaryButton(
                    title: "Cancel".tr(),
                    action: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      });
    } else {
      _shakeDetector!.startListening();
    }
  }

  void stopListening() {
    _shakeDetector?.stopListening();
  }

  void dispose() {
    _shakeDetector?.stopListening();
    _shakeDetector = null;
  }
}
