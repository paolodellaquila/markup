import 'package:flutter/material.dart';
import 'package:flutter_app/bootstrap/helpers.dart';
import 'package:flutter_app/resources/pages/account_detail_page.dart';
import 'package:flutter_app/resources/pages/account_login_page.dart';
import 'package:flutter_app/resources/widgets/app_version_widget.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:woosignal/models/response/woosignal_app.dart';
import 'package:wp_json_api/wp_json_api.dart';

class SettingsPage extends StatelessWidget {
  static String path = "/settings";

  const SettingsPage({super.key, required this.wooSignalApp});

  final WooSignalApp? wooSignalApp;

  _actionTerms() => openBrowserTab(url: wooSignalApp!.appTermsLink!);

  _actionPrivacy() => openBrowserTab(url: wooSignalApp!.appPrivacyLink!);

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // --------- LOGO
              Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(32, 72, 32, 36),
                child: Image.asset(
                  "public/assets/app_icon/logo_completed.png",
                  height: height * 0.15,
                  alignment: Alignment.center,
                ),
              ),

              Card(
                color: Colors.white,
                elevation: 8,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        onTap: () => openBrowserTab(
                            url:
                                "https://www.google.com/maps/dir/41.3079553,16.2687905/airon+srl/@41.3089697,16.2483202,13z/data=!3m1!4b1!4m9!4m8!1m1!4e1!1m5!1m1!1s0x13381c881613d90b:0xdb6329f7be1a02b9!2m2!1d16.3004981!2d41.3148718?entry=ttu"),
                        contentPadding: EdgeInsets.all(0.0),
                        leading: Icon(
                          Icons.place,
                          color: Colors.black,
                        ),
                        title: Text(
                          "Via Trani, 78 - 76121 Barletta (BT)",
                          style: TextStyle(color: Colors.black),
                        ),
                        trailing: Icon(
                          Icons.arrow_forward_ios,
                        ),
                      ),

                      // --------- TELEFONO
                      ListTile(
                        onTap: () => openBrowserTab(url: "tel:+390883532406"),
                        contentPadding: EdgeInsets.all(0.0),
                        leading: Icon(
                          Icons.phone,
                          color: Colors.black,
                        ),
                        title: Text(
                          "0883 532406",
                          style: TextStyle(color: Colors.black, decoration: TextDecoration.underline),
                        ),
                        trailing: Icon(
                          Icons.arrow_forward_ios,
                        ),
                      ),
                      const SizedBox(height: 24),
                      // --------- ACCOUNT
                      ListTile(
                        onTap: () async {
                          (await WPJsonAPI.wpUserLoggedIn()) ? AccountDetailPage(showLeadingBackButton: false) : AccountLoginPage(showBackButton: false);
                        },
                        contentPadding: const EdgeInsets.all(0.0),
                        leading: Icon(
                          Icons.account_circle,
                          color: Colors.black,
                        ),
                        title: const Text(
                          "Account",
                          style: TextStyle(color: Colors.black),
                        ),
                        trailing: Icon(
                          Icons.arrow_forward_ios,
                        ),
                      ),

                      const SizedBox(height: 24),

                      if (wooSignalApp!.appTermsLink != null && wooSignalApp!.appTermsLink!.isNotEmpty)
                        ListTile(
                          contentPadding: const EdgeInsets.all(0.0),
                          title: Text(
                            trans("Terms and conditions"),
                            style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 16),
                          ),
                          leading: Icon(Icons.menu_book_rounded),
                          trailing: Icon(Icons.arrow_forward_ios),
                          onTap: _actionTerms,
                        ),
                      if (wooSignalApp!.appPrivacyLink != null && wooSignalApp!.appPrivacyLink!.isNotEmpty)
                        ListTile(
                          contentPadding: const EdgeInsets.all(0.0),
                          title: Text(
                            trans("Privacy policy"),
                            style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 16),
                          ),
                          trailing: Icon(Icons.arrow_forward_ios),
                          leading: Icon(Icons.account_balance),
                          onTap: _actionPrivacy,
                        ),

                      ListTile(
                        contentPadding: const EdgeInsets.all(0.0),
                        title: Text("Change language".tr()),
                        leading: Icon(Icons.language),
                        trailing: Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          NyLanguageSwitcher.showBottomModal(context);
                        },
                      ),
                      ListTile(
                        contentPadding: const EdgeInsets.all(0.0),
                        title: AppVersionWidget(),
                      ),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => openBrowserTab(url: "https://www.instagram.com/markupitalia/"),
                            child: Image.asset(
                              "public/assets/icons/facebook.png",
                              height: 32,
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => openBrowserTab(url: "https://www.facebook.com/markupitalia/?locale=it_IT"),
                            child: Image.asset(
                              "public/assets/icons/instagram.png",
                              height: 32,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
