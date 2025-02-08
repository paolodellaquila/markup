import 'package:flutter/material.dart';
import 'package:flutter_app/utils/remote_config_manager.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ChatPage extends StatelessWidget {
  static String path = "/chat-page";

  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chat with us".tr()),
      ),
      body: WebViewWidget(
        controller: WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setNavigationDelegate(
            NavigationDelegate(
              onProgress: (int progress) {},
              onPageStarted: (String url) {},
              onPageFinished: (String url) {},
              onHttpError: (HttpResponseError error) {},
              onWebResourceError: (WebResourceError error) {},
              onNavigationRequest: (NavigationRequest request) {
                return NavigationDecision.navigate;
              },
            ),
          )
          ..loadRequest(
            Uri.parse(RemoteConfigManager.instance.chatbotUrl),
          ),
      ),
    );
  }
}
