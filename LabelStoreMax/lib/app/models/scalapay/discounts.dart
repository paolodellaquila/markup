import 'package:flutter_app/app/models/scalapay/amount.dart';

class ScalapayDiscount {
  String displayName;
  ScalapayAmount amount;

  ScalapayDiscount({required this.displayName, required this.amount});

  factory ScalapayDiscount.fromJson(Map<String, dynamic> json) {
    return ScalapayDiscount(displayName: json['displayName'], amount: ScalapayAmount.fromJson(json['amount']));
  }

  Map<String, dynamic> toJson() {
    return {'displayName': displayName, 'amount': amount.toJson()};
  }
}
