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

import '/resources/widgets/buttons.dart';

class ProductDetailFooterActionsWidget extends StatelessWidget {
  const ProductDetailFooterActionsWidget(
      {super.key,
      required this.product,
      required this.quantity,
      required this.onAddToCart,
      required this.onViewExternalProduct,
      required this.onAddQuantity,
      required this.onRemoveQuantity,
      this.disabled = false});

  final Product? product;
  final Function onViewExternalProduct;
  final Function onAddToCart;
  final Function onAddQuantity;
  final Function onRemoveQuantity;
  final int quantity;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // if (product!.type != "external")
            //   Row(
            //     crossAxisAlignment: CrossAxisAlignment.center,
            //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //     children: <Widget>[
            //       Text(
            //         trans("Quantity"),
            //         style: Theme.of(context)
            //             .textTheme
            //             .bodyLarge!
            //             .copyWith(color: Colors.grey),
            //       ),
            //       Row(
            //         children: <Widget>[
            //           IconButton(
            //             icon: Icon(
            //               Icons.remove_circle_outline,
            //               size: 28,
            //             ),
            //             onPressed: onRemoveQuantity as void Function()?,
            //           ),
            //           ProductQuantity(productId: product!.id!),
            //           IconButton(
            //             icon: Icon(
            //               Icons.add_circle_outline,
            //               size: 28,
            //             ),
            //             onPressed: onAddQuantity as void Function()?,
            //           ),
            //         ],
            //       )
            //     ],
            //   ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                /*Flexible(
                    child: Align(
                  child: Row(
                    children: [
                      AutoSizeText(
                        "${trans("Price")}:  ",
                        style: Theme.of(context).textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                      AutoSizeText(
                        formatStringCurrency(total: (parseWcPrice(product!.price) * quantity).toString()),
                        style: Theme.of(context).textTheme.headlineSmall,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  alignment: Alignment.centerLeft,
                )),*/
                product!.type == "external"
                    ? Flexible(
                        child: WooSignalButton(
                          key: key,
                          title: trans("Buy Product"),
                          action: onViewExternalProduct,
                          textStyle: Theme.of(context).textTheme.labelLarge!.copyWith(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                          bgColor: disabled ? Colors.grey : Colors.black,
                        ),
                      )
                    : Flexible(
                        child: WooSignalButton(
                          key: key,
                          title: trans("Add to cart"),
                          action: disabled ? null : onAddToCart,
                          textStyle: Theme.of(context).textTheme.labelLarge!.copyWith(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                          bgColor: disabled ? Colors.grey : Colors.black,
                        ),
                      )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
