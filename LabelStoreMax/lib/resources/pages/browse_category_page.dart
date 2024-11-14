//  Label StoreMax
//
//  Created by Anthony Gordon.
//  2024, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:woosignal/models/response/product.dart' as ws_product;
import 'package:woosignal/models/response/product_category.dart';

import '/bootstrap/enums/sort_enums.dart';
import '/bootstrap/helpers.dart';
import '/resources/pages/product_detail_page.dart';
import '/resources/widgets/product_item_container_widget.dart';
import '/resources/widgets/safearea_widget.dart';
import '/resources/widgets/woosignal_ui.dart';

class BrowseCategoryPage extends NyStatefulWidget {
  static String path = "/browse-category";

  BrowseCategoryPage({Key? key}) : super(path, key: key, child: _BrowseCategoryPageState());
}

class _BrowseCategoryPageState extends NyState<BrowseCategoryPage> {
  ProductCategory? productCategory;
  double _minPrice = 0;
  double _maxPrice = 1000;
  List<ws_product.Product> _freezeProducts = [];

  _BrowseCategoryPageState();

  SortByType? _sortByType;

  @override
  init() async {
    productCategory = widget.controller.data();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(trans("Browse"), style: Theme.of(context).textTheme.titleMedium),
            afterNotNull(productCategory, child: () => Text(parseHtmlString(productCategory!.name)), loading: CupertinoActivityIndicator())
          ],
        ),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.tune),
            onPressed: _modalSheetTune,
          )
        ],
      ),
      body: SafeAreaWidget(
          child: NyPullToRefresh.grid(
        data: (page) async {
          final products = await appWooSignal((api) => api.getProducts(
                perPage: 25,
                category: productCategory?.id.toString(),
                page: page,
                status: "publish",
                stockStatus: "instock",
              ));
          _freezeProducts = products;
          return products;
        },
        child: (context, product) {
          return Container(
            height: 320,
            child: ProductItemContainer(
              product: product,
              onTap: () => _showProduct(product),
            ),
          );
        },
        stateName: 'browse_category_pull_to_refresh',
        sort: (products) {
          return _sortProducts(products, by: _sortByType ?? SortByType.dateDesc);
        },
      )),
    );
  }

  _sortProducts(List<ws_product.Product> products, {required SortByType by}) {
    switch (by) {
      case SortByType.lowToHigh:
        products.sort(
          (product1, product2) => (parseWcPrice(product1.price)).compareTo((parseWcPrice(product2.price))),
        );
        break;
      case SortByType.highToLow:
        products.sort(
          (product1, product2) => (parseWcPrice(product2.price)).compareTo((parseWcPrice(product1.price))),
        );
        break;
      case SortByType.nameAZ:
        products.sort(
          (product1, product2) => product1.name!.compareTo(product2.name!),
        );
        break;
      case SortByType.nameZA:
        products.sort(
          (product1, product2) => product2.name!.compareTo(product1.name!),
        );
        break;
      case SortByType.dateAsc:
        products.sort((product1, product2) {
          DateTime? date1 = product1.dateCreated.toDateTime();
          DateTime? date2 = product2.dateCreated.toDateTime();
          return date1.compareTo(date2);
        });
      case SortByType.dateDesc:
        products.sort((product1, product2) {
          DateTime? date1 = product1.dateCreated.toDateTime();
          DateTime? date2 = product2.dateCreated.toDateTime();
          return date2.compareTo(date1);
        });
        break;
      case SortByType.price:
        final temp_product = products.where((product) {
          double price = parseWcPrice(product.price);
          return price >= _minPrice && price <= _maxPrice;
        }).toList();

        if (temp_product.isNotEmpty) {
          products = temp_product;
        }
      case SortByType.clear:
        products = _freezeProducts;
        break;
    }
    return products;
  }

  _modalSheetTune() {
    wsModalBottom(
      context,
      title: trans("Sort results"),
      bodyWidget: StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ..._buildSortOptions(setState),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ///Clear
                Padding(
                  padding: const EdgeInsets.only(top: 24.0),
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      _minPrice = 0;
                      _maxPrice = 1000;
                      _sortByType = SortByType.clear;
                      _applySort();
                      pop();
                    },
                    icon: Icon(Icons.cancel, color: Colors.grey[700]),
                    label: Text(
                      trans("Clear filters"),
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.grey[700],
                      backgroundColor: Colors.grey[200],
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                    ),
                  ),
                ),

                ///Close
                Padding(
                  padding: const EdgeInsets.only(top: 24.0),
                  child: ElevatedButton.icon(
                    onPressed: pop,
                    icon: Icon(Icons.cancel, color: Colors.grey[700]),
                    label: Text(
                      trans("Close"),
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.grey[700],
                      backgroundColor: Colors.grey[200],
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      }),
    );
  }

  Widget _buildPriceSlider(StateSetter setState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            trans("Price"),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        RangeSlider(
          values: RangeValues(_minPrice, _maxPrice),
          min: 0,
          max: 2000,
          divisions: 40,
          labels: RangeLabels(
            "\$${_minPrice.toStringAsFixed(0)}",
            "\$${_maxPrice.toStringAsFixed(0)}",
          ),
          onChanged: (RangeValues values) {
            setState(() {
              _minPrice = values.start;
              _maxPrice = values.end;
            });
          },
          onChangeEnd: (RangeValues values) {
            _sortByType = SortByType.price;
            _applySort();
          },
          activeColor: Colors.blue,
          inactiveColor: Colors.grey[300],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            "${'Price Range'.tr()}: \$${_minPrice.toStringAsFixed(0)} - \$${_maxPrice.toStringAsFixed(0)}",
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildSortOptions(StateSetter setState) {
    return [
      _buildLinkButton(
        title: trans("Sort: Name A-Z"),
        icon: Icons.sort_by_alpha,
        isSelected: _sortByType == SortByType.nameAZ,
        onTap: () {
          setState(() {
            _sortByType = SortByType.nameAZ;
          });
          _applySort();
        },
      ),
      _buildDivider(),
      _buildLinkButton(
        title: trans("Sort: Date New to Old"),
        icon: Icons.history,
        isSelected: _sortByType == SortByType.dateDesc,
        onTap: () {
          setState(() {
            _sortByType = SortByType.dateDesc;
          });
          _applySort();
        },
      ),
      _buildDivider(),
      _buildLinkButton(
        title: trans("Sort: Date Old to New"),
        icon: Icons.history,
        isSelected: _sortByType == SortByType.dateAsc,
        onTap: () {
          setState(() {
            _sortByType = SortByType.dateAsc;
          });
          _applySort();
        },
      ),
      _buildDivider(),
      _buildPriceSlider(setState),
    ];
  }

  Widget _buildLinkButton({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
      leading: Icon(icon, color: isSelected ? Colors.blue : Colors.grey[600]),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? Colors.blue : Colors.black,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onTap: onTap,
      trailing: isSelected ? Icon(Icons.check, color: Colors.blue) : null,
    );
  }

  Widget _buildDivider() {
    return Divider(
      thickness: 1,
      color: Colors.grey[300],
      indent: 16.0,
      endIndent: 16.0,
    );
  }

  void _applySort() {
    StateAction.refreshPage('browse_category_pull_to_refresh', setState: () {});
    //pop();
  }

  _showProduct(ws_product.Product product) {
    routeTo(ProductDetailPage.path, data: product);
  }
}
