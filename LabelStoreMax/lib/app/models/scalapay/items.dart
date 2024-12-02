import 'package:flutter_app/app/models/scalapay/amount.dart';

class ScalapayItems {
  String name;
  String category;
  List<String> subcategory;
  String brand;
  String gtin;
  int quantity;
  ScalapayAmount price;

  ScalapayItems({
    required this.name,
    required this.category,
    required this.subcategory,
    required this.brand,
    required this.gtin,
    required this.quantity,
    required this.price,
  });

  factory ScalapayItems.fromJson(Map<String, dynamic> json) {
    return ScalapayItems(
      name: json['name'],
      category: json['category'],
      subcategory: List<String>.from(json['subcategory'].map((x) => x)),
      brand: json['brand'],
      gtin: json['gtin'],
      quantity: json['quantity'],
      price: ScalapayAmount.fromJson(json['price']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'category': category,
      'subcategory': subcategory,
      'brand': brand,
      'gtin': gtin,
      'quantity': quantity,
      'price': price.toJson(),
    };
  }
}
