import 'package:flutter/material.dart';

class BottomSheetContent extends StatelessWidget {
  static const BorderRadius BOTTOM_SHEET_RADIUS = BorderRadius.only(
      topLeft: Radius.circular(16), topRight: Radius.circular(16));

  final VoidCallback? onTapButton;
  final String? buttonText;
  final VoidCallback? onTapPrimaryButton;
  final VoidCallback? onTapSecondaryButton;
  final String? primaryButtonText;
  final String? secondaryButtonText;
  final String? title;
  final String? message;
  final Widget? icon;
  final bool enableDrag;

  const BottomSheetContent({
    Key? key,
    this.buttonText,
    this.onTapButton,
    this.primaryButtonText,
    this.secondaryButtonText,
    this.onTapPrimaryButton,
    this.onTapSecondaryButton,
    this.title,
    this.message,
    this.icon,
    this.enableDrag = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: enableDrag ? 12 : 24,
        bottom: 40,
        left: 24,
        right: 24,
      ),
      decoration: BoxDecoration(
        borderRadius: BOTTOM_SHEET_RADIUS,
        color: Colors.white,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (enableDrag) ...[
            Container(
              height: 5,
              width: 134,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            const SizedBox(
              height: 24,
            ),
          ],
          if (icon != null) ...[
            icon!,
            const SizedBox(
              height: 8,
            ),
          ],
          if (title != null) ...[
            Text(
              title!,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .headline3
                  ?.copyWith(color: Colors.black),
            ),
            const SizedBox(
              height: 16,
            ),
          ],
          if (message != null) ...[
            Text(
              textAlign: TextAlign.center,
              message!,
              style: TextStyle(
                color: Colors.black,
              ),
            ),
          ],
          const SizedBox(
            height: 32,
          ),
          if (primaryButtonText != null)
            MaterialButton(
              color: Colors.black,
              onPressed: onTapPrimaryButton,
              child: Text(
                primaryButtonText!,
                style: TextStyle(color: Colors.white),
              ),
            ),
          const SizedBox(
            height: 16,
          ),
          if (secondaryButtonText != null)
            MaterialButton(
              color: Colors.blueGrey,
              onPressed: onTapSecondaryButton,
              child: Text(
                secondaryButtonText!,
                style: TextStyle(color: Colors.white),
              ),
            )
        ],
      ),
    );
  }
}
