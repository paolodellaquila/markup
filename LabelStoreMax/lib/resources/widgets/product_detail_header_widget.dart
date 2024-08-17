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
import 'package:flutter_app/resources/widgets/woosignal_ui.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:woosignal/models/response/product.dart';
import 'package:woosignal/models/response/product_variation.dart';

import '/bootstrap/helpers.dart';

class ProductDetailHeaderWidget extends StatelessWidget {
  const ProductDetailHeaderWidget({super.key, required this.product, this.productOnSalePrice, this.selectedProductVariation, this.productOriginalPrice});

  final Product? product;
  final String? productOnSalePrice;
  final String? productOriginalPrice;
  final ProductVariation? selectedProductVariation;

  _modalBottomSheetMenu(BuildContext context) {
    wsModalBottom(
      context,
      title: trans("Description"),
      bodyWidget: SingleChildScrollView(
        child: HtmlWidget(product!.description!),
      ),
    );
  }

  _calculateDiscountPrice() {
    String? regularPrice = selectedProductVariation?.regularPrice ?? productOriginalPrice;
    String? salePrice = selectedProductVariation?.salePrice ?? productOnSalePrice;

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
                  product!.name!,
                  style: Theme.of(context).textTheme.headlineMedium!.copyWith(fontSize: 20),
                  textAlign: TextAlign.left,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
              if (product!.permalink != null) ...[
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      Share.share(product!.permalink!);
                    },
                    child: Icon(
                      Icons.share,
                      size: 24,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(
            height: 8,
          ),
          Container(
            child: HtmlWidget(product!.shortDescription!.isNotEmpty ? product!.shortDescription! : product!.description!, renderMode: RenderMode.column,
                onTapUrl: (String url) async {
              await launchUrl(Uri.parse(url));
              return true;
            }, textStyle: Theme.of(context).textTheme.bodyMedium),
          ),
          if (product!.shortDescription!.isNotEmpty && product!.description!.isNotEmpty)
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
              if (product!.onSale == true) ...[
                Text(
                  formatStringCurrency(total: selectedProductVariation?.regularPrice ?? productOriginalPrice),
                  style: TextStyle(color: Colors.grey, decoration: TextDecoration.lineThrough, fontSize: 20),
                ),
                const SizedBox(width: 8),
                Text(
                  formatStringCurrency(total: selectedProductVariation?.salePrice ?? productOnSalePrice),
                  style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                        fontSize: 20,
                      ),
                  textAlign: TextAlign.right,
                ),
                const SizedBox(width: 8),
                if (_calculateDiscountPrice() != null)
                  Chip(
                    label: Text("-${_calculateDiscountPrice().toStringAsFixed(0)}% ${"Discount".tr()}"),
                    backgroundColor: Colors.red[200],
                    side: BorderSide(color: Colors.red[200]!),
                    padding: EdgeInsets.zero,
                  )
              ] else ...[
                Text(
                  formatStringCurrency(total: selectedProductVariation?.price ?? product!.price),
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
