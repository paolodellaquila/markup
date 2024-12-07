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

  String? extractProductPermalink(String url) {
    final regex = RegExp(r'/shop/([^/]+)');
    final match = regex.firstMatch(url);
    if (match != null && match.groupCount > 0) {
      return match.group(1)!;
    }
    return null;
  }

  /// INIT
  init() async {
    // Process initial app link only once
    final openDynLink = await appLinks.getInitialAppLink();
    if (openDynLink != null) {
      deeplinkProduct = extractProductPermalink(openDynLink.toString()) ?? '';
      //await _handleDynamicLink(openDynLink);
    }
    appLinks.allUriLinkStream.listen(onListenDynamicLink);
  }

  /// DYNAMIC LINKS LISTENER
  Future<void> onListenDynamicLink(Uri deepLink) async {
    await _handleDynamicLink(deepLink);
  }

  /// Handle Dynamic Link
  Future<void> _handleDynamicLink(Uri deepLink) async {
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
