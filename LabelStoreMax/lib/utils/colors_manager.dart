import 'dart:async';
import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_app/app/models/product_color.dart';

class ColorsManager {
  static final ColorsManager _singleton = ColorsManager._internal();

  factory ColorsManager() {
    return _singleton;
  }

  ColorsManager._internal();

  final List<ProductColor> colors = [];

  Future<void> syncColors() async {
    final ref = FirebaseDatabase.instance.ref('product');
    final snapshot = await ref.get();
    final colors = snapshot.child("color").value as Map<dynamic, dynamic>;
    for (var data in colors.entries.toList()) {
      final color = ProductColor(
        name: data.key,
        hex: data.value,
      );
      this.colors.add(color);
    }
  }

  List<ProductColor> getColorsFromProductTaxomonies(List<String> colors) {
    List<ProductColor> colorList = [];
    for (var color in colors) {
      final colorData = this.colors.firstWhereOrNull((element) => element.name.toLowerCase() == color.toLowerCase());
      if (colorData != null)
        colorList.add(colorData);
      else
        colorList.add(ProductColor(name: color, hex: "#D3D3D3"));
    }
    return colorList;
  }
}

extension HexColor on Color {
  /// String is in the format "aabbcc" or "ffaabbcc" with an optional leading "#".
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  /// Prefixes a hash sign if [leadingHashSign] is set to `true` (default is `true`).
  String toHex({bool leadingHashSign = true}) => '${leadingHashSign ? '#' : ''}'
      '${alpha.toRadixString(16).padLeft(2, '0')}'
      '${red.toRadixString(16).padLeft(2, '0')}'
      '${green.toRadixString(16).padLeft(2, '0')}'
      '${blue.toRadixString(16).padLeft(2, '0')}';
}
