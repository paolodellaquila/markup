//  Label StoreMax
//
//  Created by Anthony Gordon.
//  2024, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:woosignal/models/payload/order_wc.dart';
import 'package:woosignal/models/response/order.dart';
import 'package:woosignal/models/response/tax_rate.dart';
import 'package:woosignal/models/response/woosignal_app.dart';

import '/bootstrap/app_helper.dart';
import '/bootstrap/data/order_wc.dart';
import '/bootstrap/helpers.dart';
import '/resources/pages/checkout_confirmation_page.dart';
import '/resources/pages/checkout_status_page.dart';

stripePay(context, {TaxRate? taxRate}) async {
  WooSignalApp? wooSignalApp = AppHelper.instance.appConfig;

  bool liveMode = getEnv('STRIPE_LIVE_MODE') == null ? !wooSignalApp!.stripeLiveMode! : getEnv('STRIPE_LIVE_MODE', defaultValue: false);

  // CONFIGURE STRIPE
  Stripe.stripeAccountId = getEnv('STRIPE_ACCOUNT') ?? wooSignalApp!.stripeAccount;

  Stripe.publishableKey = liveMode
      ? "pk_live_51QRXzgIzl4XsOW4zTU4q24HdcoYKYzo685hUtc9Al6EsKHBeyZfRI6Y0lM1ectV2k9GZUIwGGCG1JJzEMetfvo2E00qp2uf8Jz"
      : "pk_test_51QRXzgIzl4XsOW4zCv3VuX1nFoKY2IQT3jsWBCwJUh11FoIJqRKKboYmUxqLNcZwWiCrePwHQFh4dDyB20L14FJ900GRGhRszF"; // Don't change this value
  await Stripe.instance.applySettings();

  if (Stripe.stripeAccountId == '') {
    NyLogger.error('You need to connect your Stripe account to WooSignal via the dashboard https://woosignal.com/dashboard');
    return;
  }

  try {
    Map<String, dynamic>? rsp = {};
    //   // CHECKOUT HELPER
    await checkout(taxRate, (total, billingDetails, cart) async {
      String cartShortDesc = await cart.cartShortDesc();

      rsp = await appWooSignal((api) => api.stripePaymentIntentV2(
            amount: total,
            email: billingDetails?.billingAddress?.emailAddress,
            desc: cartShortDesc,
            shipping: billingDetails?.getShippingAddressStripe(),
            customerDetails: billingDetails?.createStripeDetails(),
          ));
    });

    if (rsp == null) {
      showToastNotification(context,
          title: trans("Oops!"), description: trans("Something went wrong, please try again."), icon: Icons.payment, style: ToastNotificationStyleType.WARNING);
      updateState(CheckoutConfirmationPage.path, data: {"reloadState": false});
      return;
    }

    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
          style: Theme.of(context).brightness == Brightness.light ? ThemeMode.light : ThemeMode.dark,
          merchantDisplayName: getEnv('APP_NAME', defaultValue: wooSignalApp?.appName),
          customerId: rsp!['customer'],
          paymentIntentClientSecret: rsp!['client_secret'],
          customerEphemeralKeySecret: rsp!['ephemeral_key'],
          setupIntentClientSecret: rsp!['setup_intent_secret']),
    );

    await Stripe.instance.presentPaymentSheet();

    PaymentIntent paymentIntent = await Stripe.instance.retrievePaymentIntent(rsp!['client_secret']);

    if (paymentIntent.status == PaymentIntentsStatus.Unknown) {
      showToastNotification(
        context,
        title: trans("Oops!"),
        description: trans("Something went wrong, please try again."),
        icon: Icons.payment,
        style: ToastNotificationStyleType.WARNING,
      );
    }

    if (paymentIntent.status != PaymentIntentsStatus.Succeeded) {
      return;
    }

    updateState(CheckoutConfirmationPage.path, data: {"reloadState": true});

    OrderWC orderWC = await buildOrderWC(taxRate: taxRate);
    Order? order = await (appWooSignal((api) => api.createOrder(orderWC)));

    if (order == null) {
      showToastNotification(
        context,
        title: trans("Error"),
        description: trans("Something went wrong, please contact our store"),
      );
      updateState(CheckoutConfirmationPage.path, data: {"reloadState": false});
      return;
    }

    routeTo(CheckoutStatusPage.path, navigationType: NavigationType.pushAndForgetAll, data: order);
  } on StripeException catch (e) {
    if (getEnv('APP_DEBUG', defaultValue: true)) {
      NyLogger.error(e.error.message!);
    }
    showToastNotification(
      context,
      title: trans("Oops!"),
      description: e.error.localizedMessage!,
      icon: Icons.payment,
      style: ToastNotificationStyleType.WARNING,
    );
    updateState(CheckoutConfirmationPage.path, data: {"reloadState": false});
  } catch (ex) {
    if (getEnv('APP_DEBUG', defaultValue: true)) {
      NyLogger.error(ex.toString());
    }
    showToastNotification(
      context,
      title: trans("Oops!"),
      description: trans("Something went wrong, please try again."),
      icon: Icons.payment,
      style: ToastNotificationStyleType.WARNING,
    );
    updateState(CheckoutConfirmationPage.path, data: {"reloadState": false});
  }
}
