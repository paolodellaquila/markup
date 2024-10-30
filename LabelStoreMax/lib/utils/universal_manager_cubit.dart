import 'package:app_links/app_links.dart';
import 'package:flutter_app/bootstrap/helpers.dart';
import 'package:flutter_app/resources/pages/product_detail_page.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:woosignal/models/response/product.dart';

class UniversalLinkManagerCubit {
  final AppLinks appLinks = AppLinks();
  String? deeplinkProduct = '';

  static final UniversalLinkManagerCubit _singleton = UniversalLinkManagerCubit._internal();

  factory UniversalLinkManagerCubit() {
    return _singleton;
  }

  UniversalLinkManagerCubit._internal() {
    init();
  }

  //extract product permalink from deep link
  ///ex: https://markupitalia.com/shop/d-v-f-12-100-extra-fine-merinos/
  String? extractProductPermalink(String url) {
    // Create a regular expression to match the product permalink in the URL
    final regex = RegExp(r'/shop/([^/]+)');
    final match = regex.firstMatch(url);

    // Check if a match is found and return the permalink
    if (match != null && match.groupCount > 0) {
      return match.group(1)!;
    }

    // Return an empty string if no match is found
    return null;
  }

  ///INIT
  init() async {
    //check app opened from dynamic link
    final openDynLink = await appLinks.getInitialAppLink();
    if (openDynLink != null) {
      //extract product permalink from deep link
      deeplinkProduct = extractProductPermalink(openDynLink.toString()) ?? '';
    }
    appLinks.allUriLinkStream.listen(onListenDynamicLink);
  }

  /// DYNAMIC LINKS LISTENER
  Future<void> onListenDynamicLink(Uri deepLink) async {
    //extract product permalink from deep link
    deeplinkProduct = extractProductPermalink(deepLink.toString()) ?? '';
    if (deeplinkProduct != null && deeplinkProduct!.isNotEmpty) {
      NyNavigator.instance.router.navigatorKey?.currentContext?.loaderOverlay.show();
      List<Product> products = await appWooSignal((api) => api.getProducts(slug: deeplinkProduct));
      NyNavigator.instance.router.navigatorKey?.currentContext?.loaderOverlay.hide();
      if (products.isNotEmpty) {
        deeplinkProduct = null;
        routeTo(ProductDetailPage.path, data: products.first);
      }
    }
  }
}
