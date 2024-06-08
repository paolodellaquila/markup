import 'package:flutter/material.dart';
import 'package:flutter_app/bootstrap/app_helper.dart';
import 'package:flutter_app/resources/widgets/cached_image_widget.dart';

class StoreLogo extends StatelessWidget {
  const StoreLogo(
      {super.key,
      this.height = 156,
      this.width = 156,
      this.placeholder = const CircularProgressIndicator(),
      this.fit = BoxFit.contain,
      this.showBgWhite = true});

  final bool showBgWhite;
  final double height;
  final double width;
  final Widget placeholder;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(color: showBgWhite ? Colors.white : Colors.transparent, borderRadius: BorderRadius.circular(5)),
        child: CachedImageWidget(
          width: width,
          fit: fit,
          image: AppHelper.instance.appConfig!.appLogo,
          height: height,
          placeholder: Container(height: height, width: width),
        ),
      );
}
