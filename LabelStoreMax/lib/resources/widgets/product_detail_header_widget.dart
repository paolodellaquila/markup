//  Label StoreMax
//
//  Created by Anthony Gordon.
//  2024, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/app/controllers/product_detail_controller.dart';
import 'package:flutter_app/bootstrap/enums/wishlist_action_enums.dart';
import 'package:flutter_app/resources/widgets/woosignal_ui.dart';
import 'package:flutter_app/utils/product_manager.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:woosignal/models/response/product.dart';
import 'package:woosignal/models/response/product_variation.dart';
import 'package:woosignal/models/response/woosignal_app.dart';

import '/bootstrap/helpers.dart';

class ProductDetailHeaderWidget extends StatefulWidget {
  const ProductDetailHeaderWidget(
      {super.key,
      required this.product,
      this.productOnSalePrice,
      this.selectedProductVariation,
      this.productOriginalPrice,
      required this.controller,
      required this.wooSignalApp});

  final ProductDetailController controller;
  final WooSignalApp? wooSignalApp;
  final Product? product;
  final String? productOnSalePrice;
  final String? productOriginalPrice;
  final ProductVariation? selectedProductVariation;

  @override
  State<ProductDetailHeaderWidget> createState() => _ProductDetailHeaderWidgetState();
}

class _ProductDetailHeaderWidgetState extends State<ProductDetailHeaderWidget> {
  _modalBottomSheetMenu(BuildContext context) {
    wsModalBottom(
      context,
      title: trans("Description"),
      bodyWidget: SingleChildScrollView(
        child: HtmlWidget(widget.product!.description!),
      ),
    );
  }

  _calculateDiscountPrice() {
    String? regularPrice = widget.selectedProductVariation?.regularPrice ?? widget.productOriginalPrice;
    String? salePrice = widget.selectedProductVariation?.salePrice ?? widget.productOnSalePrice;

    double? discountPercentage;
    if (regularPrice != null && salePrice != null) {
      double regular = double.parse(regularPrice);
      double sale = double.parse(salePrice);
      discountPercentage = ((regular - sale) / regular) * 100;
    }

    return discountPercentage;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 16,
      ).copyWith(
        top: 24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: AutoSizeText(
                  widget.product!.name!,
                  style: Theme.of(context).textTheme.headlineMedium!.copyWith(fontSize: 20),
                  textAlign: TextAlign.left,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
              Row(
                children: [
                  if (widget.product!.permalink != null) ...[
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.mediumImpact();
                        Share.share(widget.product!.permalink!);
                      },
                      child: Icon(
                        Icons.share,
                        size: 24,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                  const SizedBox(width: 24),
                  if (widget.wooSignalApp!.wishlistEnabled!)
                    NyFutureBuilder(
                        future: hasAddedWishlistProduct(widget.product?.id),
                        child: (context, dynamic isInFavourites) {
                          return isInFavourites
                              ? GestureDetector(
                                  onTap: () => widget.controller.toggleWishList(onSuccess: () => setState(() {}), wishlistAction: WishlistAction.remove),
                                  child: Icon(Icons.favorite, size: 32, color: Colors.red))
                              : GestureDetector(
                                  onTap: () => widget.controller.toggleWishList(onSuccess: () => setState(() {}), wishlistAction: WishlistAction.add),
                                  child: Icon(
                                    Icons.favorite_border,
                                    size: 32,
                                  ));
                        }),
                ],
              ),
            ],
          ),
          AutoSizeText(
            (widget.product!.sku!.isNotEmpty ? " (${widget.product!.sku})" : "").trim(),
            style: Theme.of(context).textTheme.headlineMedium!.copyWith(fontSize: 14),
            textAlign: TextAlign.left,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
          const SizedBox(
            height: 16,
          ),
          Container(
            child: HtmlWidget(widget.product!.shortDescription!.isNotEmpty ? widget.product!.shortDescription! : widget.product!.description!,
                renderMode: RenderMode.column, onTapUrl: (String url) async {
              await launchUrl(Uri.parse(url));
              return true;
            }, textStyle: Theme.of(context).textTheme.bodyMedium),
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
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              if (widget.product!.onSale == true) ...[
                Text(
                  ProductManager()
                      .internationalPricingRate(formatStringCurrency(total: widget.selectedProductVariation?.regularPrice ?? widget.productOriginalPrice))
                      .toString(),
                  style: TextStyle(color: Colors.grey, decoration: TextDecoration.lineThrough, fontSize: 20),
                ),
                const SizedBox(width: 8),
                Text(
                  ProductManager()
                      .internationalPricingRate(formatStringCurrency(total: widget.selectedProductVariation?.salePrice ?? widget.productOnSalePrice))
                      .toString(),
                  style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                        fontSize: 20,
                      ),
                  textAlign: TextAlign.right,
                ),
                const SizedBox(width: 8),
                if (_calculateDiscountPrice() != null)
                  Chip(
                    label: Text("-${_calculateDiscountPrice().toStringAsFixed(0)}% ${"Discount".tr()}", style: TextStyle(color: Colors.white)),
                    backgroundColor: Colors.black,
                    side: BorderSide(color: Colors.black),
                    padding: EdgeInsets.zero,
                  )
              ] else ...[
                Text(
                  ProductManager()
                      .internationalPricingRate(formatStringCurrency(total: widget.selectedProductVariation?.price ?? widget.product!.price))
                      .toString(),
                  style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                        fontSize: 20,
                      ),
                  textAlign: TextAlign.right,
                ),
              ],
            ],
          )
        ],
      ),
    );
  }
}
