//  Label StoreMax
//
//  Created by Anthony Gordon.
//  2024, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:flutter/material.dart';
import 'package:flutter_app/bootstrap/app_helper.dart';
import 'package:flutter_app/resources/widgets/store_logo_widget.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:wp_json_api/exceptions/incorrect_password_exception.dart';
import 'package:wp_json_api/exceptions/invalid_email_exception.dart';
import 'package:wp_json_api/exceptions/invalid_nonce_exception.dart';
import 'package:wp_json_api/exceptions/invalid_username_exception.dart';
import 'package:wp_json_api/models/responses/wp_user_login_response.dart';
import 'package:wp_json_api/wp_json_api.dart';

import '/app/events/login_event.dart';
import '/bootstrap/helpers.dart';
import '/resources/pages/account_register_page.dart';
import '/resources/widgets/buttons.dart';
import '/resources/widgets/woosignal_ui.dart';

class AccountLoginPage extends StatefulWidget {
  static String path = "/account-login";
  final bool showBackButton;
  AccountLoginPage({this.showBackButton = true});

  @override
  createState() => _AccountLoginPageState();
}

class _AccountLoginPageState extends NyState<AccountLoginPage> {
  final TextEditingController _tfEmailController = TextEditingController(), _tfPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.showBackButton
          ? AppBar(
              leading: IconButton(
                icon: Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(trans("Login")),
              centerTitle: true,
            )
          : null,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  StoreLogo(height: 100),
                  Card(
                    elevation: 8,
                    margin: EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 18, horizontal: 8),
                      margin: EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          TextEditingRow(heading: trans("Email"), controller: _tfEmailController, keyboardType: TextInputType.emailAddress),
                          const SizedBox(height: 16),
                          TextEditingRow(
                              heading: trans("Password"), controller: _tfPasswordController, keyboardType: TextInputType.visiblePassword, obscureText: true),
                          const SizedBox(height: 16),
                          LinkButton(
                            title: trans("Forgot Password"),
                            underline: true,
                            action: () {
                              String? forgotPasswordUrl = AppHelper.instance.appConfig!.wpLoginForgotPasswordUrl;
                              if (forgotPasswordUrl != null) {
                                openBrowserTab(url: forgotPasswordUrl);
                              } else {
                                NyLogger.info("No URL found for \"forgot password\".\nAdd your forgot password URL here https://woosignal.com/dashboard/apps");
                              }
                            },
                          ),
                          const SizedBox(height: 16),
                          PrimaryButton(
                            title: trans("Login"),
                            isLoading: isLocked('login_button'),
                            action: _loginUser,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.account_circle,
                    size: 28,
                    color: (Theme.of(context).brightness == Brightness.light) ? Colors.black38 : Colors.white70,
                  ),
                  Padding(
                    child: Text(
                      trans("Create an account"),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    padding: EdgeInsets.only(left: 8),
                  )
                ],
              ),
              onPressed: () => routeTo(AccountRegistrationPage.path),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 20),
            ),
          ],
        ),
      ),
    );
  }

  _loginUser() async {
    String email = _tfEmailController.text;
    String password = _tfPasswordController.text;

    if (email.isNotEmpty) {
      email = email.trim();
    }

    if (email == "" || password == "") {
      showToastNotification(context,
          title: trans("Invalid details"), description: trans("The email and password field cannot be empty"), style: ToastNotificationStyleType.DANGER);
      return;
    }

    if (!isEmail(email)) {
      showToastNotification(context, title: trans("Oops"), description: trans("That email address is not valid"), style: ToastNotificationStyleType.DANGER);
      return;
    }

    await lockRelease('login_button', perform: () async {
      WPUserLoginResponse? wpUserLoginResponse;
      try {
        wpUserLoginResponse = await WPJsonAPI.instance.api((request) => request.wpLogin(email: email, password: password));
      } on InvalidNonceException catch (_) {
        showToastNotification(context,
            title: trans("Invalid details"), description: trans("Something went wrong, please contact our store"), style: ToastNotificationStyleType.DANGER);
      } on InvalidEmailException catch (_) {
        showToastNotification(context,
            title: trans("Invalid details"), description: trans("That email does not match our records"), style: ToastNotificationStyleType.DANGER);
      } on InvalidUsernameException catch (_) {
        showToastNotification(context,
            title: trans("Invalid details"), description: trans("That username does not match our records"), style: ToastNotificationStyleType.DANGER);
      } on IncorrectPasswordException catch (_) {
        showToastNotification(context,
            title: trans("Invalid details"), description: trans("That password does not match our records"), style: ToastNotificationStyleType.DANGER);
      } on Exception catch (_) {
        showToastNotification(context,
            title: trans("Oops!"), description: trans("Invalid login credentials"), style: ToastNotificationStyleType.DANGER, icon: Icons.account_circle);
      }

      if (wpUserLoginResponse == null) {
        return;
      }

      if (wpUserLoginResponse.status != 200) {
        return;
      }

      event<LoginEvent>();

      showToastNotification(context,
          title: trans("Hello"), description: trans("Welcome back"), style: ToastNotificationStyleType.SUCCESS, icon: Icons.account_circle);

      navigatorPush(context, routeName: UserAuth.instance.redirect, forgetAll: true);
    });
  }
}
