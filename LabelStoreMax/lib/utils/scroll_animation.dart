import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';

class ScrollIndicatorAnimation extends StatefulWidget {
  @override
  _ScrollIndicatorAnimationState createState() => _ScrollIndicatorAnimationState();
}

class _ScrollIndicatorAnimationState extends State<ScrollIndicatorAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0, end: 16).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Horizontal Text above the arrow
        Text(
          "Discover More".tr(),
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
        SizedBox(height: 8), // Space between text and arrow
        // Single animated arrow
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _animation.value),
              child: Icon(
                Icons.keyboard_arrow_down,
                color: Colors.white,
                size: 32,
              ),
            );
          },
        ),
      ],
    );
  }
}
