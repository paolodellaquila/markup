import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';

class LocationBanner extends StatefulWidget {
  const LocationBanner({super.key});

  @override
  _LocationBannerState createState() => _LocationBannerState();
}

class _LocationBannerState extends State<LocationBanner> {
  @override
  Widget build(BuildContext context) {
    return Container(
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
          ],
        ),
      ),
    );
  }
}
