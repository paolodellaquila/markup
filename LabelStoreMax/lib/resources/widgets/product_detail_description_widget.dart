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
import 'package:flutter_app/utils/colors_manager.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:woosignal/models/response/product.dart';

import '/resources/widgets/woosignal_ui.dart';

class ProductDetailDescriptionWidget extends StatefulWidget {
  const ProductDetailDescriptionWidget({super.key, required this.product, required this.onSizeColorSelected});

  final Product? product;
  final void Function(String? size, String? color) onSizeColorSelected;

  @override
  State<ProductDetailDescriptionWidget> createState() => _ProductDetailDescriptionWidgetState();
}

class _ProductDetailDescriptionWidgetState extends State<ProductDetailDescriptionWidget> {
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
    if (widget.product!.shortDescription!.isEmpty && widget.product!.description!.isEmpty) {
      return SizedBox.shrink();
    }

    return ListView(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      children: [
        Container(
          height: 50,
          padding: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                trans("Description"),
                style: Theme.of(context).textTheme.bodySmall!.copyWith(fontSize: 18),
                textAlign: TextAlign.left,
              ),
              if (widget.product!.shortDescription!.isNotEmpty && widget.product!.description!.isNotEmpty)
                MaterialButton(
                  child: Text(
                    trans("Full description"),
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 14),
                    textAlign: TextAlign.right,
                    overflow: TextOverflow.ellipsis,
                  ),
                  height: 50,
                  minWidth: 60,
                  onPressed: () => _modalBottomSheetMenu(context),
                ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
          child: HtmlWidget(widget.product!.shortDescription!.isNotEmpty ? widget.product!.shortDescription! : widget.product!.description!,
              renderMode: RenderMode.column, onTapUrl: (String url) async {
            await launchUrl(Uri.parse(url));
            return true;
          }, textStyle: Theme.of(context).textTheme.bodyMedium),
        ),

        //TODO: FUTURE implementation: palette of colors
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
                Text(
                  "Colore".tr(),
                  style: context.textTheme().bodyLarge!.copyWith(fontSize: 18),
                ),
                const SizedBox(
                  height: 16,
                ),
                Wrap(
                  children: [
                    ...ColorsManager()
                        .getColorsFromProductTaxomonies(widget.product!.attributes.firstWhereOrNull((att) => (att.name ?? "").contains("Colore"))!.options!)
                        .map((color) => Padding(
                              padding: EdgeInsets.only(right: 8),
                              child: GestureDetector(
                                onTap: () {
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
                                        borderRadius: BorderRadius.circular(6),
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
        //TODO: FUTURE implementation: palette of Taglia
        if (widget.product?.attributes.firstWhereOrNull((att) => (att.name ?? "").contains("Taglia")) != null &&
            widget.product!.attributes.firstWhereOrNull((att) => (att.name ?? "").contains("Taglia"))!.options!.isNotEmpty) ...[
          Padding(
            padding: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Taglia".tr(),
                  style: context.textTheme().bodyLarge!.copyWith(fontSize: 18),
                ),
                const SizedBox(
                  height: 16,
                ),
                Wrap(
                  children: [
                    ...widget.product!.attributes.firstWhereOrNull((att) => (att.name ?? "").contains("Taglia"))!.options!.map((taglia) {
                      return Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedSize = taglia;
                              checkSizeColorSelected();
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: selectedSize == taglia ? Colors.black38 : Colors.grey, width: selectedSize == taglia ? 2 : 0.5),
                              borderRadius: BorderRadius.circular(6),
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

        const SizedBox(
          height: 24,
        ),

        if (widget.product!.permalink != null) ...[
          Padding(
            padding: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
            child: GestureDetector(
              onTap: () {
                Share.share(widget.product!.permalink!);
              },
              child: Row(
                children: [
                  Text(
                    "Share".tr(),
                    style: context.textTheme().headlineSmall!.copyWith(
                          color: Colors.blue,
                        ),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Icon(
                    Icons.share,
                    color: Colors.blue,
                  )
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  _modalBottomSheetMenu(BuildContext context) {
    wsModalBottom(
      context,
      title: trans("Description"),
      bodyWidget: SingleChildScrollView(
        child: HtmlWidget(widget.product!.description!),
      ),
    );
  }
}
