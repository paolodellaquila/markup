import 'package:flutter/cupertino.dart';
import 'package:nylo_framework/nylo_framework.dart';

class CountryUtility {
  // Private constructor for the singleton pattern
  CountryUtility._privateConstructor();

  // The single instance of the class
  static final CountryUtility instance = CountryUtility._privateConstructor();
  static Map<String, dynamic> languageData = {};

  init(BuildContext context, {setLanguage = false}) async {
    Response response = await Dio().get('http://ip-api.com/json');
    languageData = response.data;

    if (setLanguage) {
      final countryCode = CountryUtility.instance.getUserCountryCode();

      if (countryCode != null) {
        await NyLocalization.instance.setLanguage(context, language: isOutsideItaly ? "en" : "it");
      }
    }
  }

  // Method to fetch the user's country code
  String? getUserCountryCode() {
    try {
      return languageData['countryCode'] as String?;
    } catch (error) {
      print("Error fetching location: $error");
      return null;
    }
  }

  // Method to check if the user is outside Italy
  bool get isOutsideItaly {
    String? countryCode = getUserCountryCode();
    if (countryCode == null) return false;
    return countryCode != 'IT';
  }
}
