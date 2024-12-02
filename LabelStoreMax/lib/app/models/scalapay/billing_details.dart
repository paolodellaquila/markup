class ScalapayBillingShippingDetails {
  String name;
  String line1;
  String suburb;
  String postcode;
  String countryCode;
  String phoneNumber;

  ScalapayBillingShippingDetails(
      {required this.name, required this.line1, required this.suburb, required this.postcode, required this.countryCode, required this.phoneNumber});

  factory ScalapayBillingShippingDetails.fromJson(Map<String, dynamic> json) {
    return ScalapayBillingShippingDetails(
        name: json['name'],
        line1: json['line1'],
        suburb: json['suburb'],
        postcode: json['postcode'],
        countryCode: json['countryCode'],
        phoneNumber: json['phoneNumber']);
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'line1': line1, 'suburb': suburb, 'postcode': postcode, 'countryCode': countryCode, 'phoneNumber': phoneNumber};
  }
}
