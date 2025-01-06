class ScalapayMerchant {
  String? redirectConfirmUrl;
  String? redirectCancelUrl;

  ScalapayMerchant(
      {this.redirectConfirmUrl = "https://portal.integration.scalapay.com/failure-url",
      this.redirectCancelUrl = "https://portal.integration.scalapay.com/success-url"});

  factory ScalapayMerchant.fromJson(Map<String, dynamic> json) {
    return ScalapayMerchant(
      redirectConfirmUrl: json['redirectConfirmUrl'],
      redirectCancelUrl: json['redirectCancelUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['redirectConfirmUrl'] = this.redirectConfirmUrl;
    data['redirectCancelUrl'] = this.redirectCancelUrl;
    return data;
  }
}
