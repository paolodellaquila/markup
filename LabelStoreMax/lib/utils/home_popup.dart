import 'package:flutter/material.dart';
import 'package:flutter_app/resources/widgets/cached_image_widget.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PromoPopup extends StatefulWidget {
  final String uniqueId;
  final String title;
  final String message;
  final String? imageURL;

  PromoPopup({
    required this.uniqueId,
    required this.title,
    required this.message,
    this.imageURL,
  });

  @override
  _PromoPopupState createState() => _PromoPopupState();
}

class _PromoPopupState extends State<PromoPopup> with SingleTickerProviderStateMixin {
  AnimationController? _animationController;
  Animation<Offset>? _offsetAnimation;
  bool _isVisible = false;
  bool _doNotShowAgain = false;

  @override
  void initState() {
    super.initState();
    _initPopup();
  }

  Future<void> _initPopup() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool hasDismissedPopup = prefs.getBool(widget.uniqueId) ?? false;

    if (!hasDismissedPopup && widget.message.isNotEmpty && widget.title.isNotEmpty) {
      _animationController = AnimationController(
        duration: const Duration(milliseconds: 500),
        vsync: this,
      );

      _offsetAnimation = Tween<Offset>(
        begin: const Offset(0.0, 1.0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _animationController!,
        curve: Curves.easeInOut,
      ));

      await Future.delayed(Duration(seconds: 2));
      setState(() {
        _isVisible = true;
      });
      _animationController!.forward();
    }
  }

  void _dismissPopup() async {
    if (_doNotShowAgain) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool(widget.uniqueId, true);
    }

    _animationController!.reverse().then((_) {
      setState(() {
        _isVisible = false;
      });
    });
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return _isVisible
        ? SlideTransition(
            position: _offsetAnimation!,
            child: Material(
              color: Colors.transparent,
              child: Center(
                child: SingleChildScrollView(
                  child: Container(
                    width: screenWidth * 0.9, // Responsive width
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Stack(
                          children: [
                            if (widget.imageURL != null) ...[
                              Padding(
                                padding: const EdgeInsets.only(top: 16),
                                child: CachedImageWidget(
                                  image: widget.imageURL,
                                  width: screenWidth * 0.8, // Adjust image size
                                  height: screenHeight * 0.3,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ],
                            Align(
                              alignment: Alignment.centerRight,
                              child: GestureDetector(
                                onTap: _dismissPopup,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(6.0),
                                    child: Icon(
                                      Icons.close,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          widget.title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: screenWidth * 0.05, // Dynamic font size
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SingleChildScrollView(
                          child: Html(
                            data: widget.message,
                            style: {
                              'body': Style(
                                fontSize: FontSize(screenWidth * 0.04),
                                textAlign: TextAlign.center,
                              ),
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _doNotShowAgain = !_doNotShowAgain;
                              });
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Checkbox(
                                  value: _doNotShowAgain,
                                  onChanged: (value) {
                                    setState(() {
                                      _doNotShowAgain = value ?? false;
                                    });
                                  },
                                ),
                                Text(
                                  'Do not show again'.tr(),
                                  style: TextStyle(fontSize: screenWidth * 0.035),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          )
        : SizedBox.shrink();
  }
}
