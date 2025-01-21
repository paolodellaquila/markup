import 'package:flutter/material.dart';

class FilterSelectableItem extends StatelessWidget {
  final bool isSelected;
  final String text;

  const FilterSelectableItem({this.isSelected = false, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              border: Border.all(color: isSelected ? Colors.black : Colors.grey),
              color: isSelected ? Colors.black : Colors.white),
          padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: isSelected ? Colors.white : Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ));
  }
}
