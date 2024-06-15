import 'package:flutter/material.dart';

import 'bottomsheet_content.dart';

Future<void> showRoundedBottomSheet({
  required BuildContext context,
  String? title,
  String? message,
  String? buttonText,
  VoidCallback? onTapButton,
  final VoidCallback? onTapPrimaryButton,
  final VoidCallback? onTapSecondaryButton,
  final String? primaryButtonText,
  final String? secondaryButtonText,
  Widget? icon,
  bool enableDrag = false,
  bool isDismissible = true,
}) {
  return showModalBottomSheet(
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BottomSheetContent.BOTTOM_SHEET_RADIUS,
    ),
    context: context,
    enableDrag: enableDrag,
    isDismissible: isDismissible,
    builder: (context) => BottomSheetContent(
      onTapButton: onTapButton,
      buttonText: buttonText,
      onTapPrimaryButton: onTapPrimaryButton,
      onTapSecondaryButton: onTapSecondaryButton,
      primaryButtonText: primaryButtonText,
      secondaryButtonText: secondaryButtonText,
      title: title,
      message: message,
      icon: icon,
      enableDrag: enableDrag,
    ),
  );
}

Future<void> delay([int milliseconds = 2000]) {
  return Future.delayed(Duration(milliseconds: milliseconds));
}