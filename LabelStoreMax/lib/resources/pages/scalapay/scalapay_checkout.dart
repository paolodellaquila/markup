import 'package:flutter/material.dart';
import 'package:flutter_app/app/models/scalapay/order.dart';
import 'package:flutter_app/app/models/scalapay/order_response.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ScalapayCheckout extends StatefulWidget {
  final ScalapayOrder scalapayOrder;
  final ScalapayOrderResponse orderResponse;

  const ScalapayCheckout({super.key, required this.scalapayOrder, required this.orderResponse});

  @override
  State<ScalapayCheckout> createState() => _ScalapayCheckoutState();
}

class _ScalapayCheckoutState extends State<ScalapayCheckout> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Scalapay Checkout")),
        body: WebViewWidget(
          controller: WebViewController()
            ..setJavaScriptMode(JavaScriptMode.unrestricted)
            ..setNavigationDelegate(
              NavigationDelegate(
                onProgress: (int progress) {},
                onPageStarted: (String url) {
                  if ((url.contains(widget.scalapayOrder.merchant.redirectConfirmUrl!)) || (url.contains("returnTo=%2Fhome"))) {
                    Navigator.pop(context, true);
                  } else if (url.contains(widget.scalapayOrder.merchant.redirectCancelUrl!)) {
                    Navigator.pop(context, false);
                  }
                },
                onPageFinished: (_) {},
                onHttpError: (HttpResponseError error) {},
                onWebResourceError: (WebResourceError error) {},
                onNavigationRequest: (NavigationRequest request) {
                  return NavigationDecision.navigate;
                },
              ),
            )
            ..loadRequest(Uri.parse(widget.orderResponse.checkoutUrl!)),
        ));
  }
}
