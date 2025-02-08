import 'package:flutter_app/app/models/scalapay/amount.dart';
import 'package:flutter_app/app/models/scalapay/billing_details.dart';
import 'package:flutter_app/app/models/scalapay/consumer_details.dart';
import 'package:flutter_app/app/models/scalapay/discounts.dart';
import 'package:flutter_app/app/models/scalapay/frequency.dart';
import 'package:flutter_app/app/models/scalapay/items.dart';
import 'package:flutter_app/app/models/scalapay/merchant.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:woosignal/models/payload/order_wc.dart';

class ScalapayOrder {
  ScalapayAmount totalAmount;
  ScalapayConsumerDetails consumer;
  ScalapayBillingShippingDetails billing;
  ScalapayBillingShippingDetails shipping;
  List<ScalapayItems> items;
  List<ScalapayDiscount> discounts;
  ScalapayMerchant merchant;
  String merchantReference;
  ScalapayAmount taxAmount;
  ScalapayAmount shippingAmount;
  String type;
  String product;
  ScalapayFrequency frequency;
  int orderExpiryMilliseconds;

  ScalapayOrder({
    required this.totalAmount,
    required this.consumer,
    required this.billing,
    required this.shipping,
    required this.items,
    required this.discounts,
    required this.merchant,
    required this.merchantReference,
    required this.taxAmount,
    required this.shippingAmount,
    this.type = "online",
    this.product = "pay-in-3",
    this.frequency = const ScalapayFrequency(),
    this.orderExpiryMilliseconds = 600000,
  });

  factory ScalapayOrder.fromJson(Map<String, dynamic> json) {
    return ScalapayOrder(
        totalAmount: ScalapayAmount.fromJson(json['totalAmount']),
        consumer: ScalapayConsumerDetails.fromJson(json['consumer']),
        billing: ScalapayBillingShippingDetails.fromJson(json['billing']),
        shipping: ScalapayBillingShippingDetails.fromJson(json['shipping']),
        items: List<ScalapayItems>.from(json['items'].map((x) => ScalapayItems.fromJson(x))),
        discounts: List<ScalapayDiscount>.from(json['discounts'].map((x) => ScalapayDiscount.fromJson(x))),
        merchant: ScalapayMerchant.fromJson(json['merchant']),
        merchantReference: json['merchantReference'],
        taxAmount: ScalapayAmount.fromJson(json['taxAmount']),
        shippingAmount: ScalapayAmount.fromJson(json['shippingAmount']));
  }

  factory ScalapayOrder.fromOrderWC(OrderWC orderWC,
      {required String total, required String currency, required String taxTotal, required String shippingTotal, required String countryCode}) {
    return ScalapayOrder(
        totalAmount: ScalapayAmount(amount: total, currency: currency),
        consumer: ScalapayConsumerDetails(
          email: orderWC.billing?.email ?? "",
          givenNames: orderWC.billing?.firstName ?? "",
          surname: orderWC.billing?.lastName ?? "",
          phoneNumber: orderWC.billing?.phone ?? "",
        ),
        billing: ScalapayBillingShippingDetails(
          name: "${orderWC.billing?.firstName ?? ""} ${orderWC.billing?.lastName ?? ""}",
          line1: orderWC.billing?.address1 ?? "",
          suburb: orderWC.billing?.city ?? "",
          postcode: orderWC.billing?.postcode ?? "",
          countryCode: countryCode,
          phoneNumber: orderWC.billing?.phone ?? "",
        ),
        shipping: ScalapayBillingShippingDetails(
          name: "${orderWC.shipping?.firstName ?? ""} ${orderWC.shipping?.lastName ?? ""}",
          line1: orderWC.shipping?.address1 ?? "",
          suburb: orderWC.shipping?.city ?? "",
          postcode: orderWC.shipping?.postcode ?? "",
          countryCode: countryCode,
          phoneNumber: orderWC.billing?.phone ?? "",
        ),
        items: orderWC.lineItems
                ?.map((item) => ScalapayItems(
                      name: item.name ?? "",
                      quantity: item.quantity ?? 1,
                      price: ScalapayAmount(amount: item.subtotal ?? "0.0", currency: currency),
                      category: "",
                      subcategory: [''],
                      brand: 'Markup',
                      gtin: (item.productId.toString()),
                    ))
                .toList() ??
            [],
        discounts: orderWC.couponLines
                ?.map((coupon) => ScalapayDiscount(
                      displayName: coupon.code ?? "",
                      amount: ScalapayAmount(amount: coupon.discount ?? "0.0", currency: currency),
                    ))
                .toList() ??
            [],
        merchant: ScalapayMerchant(
            redirectConfirmUrl: getEnv('SCALAPAY_LIVE_MODE') == true
                ? "https://portal.integration.scalapay.com/failure-url"
                : "https://portal.integration.scalapay.com/failure-url",
            redirectCancelUrl: getEnv('SCALAPAY_LIVE_MODE') == true
                ? "https://portal.integration.scalapay.com/success-url"
                : "https://portal.integration.scalapay.com/success-url"),
        merchantReference: orderWC.transactionId ?? "order-12345",
        taxAmount: ScalapayAmount(amount: taxTotal, currency: currency),
        shippingAmount: ScalapayAmount(amount: shippingTotal, currency: currency));
  }

  Map<String, dynamic> toJson() {
    return {
      'totalAmount': totalAmount.toJson(),
      'consumer': consumer.toJson(),
      'billing': billing.toJson(),
      'shipping': shipping.toJson(),
      'items': items.map((x) => x.toJson()).toList(),
      'discounts': discounts.map((x) => x.toJson()).toList(),
      'merchant': merchant.toJson(),
      'merchantReference': merchantReference,
      'taxAmount': taxAmount.toJson(),
      'shippingAmount': shippingAmount.toJson(),
      'type': type,
      'product': product,
      'frequency': frequency.toJson(),
      'orderExpiryMilliseconds': orderExpiryMilliseconds
    };
  }
}
