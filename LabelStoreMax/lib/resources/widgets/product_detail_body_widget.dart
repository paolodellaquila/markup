//  Label StoreMax
//
//  Created by Anthony Gordon.
//  2024, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:woosignal/models/response/product.dart';
import 'package:woosignal/models/response/product_variation.dart';
import 'package:woosignal/models/response/woosignal_app.dart';

import '/resources/pages/product_image_viewer_page.dart';
import '/resources/widgets/product_detail_description_widget.dart';
import '/resources/widgets/product_detail_header_widget.dart';
import '/resources/widgets/product_detail_image_swiper_widget.dart';
import '/resources/widgets/product_detail_related_products_widget.dart';
import '/resources/widgets/product_detail_reviews_widget.dart';
import '/resources/widgets/product_detail_upsell_widget.dart';

class ProductDetailBodyWidget extends StatefulWidget {
  const ProductDetailBodyWidget(
      {super.key, required this.product, required this.wooSignalApp, required this.onSizeColorSelected, this.selectedProductVariation});

  final Product? product;
  final ProductVariation? selectedProductVariation;
  final WooSignalApp? wooSignalApp;
  final void Function(String? size, String? color) onSizeColorSelected;

  @override
  State<ProductDetailBodyWidget> createState() => _ProductDetailBodyWidgetState();
}

class _ProductDetailBodyWidgetState extends State<ProductDetailBodyWidget> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      children: <Widget>[
        ProductDetailImageSwiperWidget(
            images: widget.selectedProductVariation != null
                ? widget.selectedProductVariation!.image != null
                    ? [widget.selectedProductVariation!.image!]
                    : widget.product!.images
                : widget.product!.images,
            onTapImage: (i) => _viewProductImages(context, i)),
        // </Image Swiper>

        ProductDetailHeaderWidget(product: widget.product),
        // </Header title + price>

        ProductDetailDescriptionWidget(product: widget.product, onSizeColorSelected: widget.onSizeColorSelected),
        // </Description body>

        ProductDetailReviewsWidget(product: widget.product, wooSignalApp: widget.wooSignalApp),
        // </Product reviews>

        if (widget.product != null) ProductDetailUpsellWidget(productIds: widget.product!.upsellIds, wooSignalApp: widget.wooSignalApp),
        // </You may also like>

        const SizedBox(height: 72),

        ProductDetailRelatedProductsWidget(product: widget.product, wooSignalApp: widget.wooSignalApp)
        // </Related products>
      ],
    );
  }

  _viewProductImages(BuildContext context, int i) {
    routeTo(ProductImageViewerPage.path, data: {"index": i, "images": widget.product!.images.map((f) => f.src).toList()});
  }
}
