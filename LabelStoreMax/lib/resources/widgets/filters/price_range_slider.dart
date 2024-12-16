import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';

class OpenFlutterPriceRangeSlider extends StatelessWidget {
  final double max;
  final double min;
  final double selectedMin;
  final double selectedMax;
  final String label;
  final Function(RangeValues value) onChanged;

  const OpenFlutterPriceRangeSlider(
      {required this.max, required this.min, required this.label, required this.onChanged, required this.selectedMin, required this.selectedMax});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            trans("Price"),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        RangeSlider(
          values: RangeValues(selectedMin, selectedMax),
          min: min,
          max: max,
          divisions: 40,
          labels: RangeLabels(
            "\€${selectedMin.toStringAsFixed(0)}",
            "\€${selectedMax.toStringAsFixed(0)}",
          ),
          onChanged: onChanged,
          activeColor: Colors.black,
          inactiveColor: Colors.grey[300],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            "${'Price Range'.tr()}: \€${min.toStringAsFixed(0)} - \€${max.toStringAsFixed(0)}",
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
      ],
    );
  }
}
