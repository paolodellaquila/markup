class ScalapayOrderResponse {
  String? token;
  DateTime? expires;
  String? checkoutUrl;

  ScalapayOrderResponse({
    this.token,
    this.expires,
    this.checkoutUrl,
  });

  factory ScalapayOrderResponse.fromJson(Map<String, dynamic> json) {
    return ScalapayOrderResponse(
      token: json['token'],
      expires: DateTime.parse(json['expires']),
      checkoutUrl: json['checkoutUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['token'] = this.token;
    data['expires'] = this.expires;
    data['checkoutUrl'] = this.checkoutUrl;
    return data;
  }
}
