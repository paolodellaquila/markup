import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/bootstrap/helpers.dart';
import 'package:flutter_app/config/firebase-messaging/firebase_notification_handler.dart';
import 'package:flutter_app/resources/pages/account_detail_page.dart';
import 'package:flutter_app/resources/pages/account_login_page.dart';
import 'package:flutter_app/resources/widgets/app_version_widget.dart';
import 'package:notification_permissions/notification_permissions.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:woosignal/models/response/woosignal_app.dart';
import 'package:wp_json_api/wp_json_api.dart';

class SettingsPage extends StatefulWidget {
  static String path = "/settings";

  const SettingsPage({super.key, required this.wooSignalApp});

  final WooSignalApp? wooSignalApp;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  var notificationValue = false;

  _actionTerms() => openBrowserTab(url: widget.wooSignalApp!.appTermsLink!);
  _actionPrivacy() => openBrowserTab(url: widget.wooSignalApp!.appPrivacyLink!);

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 8),
                // --------- LOGO
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(32),
                  child: Image.asset(
                    "public/assets/app_icon/logo_completed.png",
                    height: 72,
                    alignment: Alignment.center,
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
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
                      if (widget.wooSignalApp!.appTermsLink != null && widget.wooSignalApp!.appTermsLink!.isNotEmpty)
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
                      if (widget.wooSignalApp!.appPrivacyLink != null && widget.wooSignalApp!.appPrivacyLink!.isNotEmpty)
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
                      Container(
                        width: width,
                        height: 50,
                        child: FutureBuilder(
                          future: NotificationPermissions.getNotificationPermissionStatus(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator());
                            } else if (snapshot.hasError) {
                              return SizedBox.shrink();
                            } else if (snapshot.hasData) {
                              notificationValue = snapshot.data == PermissionStatus.granted;
                              return ListTile(
                                contentPadding: const EdgeInsets.all(0.0),
                                title: Text("Notifiche Push".tr()),
                                leading: Icon(Icons.notification_add),
                                trailing: Switch(
                                    value: notificationValue,
                                    onChanged: (value) {
                                      if (value) {
                                        FirebaseNotifications().askPermission();
                                        NotificationPermissions.requestNotificationPermissions();
                                      } else {
                                        try {
                                          if (Platform.isAndroid) {
                                            AppSettings.openAppSettings(type: AppSettingsType.notification);
                                          } else {
                                            AppSettings.openAppSettings();
                                          }
                                        } catch (e) {
                                          print(e);
                                        }
                                      }
                                      setState(() => notificationValue = value);
                                    }),
                                onTap: () {
                                  NyLanguageSwitcher.showBottomModal(context);
                                },
                              );
                            }
                            return SizedBox.shrink();
                          },
                        ),
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
                        leading: Icon(Icons.contact_support_rounded),
                        trailing: Icon(Icons.arrow_forward_ios),
                        onTap: () => openBrowserTab(url: "https://markupitalia.com/contatti/"),
                      ),
                      const SizedBox(height: 24),
                      ListTile(
                        contentPadding: const EdgeInsets.all(0.0),
                        title: AppVersionWidget(),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
