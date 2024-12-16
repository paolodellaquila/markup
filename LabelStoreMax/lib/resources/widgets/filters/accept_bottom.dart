import 'package:flutter/material.dart';
import 'package:flutter_app/resources/widgets/buttons.dart';

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
            child: SecondaryButton(
              title: 'Discard',
              action: () {
                Navigator.of(context).pop();
              },
            ),
          ),
          Expanded(
            child: PrimaryButton(
              title: 'Apply',
              action: onApply!,
            ),
          )
        ],
      ),
    );
  }
}
