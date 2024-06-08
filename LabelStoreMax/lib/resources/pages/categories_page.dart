import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/bootstrap/helpers.dart';
import 'package:flutter_app/resources/pages/browse_category_page.dart';
import 'package:flutter_app/resources/pages/browse_search_page.dart';
import 'package:flutter_app/resources/widgets/app_loader_widget.dart';
import 'package:flutter_app/resources/widgets/buttons.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:woosignal/models/response/product_category.dart';
import 'package:woosignal/models/response/product_category_collection.dart';
import 'package:woosignal/models/response/woosignal_app.dart';

class CategoriesPage extends StatefulWidget {
  static String path = "/categories";

  const CategoriesPage({super.key, required this.wooSignalApp});

  final WooSignalApp? wooSignalApp;

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends NyState<CategoriesPage> {
  List<ProductCategory> categories = [];
  final TextEditingController _txtSearchController = TextEditingController();

  _actionSearch() {
    if (_txtSearchController.text.isEmpty) return;
    if (_txtSearchController.text.length < 3) return;

    routeTo(BrowseSearchPage.path, data: _txtSearchController.text, onPop: (value) {
      if (["notic", "compo"].contains(widget.wooSignalApp!.theme) == false) {
        Navigator.pop(context);
      }
    });
  }

  _loadCategories() async {
    if ((widget.wooSignalApp?.productCategoryCollections ?? []).isNotEmpty) {
      List<int> productCategoryId = widget.wooSignalApp?.productCategoryCollections.map((e) => int.parse(e.collectionId!)).toList() ?? [];
      categories = await (appWooSignal((api) => api.getProductCategories(parent: 0, perPage: 50, hideEmpty: true, include: productCategoryId)));
      categories.sort((category1, category2) {
        ProductCategoryCollection? productCategoryCollection1 =
            widget.wooSignalApp?.productCategoryCollections.firstWhereOrNull((element) => element.collectionId == category1.id.toString());
        ProductCategoryCollection? productCategoryCollection2 =
            widget.wooSignalApp?.productCategoryCollections.firstWhereOrNull((element) => element.collectionId == category2.id.toString());

        if (productCategoryCollection1 == null) return 0;
        if (productCategoryCollection2 == null) return 0;

        if (productCategoryCollection1.position == null) return 0;
        if (productCategoryCollection2.position == null) return 0;

        return productCategoryCollection1.position!.compareTo(productCategoryCollection2.position!);
      });
    } else {
      categories = await (appWooSignal((api) => api.getProductCategories(parent: 0, perPage: 50, hideEmpty: true)));
      categories.sort((category1, category2) => category1.menuOrder!.compareTo(category2.menuOrder!));

      //Remove uncategorized category
      categories.removeWhere((element) => (element.name ?? "").contains("Uncategorized"));
    }
  }

  @override
  boot() async {
    await _loadCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(trans("Categories")),
      ),
      body: SafeArea(
        child: categories.isEmpty
            ? Center(
                child: AppLoaderWidget(),
              )
            : ListView.builder(
                shrinkWrap: true,
                itemCount: categories.length + 1,
                itemBuilder: (BuildContext context, int index) {
                  if (index == 0) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          NyTextField.compact(
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.search),
                              hintText: trans("Search hint"),
                              hintStyle: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.black),
                            ),
                            backgroundColor: Colors.grey.shade200,
                            controller: _txtSearchController,
                            style: Theme.of(context).textTheme.displaySmall,
                            keyboardType: TextInputType.text,
                            autocorrect: false,
                            autoFocus: false,
                            textCapitalization: TextCapitalization.sentences,
                            onSubmitted: (_) => _actionSearch,
                            onTapOutside: (_) => _actionSearch(),
                          ),
                          const SizedBox(height: 16),
                          PrimaryButton(
                            title: trans("Search"),
                            action: _actionSearch,
                          ),
                          const SizedBox(height: 36),
                        ],
                      ),
                    );
                  }

                  ProductCategory category = categories[index - 1];
                  return ListTile(
                    title: Text(
                      category.name ?? "",
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 16),
                    ),
                    trailing: Icon(Icons.keyboard_arrow_right_rounded),
                    onTap: () {
                      routeTo(BrowseCategoryPage.path, data: category);
                    },
                  );
                },
              ),
      ),
    );
  }
}
