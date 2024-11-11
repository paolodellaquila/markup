//  Label StoreMax
//
//  Created by Anthony Gordon.
//  2024, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:flutter/material.dart';
import 'package:flutter_app/app/models/cart.dart';
import 'package:flutter_paypal_payment/flutter_paypal_payment.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:woosignal/models/payload/order_wc.dart';
import 'package:woosignal/models/response/order.dart';
import 'package:woosignal/models/response/tax_rate.dart';
import 'package:woosignal/models/response/woosignal_app.dart';

import '/app/models/cart_line_item.dart';
import '/app/models/checkout_session.dart';
import '/bootstrap/app_helper.dart';
import '/bootstrap/data/order_wc.dart';
import '/bootstrap/helpers.dart';
import '/resources/pages/checkout_confirmation_page.dart';
import '/resources/pages/checkout_status_page.dart';

payPalPay(context, {TaxRate? taxRate, bool taxIncluded = false}) async {
  await checkout(taxRate, (total, billingDetails, cart) async {
    WooSignalApp? wooSignalApp = AppHelper.instance.appConfig;

    List<CartLineItem> cartLineItems = await cart.getCart();

    String taxTotal = '';
    if (AppHelper.instance.appConfig!.productPricesIncludeTax == 0) {
      taxTotal = await cart.taxAmount(taxRate);
    }

    String subtotal = await Cart.getInstance.getSubtotal();
    // ///Update subtotal
    // if (CheckoutSession.getInstance.coupon != null) {
    //   String discountAmount = await Cart.getInstance.couponDiscountAmount();
    //   subtotal = (double.parse(subtotal) - double.parse(discountAmount)).toStringAsFixed(2);
    // }

    String discountAmount = await Cart.getInstance.couponDiscountAmount();

    String? currencyCode = wooSignalApp?.currencyMeta?.code;

    String shippingTotal = CheckoutSession.getInstance.shippingType?.getTotal() ?? "0";
    String description = "(${cartLineItems.length}) items from ${getEnv('APP_NAME')}".tr(arguments: {"appName": getEnv('APP_NAME')});
    description += ": ${cartLineItems.map((item) => "${item.name} (${item.variationOptions})").join(", ")}";

    if (taxTotal == "") {
      taxTotal = "0";
    }

    if (shippingTotal == "" || shippingTotal == "min_amount" || CheckoutSession.getInstance.coupon?.freeShipping == true) {
      shippingTotal = "0";
    } else {
      ///FIX shipping total
      shippingTotal = shippingTotal.replaceAll(",", ".");
    }

    //TODO testing
    //OrderWC orderWC = await buildOrderWC(taxRate: taxRate, markPaid: true);
    //Order? order = await (appWooSignal((api) => api.createOrder(orderWC)));

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) => PaypalCheckoutView(
          sandboxMode: getEnv('PAYPAL_LIVE_MODE') != true,
          clientId: getEnv('PAYPAL_CLIENT_ID'),
          secretKey: getEnv('PAYPAL_SECRET_KEY'),
          note: "Contact us for any questions on your order.".tr(),
          transactions: [
            {
              "amount": {
                "total": total,
                "currency": currencyCode?.toUpperCase(),
                "details": {"subtotal": subtotal, "shipping": shippingTotal, "shipping_discount": discountAmount, "tax": taxTotal}
              },
              "description": description,
              "item_list": {
                "items": cartLineItems
                    .map((item) => {"name": item.name, "quantity": item.quantity, "price": item.total, "currency": currencyCode?.toUpperCase()})
                    .toList(),
                "shipping_address": {
                  "recipient_name": "${billingDetails?.shippingAddress?.nameFull()}",
                  "line1": billingDetails?.shippingAddress?.addressLine,
                  "line2": "",
                  "city": billingDetails?.shippingAddress?.city,
                  "country_code": billingDetails?.shippingAddress?.customerCountry?.countryCode,
                  "postal_code": billingDetails?.shippingAddress?.postalCode,
                  "phone": billingDetails?.shippingAddress?.phoneNumber,
                  "state": billingDetails?.shippingAddress?.customerCountry?.state?.name
                },
              }
            }
          ],
          onSuccess: (Map params) async {
            OrderWC orderWC = await buildOrderWC(taxRate: taxRate, markPaid: true);
            Order? order = await (appWooSignal((api) => api.createOrder(orderWC)));

            ///Temporary fix: set id of order into orderWC
            orderWC.parentId = order?.id;

            ///Temporary fix
            if (order == null && params["error"] == false && params["message"].contains("Success")) {
              routeTo(CheckoutStatusPage.path, data: orderWC);
              return;
            }

            if (params["error"] == true && !params["message"].contains("Success")) {
              showToastNotification(
                context,
                title: trans("Something went wrong"),
                description: trans("please contact us"),
              );
              updateState(CheckoutConfirmationPage.path, data: {"reloadState": false});
              context.pop();
              return;
            }

            routeTo(CheckoutStatusPage.path, data: orderWC);
          },
          onError: (error) {
            NyLogger.error(error.toString());
            showToastNotification(
              context,
              title: trans("Something went wrong"),
              description: trans("please contact us"),
            );
            updateState(CheckoutConfirmationPage.path, data: {"reloadState": false});
            context.pop();
          },
          onCancel: () {
            showToastNotification(
              context,
              title: trans("Payment Cancelled"),
              description: trans("The payment has been cancelled"),
            );
            updateState(CheckoutConfirmationPage.path, data: {"reloadState": false});
            context.pop();
          },
        ),
      ),
    );
  });
}
