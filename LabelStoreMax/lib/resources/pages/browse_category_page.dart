//  Label StoreMax
//
//  Created by Anthony Gordon.
//  2024, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/app/models/filter_rules.dart';
import 'package:flutter_app/resources/pages/browse_search_page.dart';
import 'package:flutter_app/resources/widgets/buttons.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:woosignal/models/response/product.dart' as ws_product;
import 'package:woosignal/models/response/product_category.dart';

import '/bootstrap/enums/sort_enums.dart';
import '/bootstrap/helpers.dart';
import '/resources/pages/product_detail_page.dart';
import '/resources/widgets/product_item_container_widget.dart';
import '/resources/widgets/safearea_widget.dart';
import '/resources/widgets/woosignal_ui.dart';
import 'product_filters_page.dart';

class BrowseCategoryPage extends NyStatefulWidget {
  static String path = "/browse-category";

  BrowseCategoryPage({Key? key}) : super(path, key: key, child: _BrowseCategoryPageState());
}

class _BrowseCategoryPageState extends NyState<BrowseCategoryPage> {
  ProductCategory? productCategory;
  List<ws_product.Product> _freezeProducts = [];
  List<ws_product.Product>? _filteredProducts = [];
  FilterRules? _filterRules;

  _BrowseCategoryPageState();

  SortByType? _sortByType;
  String? _sortTitle;

  final TextEditingController _txtSearchController = TextEditingController();
  bool isSearching = false;

  _actionSearch() {
    if (_txtSearchController.text.isEmpty) return;
    if (_txtSearchController.text.length < 3) return;

    try {
      ///log
      FirebaseAnalytics.instance.logSearch(searchTerm: _txtSearchController.text);
      FacebookAppEvents().logViewContent(type: "search", id: _txtSearchController.text);
    } catch (e) {
      print("Error logging search: $e");
    }

    routeTo(BrowseSearchPage.path, data: _txtSearchController.text, onPop: (value) {
      Navigator.pop(context);
    });
  }

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
            afterNotNull(productCategory, child: () => Text(parseHtmlString(productCategory!.name)), loading: CupertinoActivityIndicator()),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              setState(() {
                isSearching = !isSearching;
              });
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(32),
          child: Center(
            child: Column(
              children: [
                afterNotNull(
                  productCategory,
                  child: () => Padding(
                      padding: const EdgeInsets.only(left: 24, right: 18),
                      child: _freezeProducts.isNotEmpty
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                GestureDetector(
                                  onTap: () async {
                                    routeTo(ProductFiltersPage.path, data: {"products": _freezeProducts, "filters": _filterRules}, onPop: (result) {
                                      if (result != null) {
                                        if (result["rules"] != null) {
                                          _filterRules = result["rules"];
                                          _filteredProducts = _applyFilters(result["rules"], _freezeProducts);
                                          _applySort();
                                        } else {
                                          _filterRules = null;
                                          _filteredProducts = null;
                                          _sortByType = SortByType.clear;
                                          _applySort();
                                        }
                                      }
                                    });
                                  },
                                  child: _filterRules == null
                                      ? Row(
                                          children: [
                                            Icon(Icons.filter_list_outlined, size: 18),
                                            const SizedBox(width: 4),
                                            Text("Filters".tr(), style: Theme.of(context).textTheme.bodyLarge),
                                          ],
                                        )
                                      : Container(
                                          decoration: BoxDecoration(
                                            color: Colors.black,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Center(
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 8),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.filter_list_outlined,
                                                    size: 18,
                                                    color: Colors.white,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                      "${_filterRules!.selectedAttributes.isNotEmpty ? _filterRules!.selectedAttributes.length : ''} ${"Filters".tr()}",
                                                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                                            color: Colors.white,
                                                          )),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                ),
                                GestureDetector(
                                  onTap: _modalSheetTune,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Icon(Icons.compare_arrows_outlined, size: 18),
                                      const SizedBox(width: 4),
                                      Text(_sortTitle ?? trans("Empty Sort"), style: Theme.of(context).textTheme.bodyMedium),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          : const SizedBox.shrink()),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SafeAreaWidget(
          child: Column(
        children: [
          const SizedBox(height: 16),
          if (isSearching) ...[
            NyTextField.compact(
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: trans("Search hint"),
                hintStyle: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.black),
              ),
              backgroundColor: Colors.grey.shade200,
              controller: _txtSearchController,
              style: Theme.of(context).textTheme.bodySmall,
              keyboardType: TextInputType.text,
              autocorrect: false,
              autoFocus: false,
              textCapitalization: TextCapitalization.sentences,
              onSubmitted: (_) => _actionSearch,
            ),
            const SizedBox(height: 16),
            PrimaryButton(
              title: trans("Search"),
              action: _actionSearch,
            ),
            const SizedBox(height: 36),
          ],
          Expanded(
            child: NyPullToRefresh.grid(
              data: (page) async {
                final products = await appWooSignal((api) => api.getProducts(
                      perPage: 25,
                      category: productCategory?.id.toString(),
                      page: page,
                      status: "publish",
                      stockStatus: "instock",
                    ));
                setState(() {
                  _freezeProducts = products;
                });
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
                if (_filteredProducts != null && _filteredProducts!.isNotEmpty) {
                  return _sortProducts(_filteredProducts!, by: _sortByType ?? SortByType.dateDesc);
                }
                return _sortProducts(products, by: _sortByType ?? SortByType.dateDesc);
              },
            ),
          ),
        ],
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
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ..._buildSortOptions(setState),
          ],
        );
      }),
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
            _sortTitle = trans("Sort: Name A-Z");
            _sortByType = SortByType.nameAZ;
          });
          _applySort();
        },
      ),
      _buildDivider(),
      _buildLinkButton(
        title: trans("Sort: Date New to Old"),
        icon: Icons.update_outlined,
        isSelected: _sortByType == SortByType.dateDesc,
        onTap: () {
          setState(() {
            _sortTitle = trans("Sort: Date New to Old");
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
            _sortTitle = trans("Sort: Date Old to New");
            _sortByType = SortByType.dateAsc;
          });
          _applySort();
        },
      ),
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
    setState(() {});
    //pop();
  }

  _showProduct(ws_product.Product product) {
    routeTo(ProductDetailPage.path, data: product);
  }

  List<ws_product.Product> _applyFilters(FilterRules filters, List<ws_product.Product> products) {
    return products.where((product) {
      // Filter by selected attributes
      bool matchesAttributes = filters.selectedAttributes.entries.every((entry) {
        final attribute = entry.key;
        final selectedValues = entry.value;
        return product.attributes.any(
            (productAttribute) => productAttribute.id == attribute.id && productAttribute.options?.any((option) => selectedValues.contains(option)) == true);
      });

      // Filter by price range
      final productPrice = double.tryParse(product.price ?? "0") ?? 0;
      bool matchesPrice = productPrice >= filters.selectedPriceRange.minPrice && productPrice <= filters.selectedPriceRange.maxPrice;

      return matchesAttributes && matchesPrice;
    }).toList();
  }
}
