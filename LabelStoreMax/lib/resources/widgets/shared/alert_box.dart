import 'package:flutter/material.dart';

class AlertBox extends StatelessWidget {
  final String message;
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
  final Color textColor;

  const AlertBox({
    Key? key,
    required this.message,
    this.icon = Icons.info_outline,
    this.backgroundColor = Colors.white,
    this.iconColor = Colors.redAccent,
    this.textColor = Colors.black,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: iconColor,
            size: 30,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: textColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
