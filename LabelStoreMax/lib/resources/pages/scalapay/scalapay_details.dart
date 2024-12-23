import 'package:flutter/material.dart';

class DisplayDetails extends StatelessWidget {
  final String header;
  final String content;

  const DisplayDetails({required Key key, required this.header, required this.content}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 0, 32, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(header, style: TextStyle(color: Colors.white)),
          Text(content, style: TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}
