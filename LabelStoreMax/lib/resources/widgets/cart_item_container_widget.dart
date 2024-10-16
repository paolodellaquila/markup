import 'package:flutter/material.dart';
import 'package:flutter_app/app/models/cart_line_item.dart';
import 'package:flutter_app/bootstrap/helpers.dart';
import 'package:flutter_app/resources/widgets/cached_image_widget.dart';
import 'package:nylo_framework/nylo_framework.dart';

class CartItemContainer extends StatelessWidget {
  const CartItemContainer({
    super.key,
    required this.cartLineItem,
    required this.actionIncrementQuantity,
    required this.actionDecrementQuantity,
    required this.actionRemoveItem,
    this.actionShareItem,
  });

  final CartLineItem cartLineItem;
  final void Function() actionIncrementQuantity;
  final void Function() actionDecrementQuantity;
  final void Function() actionRemoveItem;
  final void Function()? actionShareItem;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
        ),
        child: Padding(
          padding: EdgeInsets.all(8),
          child: Column(
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: CachedImageWidget(
                      image: (cartLineItem.imageSrc == "" ? getEnv("PRODUCT_PLACEHOLDER_IMAGE") : cartLineItem.imageSrc),
                      width: 130,
                      height: 130,
                      fit: BoxFit.contain,
                    ),
                    flex: 2,
                  ),
                  Flexible(
                    child: Padding(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(
                                flex: 3,
                                child: Text(
                                  cartLineItem.name!,
                                  style: Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 3,
                                ),
                              ),
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: actionRemoveItem,
                                    child: Icon(
                                      Icons.delete_outline,
                                      color: Colors.deepOrangeAccent,
                                      size: 18,
                                    ),
                                  ),
                                  if (actionShareItem != null) ...[
                                    SizedBox(width: 16),
                                    GestureDetector(
                                      onTap: actionShareItem,
                                      child: Icon(
                                        Icons.share,
                                        color: Colors.blue,
                                        size: 18,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ...cartLineItem.getVariantOptions().map(
                                    (option) => Text(option, style: Theme.of(context).textTheme.bodyLarge),
                                  ),
                            ],
                          ),
                          SizedBox(height: 16),
                          Row(
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  IconButton(
                                    icon: Icon(Icons.remove_circle_outline),
                                    onPressed: actionDecrementQuantity,
                                    highlightColor: Colors.transparent,
                                  ),
                                  Text(cartLineItem.quantity.toString(), style: Theme.of(context).textTheme.titleLarge),
                                  IconButton(
                                    icon: Icon(Icons.add_circle_outline),
                                    onPressed: actionIncrementQuantity,
                                    highlightColor: Colors.transparent,
                                  ),
                                ],
                              ),
                              Expanded(child: SizedBox.shrink()),
                              Text(
                                formatDoubleCurrency(
                                  total: parseWcPrice(cartLineItem.total),
                                ),
                                style: Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              )
                            ],
                          ),
                        ],
                      ),
                      padding: EdgeInsets.only(left: 8),
                    ),
                    flex: 5,
                  )
                ],
              ),
              // Row(
              //   crossAxisAlignment: CrossAxisAlignment.center,
              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //   children: <Widget>[
              //     Row(
              //       crossAxisAlignment: CrossAxisAlignment.center,
              //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //       children: <Widget>[
              //         IconButton(
              //           icon: Icon(Icons.remove_circle_outline),
              //           onPressed: actionDecrementQuantity,
              //           highlightColor: Colors.transparent,
              //         ),
              //         Text(cartLineItem.quantity.toString(), style: Theme.of(context).textTheme.titleLarge),
              //         IconButton(
              //           icon: Icon(Icons.add_circle_outline),
              //           onPressed: actionIncrementQuantity,
              //           highlightColor: Colors.transparent,
              //         ),
              //       ],
              //     ),
              //     Expanded(child: SizedBox.shrink()),
              //     IconButton(
              //       alignment: Alignment.centerRight,
              //       icon: Icon(Icons.delete_outline, color: Colors.deepOrangeAccent, size: 20),
              //       onPressed: actionRemoveItem,
              //       highlightColor: Colors.transparent,
              //     ),
              //   ],
              // )
            ],
          ),
        ),
      ),
    );
  }
}
