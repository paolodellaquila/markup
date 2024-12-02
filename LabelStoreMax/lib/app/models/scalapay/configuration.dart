import 'package:flutter_app/app/models/scalapay/amount.dart';

class ScalapayConfiguration {
  String? type;
  String? description;
  ScalapayAmount? minimumAmount;
  ScalapayAmount? maximumAmount;
  String? numberOfPayments;
  String? promotionUrl;
  List<String> locales = [];

  ScalapayConfiguration(
      {this.type, this.description, this.minimumAmount, this.maximumAmount, this.numberOfPayments, this.promotionUrl, this.locales = const []});

  ScalapayConfiguration.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    description = json['description'];
    minimumAmount = json['minimumAmount'] != null ? new ScalapayAmount.fromJson(json['minimumAmount']) : null;
    maximumAmount = json['maximumAmount'] != null ? new ScalapayAmount.fromJson(json['maximumAmount']) : null;
    numberOfPayments = json['numberOfPayments'];
    promotionUrl = json['promotionUrl'];
    locales = json['locales'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = this.type;
    data['description'] = this.description;
    final minimumAmount = this.minimumAmount;
    if (minimumAmount != null) {
      data['minimumAmount'] = minimumAmount.toJson();
    }
    final maximumAmount = this.maximumAmount;
    if (maximumAmount != null) {
      data['maximumAmount'] = maximumAmount.toJson();
    }
    data['numberOfPayments'] = this.numberOfPayments;
    data['promotionUrl'] = this.promotionUrl;
    data['locales'] = this.locales;
    return data;
  }
}
