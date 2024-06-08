//  Label StoreMax
//
//  Created by Anthony Gordon.
//  2024, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:flutter/material.dart';
import 'package:flutter_app/resources/widgets/cart_quantity_widget.dart';
import 'package:nylo_framework/nylo_framework.dart';

import '/resources/pages/cart_page.dart';

class CartIconWidget extends StatefulWidget {
  CartIconWidget({super.key});

  @override
  createState() => _CartIconWidgetState();
}

class _CartIconWidgetState extends State<CartIconWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70,
      child: IconButton(
        icon: Stack(
          children: <Widget>[
            Align(
              child: Icon(
                Icons.shopping_bag_outlined,
                size: 32,
              ),
              alignment: Alignment.topCenter,
            ),
            Align(
              child: CartQuantity(),
              alignment: Alignment.center,
            )
          ],
        ),
        onPressed: () => routeTo(CartPage.path),
      ),
    );
  }
}
