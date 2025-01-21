class ScalapayFrequency {
  final String? number;
  final String? frequencyType;

  const ScalapayFrequency({this.number = "1", this.frequencyType = "monthly"});

  factory ScalapayFrequency.fromJson(Map<String, dynamic> json) {
    return ScalapayFrequency(number: json['number'], frequencyType: json['frequencyType']);
  }

  Map<String, dynamic> toJson() {
    return {'number': number, 'frequencyType': frequencyType};
  }
}
