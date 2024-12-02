class ScalapayConsumerDetails {
  final String phoneNumber;
  final String givenNames;
  final String surname;
  final String email;

  ScalapayConsumerDetails({
    required this.phoneNumber,
    required this.givenNames,
    required this.surname,
    required this.email,
  });

  static ScalapayConsumerDetails fromJson(Map<String, dynamic> json) {
    return ScalapayConsumerDetails(
      phoneNumber: json['phoneNumber'],
      givenNames: json['givenNames'],
      surname: json['surname'],
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'phoneNumber': phoneNumber,
      'givenNames': givenNames,
      'surname': surname,
      'email': email,
    };
  }
}
