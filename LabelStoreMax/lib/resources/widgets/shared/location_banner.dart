import 'package:flutter/material.dart';
import 'package:flutter_app/utils/language_utility.dart';
import 'package:nylo_framework/nylo_framework.dart';

class LocationBanner extends StatefulWidget {
  final bool productCategory;

  const LocationBanner({super.key, this.productCategory = false});

  @override
  _LocationBannerState createState() => _LocationBannerState();
}

class _LocationBannerState extends State<LocationBanner> {
  bool isOutsideItaly = false;

  @override
  void initState() {
    super.initState();
    _checkUserLocation();
  }

  Future<void> _checkUserLocation() async {
    bool outsideItaly = LanguageUtility.instance.isOutsideItaly;
    setState(() {
      isOutsideItaly = outsideItaly;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isOutsideItaly
        ? Container(
            width: double.maxFinite,
            color: Colors.black,
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Column(
                children: [
                  Text(
                    "Dear User, you are outside Italy.".tr(),
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    "Shopping is available only on our website.".tr(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                  if (widget.productCategory)
                    Text(
                      " EU ${"Price may vary".tr()}",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ),
          )
        : const SizedBox.shrink();
  }
}
