//  Label StoreMax
//
//  Created by Anthony Gordon.
//  2024, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:flutter/material.dart';
import 'package:flutter_app/resources/widgets/buttons.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:share_plus/share_plus.dart';
import 'package:woosignal/models/response/product.dart';

import '/bootstrap/helpers.dart';
import '/resources/pages/product_detail_page.dart';
import '/resources/widgets/cached_image_widget.dart';

class WishListPageWidget extends StatefulWidget {
  static String path = "/wishlist";

  @override
  createState() => _WishListPageWidgetState();
}

class _WishListPageWidgetState extends NyState<WishListPageWidget> with AutomaticKeepAliveClientMixin {
  List<Product> _products = [];

  @override
  boot() async {
    await loadProducts();
  }

  loadProducts() async {
    List<dynamic> favouriteProducts = await getWishlistProducts();
    List<int> productIds = favouriteProducts.map((e) => e['id']).cast<int>().toList();
    if (productIds.isEmpty) {
      return;
    }
    _products = await (appWooSignal((api) => api.getProducts(
          include: productIds,
          perPage: 100,
          status: "publish",
          stockStatus: "instock",
        )));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(trans("Wishlist")),
      ),
      body: SafeArea(
        child: afterLoad(
            child: () => _products.isEmpty
                ? Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.favorite,
                          size: 40,
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                        ),
                        Text(trans("No items in whishlist"), style: Theme.of(context).textTheme.titleLarge!.setColor(context, (color) => Colors.black)),
                        const SizedBox(
                          height: 16,
                        ),
                        Container(
                          width: 200,
                          child: SecondaryButton(
                            title: trans("Update"),
                            action: loadProducts,
                          ),
                        )
                      ],
                    ),
                  )
                : GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 2,
                      childAspectRatio: 0.6,
                    ),
                    padding: EdgeInsets.all(8),
                    itemBuilder: (BuildContext context, int index) {
                      Product product = _products[index];
                      return InkWell(
                        onTap: () => routeTo(ProductDetailPage.path, data: product),
                        child: Card(
                          elevation: 8,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.white,
                            ),
                            child: ListView(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              children: [
                                Stack(
                                  children: [
                                    Container(
                                      height: 220,
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
                                              image: (product.images.isNotEmpty ? product.images.first.src : getEnv("PRODUCT_PLACEHOLDER_IMAGE")),
                                              fit: BoxFit.cover,
                                              height: 220,
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
                                                          text:
                                                              "${workoutSaleDiscount(salePrice: product.salePrice, priceBefore: product.regularPrice)}% ${trans("off")}",
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
                                    Positioned(
                                      right: 0,
                                      top: 0,
                                      child: Container(
                                        alignment: Alignment.center,
                                        child: IconButton(
                                          icon: Icon(
                                            Icons.favorite,
                                            color: Colors.red,
                                          ),
                                          onPressed: () => _removeFromWishlist(product),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                Container(
                                  padding: EdgeInsets.all(8),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        product.name!,
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              formatStringCurrency(total: product.price),
                                              style: TextStyle(fontSize: 18),
                                            ),
                                          ),
                                          if (product.permalink != null) ...[
                                            Container(
                                              alignment: Alignment.center,
                                              child: IconButton(
                                                icon: Icon(
                                                  Icons.share,
                                                  color: Colors.blue,
                                                ),
                                                onPressed: () => _shareProduct(product),
                                              ),
                                            )
                                          ],
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    itemCount: _products.length,
                  ),
            loading: Center(
              child: CircularProgressIndicator(),
            )),
      ),
    );
  }

  _removeFromWishlist(Product product) async {
    await removeWishlistProduct(product: product);
    showToastNotification(
      context,
      title: trans('Success'),
      icon: Icons.shopping_cart,
      description: trans('Item removed'),
    );
    _products.remove(product);
    setState(() {});
  }

  _shareProduct(Product product) {
    Share.share(product.permalink!);
  }

  @override
  bool get wantKeepAlive => true;
}
