import 'package:flutter/material.dart';
import 'package:flutter_app/resources/widgets/cached_image_widget.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:nylo_framework/nylo_framework.dart';

class PromoPopup extends StatefulWidget {
  final String title;
  final String message;
  final String? imageURL;

  PromoPopup({
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

  @override
  void initState() {
    super.initState();
    _initPopup();
  }

  Future<void> _initPopup() async {
    if (widget.message.isEmpty || widget.title.isEmpty) {
      return;
    }

    //SharedPreferences prefs = await SharedPreferences.getInstance();
    //bool hasDismissedPopup = prefs.getBool('hasDismissedPopup') ?? false;
    bool hasDismissedPopup = false;

    if (!hasDismissedPopup) {
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

      // Delay to show the popup
      await Future.delayed(Duration(seconds: 2));
      setState(() {
        _isVisible = true;
      });
      _animationController!.forward();
    }
  }

  void _dismissPopup() async {
    ///TODO capire come non renderlo invasivo, ma se controlliamo le shared potrebbe non vedersi più sempre
    /*SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasDismissedPopup', true);*/
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
    return _isVisible
        ? SlideTransition(
            position: _offsetAnimation!,
            child: Material(
              color: Colors.transparent,
              child: Center(
                child: Container(
                  width: 300,
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.close,
                              size: 18,
                            ),
                            onPressed: _dismissPopup,
                          ),
                        ],
                      ),
                      if (widget.imageURL != null) ...[
                        CachedImageWidget(
                          image: widget.imageURL,
                          width: 300,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      ],
                      SizedBox(height: 16),
                      Text(
                        widget.title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      SingleChildScrollView(
                        child: Html(
                          data: widget.message,
                          style: {
                            'body': Style(
                              fontSize: FontSize(16),
                              textAlign: TextAlign.center,
                            ),
                          },
                        ),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _dismissPopup,
                        child: Text('Dismiss'.tr()),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
        : SizedBox.shrink();
  }
}
