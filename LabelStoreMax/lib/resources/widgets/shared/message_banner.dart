import 'dart:async';

import 'package:flutter/material.dart';

class MessageBannerWidget extends StatefulWidget {
  final List<dynamic> messages;

  const MessageBannerWidget({super.key, required this.messages});

  @override
  _MessageBannerState createState() => _MessageBannerState();
}

class _MessageBannerState extends State<MessageBannerWidget> {
  int _currentIndex = 0;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(seconds: 3), (timer) {
      setState(() {
        _currentIndex = (_currentIndex + 1) % widget.messages.length;
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

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
              widget.messages[_currentIndex].title,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            if (widget.messages[_currentIndex].subtitle != null)
              Text(
                widget.messages[_currentIndex].subtitle!,
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
