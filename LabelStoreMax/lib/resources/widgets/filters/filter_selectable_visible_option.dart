import 'package:flutter/material.dart';

class FilterSelectableVisibleOption<T> extends StatelessWidget {
  final Map<T, Widget> children;
  final ValueChanged<T> onSelected;
  final String title;

  const FilterSelectableVisibleOption({required this.onSelected, required this.children, required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16).copyWith(top: 24),
          child: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        SizedBox(
          height: 16,
        ),
        Container(
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          color: Colors.white,
          child: Wrap(
            spacing: 8,
            alignment: WrapAlignment.start,
            children: children
                .map((key, widget) => MapEntry(
                    key,
                    InkWell(
                      child: widget,
                      onTap: () {
                        onSelected(key);
                      },
                    )))
                .values
                .toList(growable: false),
          ),
        )
      ],
    );
  }
}
