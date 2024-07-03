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

              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Gestisci account".tr(),
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    // --------- ACCOUNT
                    ListTile(
                      onTap: () async {
                        (await WPJsonAPI.wpUserLoggedIn()) ? routeTo(AccountDetailPage.path) : routeTo(AccountLoginPage.path);
                      },
                      contentPadding: const EdgeInsets.all(0.0),
                      leading: Icon(
                        Icons.account_circle,
                        color: Colors.black,
                      ),
                      title: Text(
                        trans("Account"),
                        style: TextStyle(color: Colors.black),
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios,
                      ),
                    ),
                    const Divider(
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      "Policy".tr(),
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
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

                    const Divider(
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 24),

                    Text(
                      "Altre Impostazioni".tr(),
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                      title: Text("Contacts".tr()),
                      leading: Icon(Icons.language),
                      trailing: Icon(Icons.arrow_forward_ios),
                      onTap: () => openBrowserTab(url: "https://markupitalia.com/contatti/"),
                    ),
                    const SizedBox(height: 24),
                    ListTile(
                      contentPadding: const EdgeInsets.all(0.0),
                      title: AppVersionWidget(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
