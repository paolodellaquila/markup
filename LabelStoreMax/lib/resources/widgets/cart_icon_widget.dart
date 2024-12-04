//  Label StoreMax
//
//  Created by Anthony Gordon.
//  2024, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:flutter_app/app/models/cart.dart';
import 'package:flutter_app/resources/widgets/cart_quantity_widget.dart';
import 'package:nylo_framework/nylo_framework.dart';

import '/resources/pages/cart_page.dart';

class CartIconWidget extends StatefulWidget {
  final double? size;
  final Color color;

  CartIconWidget({super.key, this.size = 50, this.color = Colors.black});

  @override
  createState() => _CartIconWidgetState();
}

class _CartIconWidgetState extends State<CartIconWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.size,
      child: IconButton(
        icon: Stack(
          children: <Widget>[
            Align(
              child: Icon(
                Icons.shopping_bag_outlined,
                size: 32,
                color: widget.color,
              ),
              alignment: Alignment.topCenter,
            ),
            Align(
              alignment: Alignment.center,
              child: badges.Badge(
                badgeContent: CartQuantity(color: Colors.white),
                badgeAnimation: badges.BadgeAnimation.fade(animationDuration: Duration(milliseconds: 500)),
                badgeStyle: badges.BadgeStyle(
                  shape: badges.BadgeShape.circle,
                  badgeColor: Colors.redAccent,
                  elevation: 0,
                ),
                showBadge: Cart.getInstance.cartLineItems.isNotEmpty,
                child: Container(),
              ),
            )
          ],
        ),
        onPressed: () => routeTo(CartPage.path),
      ),
    );
  }
}
