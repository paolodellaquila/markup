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
import 'package:woosignal/models/response/product_variation.dart';

class ProductDetailColorSizeWidget extends StatefulWidget {
  const ProductDetailColorSizeWidget({super.key, required this.product, required this.onSizeColorSelected, required this.productVariations});

  final Product? product;
  final List<ProductVariation> productVariations;
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
      /*if (widget.product?.attributes.firstWhereOrNull((att) => (att.name ?? "").contains("Colore")) != null &&
          widget.product!.attributes
              .firstWhereOrNull((att) => (att.name ?? "").contains("Colore"))!
              .options!
              .where((e) => !e.toLowerCase().contains("variante") && !e.toLowerCase().contains("VARI. 1"))
              .isEmpty) {
        selectedColor = widget.product!.attributes.firstWhereOrNull((att) => (att.name ?? "").contains("Colore"))!.options!.first;
      }*/

      ///Maybe the above code is not needed, so we can remove it and use the below code
      ///Check if color is 1, stop
      // if (widget.product?.attributes.firstWhereOrNull((att) => (att.name ?? "").contains("Colore")) != null &&
      //     widget.product!.attributes.firstWhereOrNull((att) => (att.name ?? "").contains("Colore"))!.options!.length == 1) {
      //   setState(() {
      //     selectedColor = widget.product!.attributes.firstWhereOrNull((att) => (att.name ?? "").contains("Colore"))!.options!.first;
      //     checkSizeColorSelected();
      //   });
      // }
      ///Default select the first color. It avoid the bug and make the user select the color
      setState(() {
        selectedColor = widget.product!.attributes.firstWhereOrNull((att) => (att.name ?? "").contains("Colore"))!.options!.first;
        checkSizeColorSelected();
      });
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
            widget.product!.attributes.firstWhereOrNull((att) => (att.name ?? "").contains("Colore"))!.options!.length != 1) ...[
          Padding(
            padding: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Color".tr() + ":" + " ${selectedColor ?? ''} ",
                      style: context.textTheme().bodySmall?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  children: [
                    ...ColorsManager()
                        .getColorsFromProductTaxomonies(widget.product!.attributes.firstWhereOrNull((att) => (att.name ?? "").contains("Colore"))!.options!)
                        .map((color) => Padding(
                              padding: EdgeInsets.only(right: 8, top: 8),
                              child: GestureDetector(
                                onTap: () {
                                  if (widget.productVariations
                                      .where((variations) => variations.sku!.toLowerCase().contains("-${color.name.toLowerCase()}"))
                                      .isNotEmpty) {
                                    HapticFeedback.mediumImpact();
                                    setState(() {
                                      selectedColor = color.name;
                                      checkSizeColorSelected();
                                    });
                                  }
                                },
                                child: Stack(
                                  children: [
                                    Container(
                                      width: selectedColor == color.name ? 36 : 32,
                                      height: selectedColor == color.name ? 36 : 32,
                                      decoration: BoxDecoration(
                                        color: HexColor.fromHex(color.hex),
                                        border: Border.all(color: Colors.black38, width: selectedColor == color.name ? 1 : 0.5),
                                        borderRadius: BorderRadius.circular(8),
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
                                      ),
                                    if (widget.productVariations
                                        .where((variations) => variations.sku!.toLowerCase().contains("-${color.name.toLowerCase()}"))
                                        .isEmpty) ...[
                                      Positioned.fill(
                                        top: 0,
                                        right: 0,
                                        child: Text("/",
                                            textAlign: TextAlign.center,
                                            style: context.textTheme().bodySmall?.copyWith(
                                                  fontSize: 24,
                                                  color: color.name.toLowerCase().contains("nero") ? Colors.white : Colors.black,
                                                )),
                                      ),
                                    ]
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
                      "Select Size".tr() + ":" + " ${selectedSize ?? ''} ",
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
                            if (selectedColor == null) {
                              HapticFeedback.mediumImpact();
                              showToastNotification(context,
                                  title: "Attention".tr(), description: "Please select a color first".tr(), style: ToastNotificationStyleType.WARNING);
                              return;
                            }

                            if (widget.productVariations
                                .where((variations) => variations.sku!.toLowerCase().contains("${selectedColor?.toLowerCase()}-${taglia.toLowerCase()}"))
                                .isNotEmpty) {
                              HapticFeedback.mediumImpact();
                              setState(() {
                                selectedSize = taglia;
                                checkSizeColorSelected();
                              });
                            }
                          },
                          child: Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: selectedSize == taglia ? Colors.black38 : Colors.grey, width: selectedSize == taglia ? 2 : 0.5),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                width: selectedSize == taglia ? 42 : 38,
                                height: selectedSize == taglia ? 42 : 38,
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
                              if (widget.productVariations
                                      .where((variations) => variations.sku!.toLowerCase().contains("${selectedColor?.toLowerCase()}-${taglia.toLowerCase()}"))
                                      .isEmpty &&
                                  selectedColor != null) ...[
                                Positioned.fill(
                                  top: 0,
                                  right: 0,
                                  child: Text("/",
                                      textAlign: TextAlign.center,
                                      style: context.textTheme().bodySmall?.copyWith(
                                            fontSize: 32,
                                            color: Colors.grey,
                                          )),
                                ),
                              ]
                            ],
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
                HapticFeedback.mediumImpact();
                setState(() {
                  selectedColor = null;
                  selectedSize = null;
                  widget.onSizeColorSelected(null, null);
                });
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    "Clear Selection".tr(),
                    style: context.textTheme().bodyMedium!.copyWith(
                          fontSize: 14,
                          color: Colors.red,
                        ),
                  ),
                ],
              ),
            ),
          )
        ],
      ],
    );
  }
}
