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
        showModalBottomSheet<void>(
          isScrollControlled: true,
          context: context,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30.0),
              topRight: Radius.circular(30.0),
            ),
          ),
          builder: (BuildContext context) {
            return SafeArea(
              minimum: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Padding(
                padding: MediaQuery.of(context).viewInsets,
                child: FractionallySizedBox(
                  heightFactor: 0.35,
                  child: Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
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
                        Padding(padding: EdgeInsets.only(top: 24)),
                        PrimaryButton(
                          title: "Continue".tr(),
                          action: () {
                            openBrowserTab(url: "https://markupitalia.com/contatti/");
                            Navigator.pop(context);
                          },
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
              ),
            );
          },
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
