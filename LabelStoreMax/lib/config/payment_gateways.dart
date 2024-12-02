import 'package:flutter_app/app/providers/payments/scalapay_pay.dart';
import 'package:nylo_framework/nylo_framework.dart';

import '/app/models/payment_type.dart';
import '/app/providers/payments/cash_on_delivery.dart';
import '/app/providers/payments/paypal_pay.dart';
import '/app/providers/payments/razorpay_pay.dart';
import '/app/providers/payments/stripe_pay.dart';
import '/bootstrap/helpers.dart';

/* PAYMENT GATEWAYS
|--------------------------------------------------------------------------
| Configure which payment gateways you want to use.
| Docs here: https://woosignal.com/docs/app/label-storemax
|-------------------------------------------------------------------------- */

const appPaymentGateways = ["PayPal"];
// Available: "Stripe", "CashOnDelivery", "PayPal", "RazorPay"
// e.g. appPaymentGateways = ["Stripe", "CashOnDelivery"]; will only use Stripe and Cash on Delivery.

List<PaymentType> paymentTypeList = [
  addPayment(
    id: 1,
    name: "Stripe",
    description: "${trans("Debit or Credit Card")} (Apple Pay / Google Pay)",
    assetImage: "dark_powered_by_stripe.png",
    pay: stripePay,
  ),

  addPayment(
    id: 2,
    name: "CashOnDelivery",
    description: trans("Cash on delivery"),
    assetImage: "cash_on_delivery.jpeg",
    pay: cashOnDeliveryPay,
  ),

  addPayment(
    id: 4,
    name: "PayPal",
    description: "${trans("Debit or Credit Card")} / PayPal ${trans("Account")}",
    assetImage: "paypal_logo.png",
    pay: payPalPay,
  ),

  addPayment(
    id: 5,
    name: "RazorPay",
    description: trans("Debit or Credit Card"),
    assetImage: "razorpay.png",
    pay: razorPay,
  ),

  // e.g. add more here

  addPayment(
    id: 6,
    name: "Scalapay",
    description: trans("Paga in 3 rate senza interessi"),
    assetImage: "scalapay_logo.png",
    pay: scalapayPay,
  ),
];
