//  Label StoreMax
//
//  Created by Anthony Gordon.
//  2024, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:auto_size_text/auto_size_text.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/bootstrap/helpers.dart';
import 'package:flutter_app/utils/colors_manager.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:woosignal/models/response/product.dart';

class ProductDetailColorSizeWidget extends StatefulWidget {
  const ProductDetailColorSizeWidget({super.key, required this.product, required this.onSizeColorSelected});

  final Product? product;
  final void Function(String? size, String? color) onSizeColorSelected;

  @override
  State<ProductDetailColorSizeWidget> createState() => _ProductDetailColorSizeWidgetState();
}

class _ProductDetailColorSizeWidgetState extends State<ProductDetailColorSizeWidget> {
  String? selectedColor;
  String? selectedSize;

  void checkSizeColorSelected() {
    if (selectedColor != null && selectedSize != null) {
      widget.onSizeColorSelected(selectedSize, selectedColor);
    }
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      ///check monovariante for color
      if (widget.product?.attributes.firstWhereOrNull((att) => (att.name ?? "").contains("Colore")) != null &&
          widget.product!.attributes
              .firstWhereOrNull((att) => (att.name ?? "").contains("Colore"))!
              .options!
              .where((e) => !e.toLowerCase().contains("variante"))
              .isEmpty) {
        selectedColor = widget.product!.attributes.firstWhereOrNull((att) => (att.name ?? "").contains("Colore"))!.options!.first;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[],
          ),
        ),
        if (widget.product?.attributes.firstWhereOrNull((att) => (att.name ?? "").contains("Colore")) != null &&
            widget.product!.attributes
                .firstWhereOrNull((att) => (att.name ?? "").contains("Colore"))!
                .options!
                .where((e) => !e.toLowerCase().contains("variante"))
                .isNotEmpty) ...[
          Padding(
            padding: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  children: [
                    ...ColorsManager()
                        .getColorsFromProductTaxomonies(widget.product!.attributes.firstWhereOrNull((att) => (att.name ?? "").contains("Colore"))!.options!)
                        .map((color) => Padding(
                              padding: EdgeInsets.only(right: 8, top: 8),
                              child: GestureDetector(
                                onTap: () {
                                  HapticFeedback.mediumImpact();
                                  setState(() {
                                    selectedColor = color.name;
                                    checkSizeColorSelected();
                                  });
                                },
                                child: Stack(
                                  children: [
                                    Container(
                                      width: selectedColor == color.name ? 36 : 32,
                                      height: selectedColor == color.name ? 36 : 32,
                                      decoration: BoxDecoration(
                                        color: HexColor.fromHex(color.hex),
                                        border: Border.all(color: Colors.black38, width: selectedColor == color.name ? 1 : 0.5),
                                        borderRadius: BorderRadius.circular(32),
                                      ),
                                    ),
                                    if (selectedColor == color.name)
                                      Positioned.fill(
                                        top: 0,
                                        right: 0,
                                        child: Icon(
                                          Icons.check,
                                          color: color.name.contains("Nero") ? Colors.white : Colors.black,
                                          size: 16,
                                        ),
                                      )
                                  ],
                                ),
                              ),
                            ))
                  ],
                ),
              ],
            ),
          ),
        ],
        const SizedBox(
          height: 16,
        ),
        if (widget.product?.attributes.firstWhereOrNull((att) => (att.name ?? "").contains("Taglia")) != null &&
            widget.product!.attributes.firstWhereOrNull((att) => (att.name ?? "").contains("Taglia"))!.options!.isNotEmpty) ...[
          Padding(
            padding: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Select Size".tr(),
                      style: context.textTheme().bodySmall?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    GestureDetector(
                      onTap: () => openBrowserTab(url: "https://markupitalia.com/taglie/"),
                      child: Text(
                        "Guida alle taglie".tr(),
                        style: context.textTheme().bodySmall?.copyWith(fontSize: 14, decoration: TextDecoration.underline),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 8,
                ),
                Wrap(
                  children: [
                    ...widget.product!.attributes.firstWhereOrNull((att) => (att.name ?? "").contains("Taglia"))!.options!.map((taglia) {
                      return Padding(
                        padding: EdgeInsets.only(right: 8, top: 8),
                        child: GestureDetector(
                          onTap: () {
                            HapticFeedback.mediumImpact();
                            setState(() {
                              selectedSize = taglia;
                              checkSizeColorSelected();
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: selectedSize == taglia ? Colors.black38 : Colors.grey, width: selectedSize == taglia ? 2 : 0.5),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            width: selectedSize == taglia ? 36 : 32,
                            height: selectedSize == taglia ? 36 : 32,
                            child: Center(
                              child: AutoSizeText(
                                taglia,
                                style: context.textTheme().titleSmall?.copyWith(
                                      color: selectedSize == taglia ? Colors.black : Colors.grey,
                                      fontWeight: selectedSize == taglia ? FontWeight.w700 : FontWeight.w500,
                                    ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ],
            ),
          )
        ],
        const SizedBox(
          height: 16,
        ),
        if (selectedColor != null && selectedSize != null) ...[
          Padding(
            padding: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  selectedColor = null;
                  selectedSize = null;
                  widget.onSizeColorSelected(null, null);
                });
              },
              child: Text(
                "Clear Selection".tr(),
                style: context.textTheme().bodyMedium!.copyWith(
                      fontSize: 14,
                      color: Colors.red,
                    ),
              ),
            ),
          )
        ],
      ],
    );
  }
}
