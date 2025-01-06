//  Label StoreMax
//
//  Created by Anthony Gordon.
//  2024, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:flutter/material.dart';
import 'package:flutter_app/app/models/checkout_session.dart';
import 'package:flutter_app/app/models/scalapay/order.dart';
import 'package:flutter_app/app/models/scalapay/order_response.dart';
import 'package:flutter_app/app/networking/scalapay/scalapay_api.dart';
import 'package:flutter_app/bootstrap/app_helper.dart';
import 'package:flutter_app/resources/pages/checkout_status_page.dart';
import 'package:flutter_app/resources/pages/scalapay/scalapay_checkout.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:woosignal/models/payload/order_wc.dart';
import 'package:woosignal/models/response/order.dart';
import 'package:woosignal/models/response/tax_rate.dart';
import 'package:woosignal/models/response/woosignal_app.dart';

import '/bootstrap/data/order_wc.dart';
import '/bootstrap/helpers.dart';
import '/resources/pages/checkout_confirmation_page.dart';

scalapayPay(context, {TaxRate? taxRate, bool taxIncluded = false}) async {
  final scalapayApi = ScalapayApi()..init();

  await checkout(taxRate, (total, billingDetails, cart) async {
    try {
      WooSignalApp? wooSignalApp = AppHelper.instance.appConfig;

      String taxTotal = '';
      if (AppHelper.instance.appConfig!.productPricesIncludeTax == 0) {
        taxTotal = await cart.taxAmount(taxRate);
      }

      String? currencyCode = wooSignalApp?.currencyMeta?.code;

      String shippingTotal = CheckoutSession.getInstance.shippingType?.getTotal() ?? "0";

      if (taxTotal == "") {
        taxTotal = "0";
      }

      if (shippingTotal == "" || shippingTotal == "min_amount" || CheckoutSession.getInstance.coupon?.freeShipping == true) {
        shippingTotal = "0";
      } else {
        ///FIX shipping total
        shippingTotal = shippingTotal.replaceAll(",", ".");
      }

      OrderWC orderWC = await buildOrderWC(taxRate: taxRate, markPaid: true);
      ScalapayOrder scalapayOrder = ScalapayOrder.fromOrderWC(orderWC,
          total: total,
          currency: currencyCode!,
          taxTotal: taxTotal,
          shippingTotal: shippingTotal,
          countryCode: billingDetails?.billingAddress?.customerCountry?.countryCode ?? "IT");

      ScalapayOrderResponse orderResponse = await scalapayApi.createOrder(scalapayOrder);

      if (orderResponse.checkoutUrl == null || orderResponse.token == null) {
        showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: Text("Error".tr()),
            content: Text("Something went wrong during order creation process".tr()),
            actions: [
              TextButton(
                onPressed: () {
                  updateState(CheckoutConfirmationPage.path, data: {"reloadState": false});
                  context.pop();
                },
                child: Text("Retry".tr()),
              ),
              TextButton(
                onPressed: () {
                  updateState(CheckoutConfirmationPage.path, data: {"reloadState": false});
                  context.pop();
                  openBrowserTab(url: "https://markupitalia.com/contatti/");
                },
                child: Text("Assistance".tr()),
              ),
            ],
          ),
        );
        return;
      }

      // Redirect user to Scalapay payment page
      bool success = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ScalapayCheckout(scalapayOrder: scalapayOrder, orderResponse: orderResponse),
        ),
      );

      if (success) {
        await scalapayApi.delayOrder(orderResponse.token!);
        await scalapayApi.capturePayment(orderResponse.token!);
        // Delay the payment
        await scalapayApi.delayOrder(orderResponse.token!);

        // Wait for the order to be confirmed and capture the payment
        // (This step should be triggered after successful shipment confirmation)
        await scalapayApi.capturePayment(orderResponse.token!);

        Order? order = await (appWooSignal((api) => api.createOrder(orderWC)));

        if (order == null) {
          showDialog(
            context: context,
            builder: (BuildContext context) => AlertDialog(
              title: Text("Error".tr()),
              content: Text("Something went wrong during order creation process".tr()),
              actions: [
                TextButton(
                  onPressed: () {
                    updateState(CheckoutConfirmationPage.path, data: {"reloadState": false});
                    context.pop();
                  },
                  child: Text("Retry".tr()),
                ),
                TextButton(
                  onPressed: () {
                    updateState(CheckoutConfirmationPage.path, data: {"reloadState": false});
                    context.pop();
                    openBrowserTab(url: "https://markupitalia.com/contatti/");
                  },
                  child: Text("Assistance".tr()),
                ),
              ],
            ),
          );
        }

        routeTo(CheckoutStatusPage.path, data: order);
      } else {
        NyLogger.error("Scalapay Payment failed");
        showToastNotification(
          style: ToastNotificationStyleType.DANGER,
          context,
          title: trans("Something went wrong"),
          description: trans("please contact us"),
        );
        updateState(CheckoutConfirmationPage.path, data: {"reloadState": false});
        Navigator.pop(context);
        return;
      }
    } catch (e) {
      NyLogger.error(e.toString());
      showToastNotification(
        style: ToastNotificationStyleType.DANGER,
        context,
        title: trans("Something went wrong"),
        description: trans("please contact us"),
      );
      updateState(CheckoutConfirmationPage.path, data: {"reloadState": false});
      Navigator.pop(context);
      return;
    }
  });
}
