import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/utils/price_extractor.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:woosignal/models/response/product.dart';

import '/bootstrap/helpers.dart';
import '/resources/widgets/cached_image_widget.dart';

class ProductItemContainer extends StatelessWidget {
  const ProductItemContainer({
    super.key,
    this.product,
    this.onTap,
  });

  final Product? product;
  final Function()? onTap;

  _calculateDiscountPrice({String? regularPrice, String? salePrice}) {
    double? discountPercentage;
    if (regularPrice != null && salePrice != null) {
      double regular = double.parse(regularPrice.replaceAll(",", "."));
      double sale = double.parse(salePrice);
      discountPercentage = ((regular - sale) / regular) * 100;
    }

    return discountPercentage?.round();
  }

  @override
  Widget build(BuildContext context) {
    if (product == null) {
      return SizedBox.shrink();
    }

    double height = 310;
    return InkWell(
      child: Container(
        margin: EdgeInsets.all(4),
        child: ListView(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          children: <Widget>[
            Container(
              height: 210,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(3.0),
                child: Stack(
                  children: [
                    Container(
                      color: Colors.grey[100],
                      height: double.infinity,
                      width: double.infinity,
                    ),
                    CachedImageWidget(
                      image: (product!.images.isNotEmpty ? product!.images.first.src : getEnv("PRODUCT_PLACEHOLDER_IMAGE")),
                      fit: BoxFit.cover,
                      height: height,
                      width: double.maxFinite,
                    ),
                    if (isProductNew(product))
                      Container(
                        padding: EdgeInsets.all(4),
                        child: Text(
                          "New",
                          style: TextStyle(color: Colors.white),
                        ),
                        decoration: BoxDecoration(color: Colors.black),
                      ),
                    if (product!.onSale!)
                      Positioned(
                        right: 0,
                        child: Container(
                          padding: EdgeInsets.all(4),
                          child: Text(
                            "${_calculateDiscountPrice(regularPrice: PriceExtractor.extractRegularPrice(product?.priceHtml), salePrice: product?.price)}%",
                            style: TextStyle(color: Colors.white),
                          ),
                          decoration: BoxDecoration(color: Colors.red),
                        ),
                      ),
                    if (product!.onSale! && product!.type != "variable")
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: Colors.white70,
                          ),
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              text: '',
                              style: Theme.of(context).textTheme.bodyLarge,
                              children: <TextSpan>[
                                TextSpan(
                                  text: "${workoutSaleDiscount(salePrice: product!.salePrice, priceBefore: product!.regularPrice)}% ${trans("off")}",
                                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                        color: Colors.black,
                                        fontSize: 13,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 2, bottom: 2),
              child: Text(
                product?.name ?? "",
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 15),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              padding: EdgeInsets.only(top: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  if (product?.onSale ?? false) ...[
                    AutoSizeText(
                      formatStringCurrency(total: PriceExtractor.extractRegularPrice(product?.priceHtml)),
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge!
                          .copyWith(fontWeight: FontWeight.w600, decoration: TextDecoration.lineThrough, color: Colors.grey),
                      textAlign: TextAlign.left,
                    ),
                    SizedBox(width: 4),
                  ],
                  AutoSizeText(
                    formatStringCurrency(total: product?.price),
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.w800),
                    textAlign: TextAlign.left,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      onTap: onTap,
    );
  }
}
