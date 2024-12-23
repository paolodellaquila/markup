import 'package:flutter/material.dart';
import 'package:flutter_app/resources/widgets/buttons.dart';
import 'package:nylo_framework/nylo_framework.dart';

class AcceptBottomNavigation extends StatelessWidget {
  final VoidCallback? onApply;

  const AcceptBottomNavigation({this.onApply});

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: Colors.white,
      child: Row(
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SecondaryButton(
                title: 'Cancel'.tr(),
                action: () {
                  context.pop();
                },
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: PrimaryButton(
                title: 'Apply'.tr(),
                action: onApply!,
              ),
            ),
          )
        ],
      ),
    );
  }
}
