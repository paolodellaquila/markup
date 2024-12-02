class ScalapayAmount {
  String amount;
  String currency;

  ScalapayAmount({required this.amount, required this.currency});

  factory ScalapayAmount.fromJson(Map<String, dynamic> json) {
    return ScalapayAmount(amount: json['amount'], currency: json['currency']);
  }

  Map<String, dynamic> toJson() {
    return {'amount': amount, 'currency': currency};
  }
}
