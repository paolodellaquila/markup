import 'package:flutter_app/app/models/scalapay/amount.dart';
import 'package:flutter_app/app/models/scalapay/billing_details.dart';
import 'package:flutter_app/app/models/scalapay/consumer_details.dart';
import 'package:flutter_app/app/models/scalapay/discounts.dart';
import 'package:flutter_app/app/models/scalapay/items.dart';
import 'package:flutter_app/app/models/scalapay/merchant.dart';

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
  int orderExpiryMilliseconds;

  ScalapayOrder(
      {required this.totalAmount,
      required this.consumer,
      required this.billing,
      required this.shipping,
      required this.items,
      required this.discounts,
      required this.merchant,
      required this.merchantReference,
      required this.taxAmount,
      required this.shippingAmount,
      required this.orderExpiryMilliseconds});

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
        shippingAmount: ScalapayAmount.fromJson(json['shippingAmount']),
        orderExpiryMilliseconds: json['orderExpiryMilliseconds']);
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
      'orderExpiryMilliseconds': orderExpiryMilliseconds
    };
  }
}
